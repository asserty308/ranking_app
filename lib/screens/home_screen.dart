import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/db_provider.dart';
import 'package:ranking_app/data/models/list.dart';
import 'package:ranking_app/screens/list_detail_screen.dart';
import 'package:ranking_app/widgets/my_reorderable_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var listData = List<Widget>();

  @override
  void initState() {
    super.initState();
    
    // load existing lists from db
    reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Collection'),
      ),
      body: MyReorderableList(
        listData: listData,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewList(context);
        },
        tooltip: 'Add new list',
        child: Icon(Icons.add),
      ),
    );
  }

  /// Fetches the db to reload the listData
  void reloadData() async {
    listData.clear();

    var models = await RankingDatabaseProvider.db.getAllLists();

    for (var m in models) {
      listData.add(
        ListTile(
          key: ValueKey(m.key),
          title: Text(m.title),
          onTap: () {
            showList(context, m.key, m.title);
          },
         )
       );
    }

    setState(() { 
    });
  }

  /// Creates a list tile from the name entered in a dialog
  void addNewList(BuildContext context) async  {
    var title = await showAddListDialog(context);
    var key = 'list_$title';
    key = key.toLowerCase().replaceAll(' ', '_');
    var index = await RankingDatabaseProvider.db.getListsLength();

    if (title == null) {
      return;
    }

    // check if title already exists
    var existingEntry = await RankingDatabaseProvider.db.getListWithKey(key);

    if (existingEntry != null) {
      showEntryAlreadyExistsDialog(context);
      return;
    }

    // create ListDM and add to db
    var newList = ListDM(
      key: key,
      title: title,
      subtitle: '',
      position: index
    );

    RankingDatabaseProvider.db.insertNewList(newList);

    // reload data to show the new entry
    setState(() {
      reloadData();
    });
  }

  /// Returns the name of the list entered in the textfield
  Future<String> showAddListDialog(BuildContext context) async {
    String listName;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New List'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Name',
            ),
            onChanged: (value) {
              listName = value;
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(listName)
            )
          ],
        );
      }
    );
  }

  void showEntryAlreadyExistsDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('A list with the desired name already exists. Please choose another title.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop()
            )
          ],
        );
      }
    );
  }

  void showList(BuildContext context, String key, String title) {
    Navigator.pushNamed(
      context, 
      '/list_detail',
      arguments: ListDetailScreenArguments(key, title),
    );
  }
}