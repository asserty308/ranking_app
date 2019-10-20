import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/list_table_provider.dart';
import 'package:ranking_app/data/models/list.dart';
import 'package:ranking_app/screens/list_detail_screen.dart';
import 'package:ranking_app/widgets/home_screen_list_tile.dart';
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
        afterReorder: (oldIndex, newIndex) => updateListIndices(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewList(context),
        tooltip: 'Add new list',
        child: Icon(Icons.add),
      ),
    );
  }

  /// Fetches the db to reload the listData
  void reloadData() async {
    listData.clear();

    // fetch list data and sort by position
    var models = await ListTableProvider.table.getAll();
    models.sort((a, b) => a.position.compareTo(b.position));

    for (var m in models) {
      listData.add(
        HomeScreenListTile(
          key: ValueKey(m.key),
          item: m, 
          shouldReloadData: () => reloadData(),
          onTap: (item) => showListDetail(context, item.key, item.title),
        )
      );
    }

    // update UI to show the list
    setState(() { 
    });
  }

  /// Creates a list tile from the name entered in a dialog
  void addNewList(BuildContext context) async  {
    final title = await showAddListDialog(context);
    var key = 'list_$title'.toLowerCase().replaceAll(' ', '_');
    final index = await ListTableProvider.table.tableCount();

    // this shouldn't happen
    if (title == null) {
      return;
    }

    // check if entry with key already exists
    var existingEntry = await ListTableProvider.table.getWithKey(key);

    if (existingEntry != null) {
      if (existingEntry.title == title) {
        // there can only be one list with the same title
        showEntryAlreadyExistsDialog(context);
        // alternative: ask user if he really wants to add two same titled lists
        return;
      }
      
      // only the key is duplicated (can happen when the user changed the title after creation)
      // append 'x' to the existing key
      key += 'x';
    }

    // create ListDM and add to db
    var newList = ListDM(
      key: key,
      title: title,
      subtitle: '',
      position: index
    );

    ListTableProvider.table.insert(newList);

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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Duplicate'),
          content: Text('A list with the desired name already exists. Please choose another title.'),
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

  void showListDetail(BuildContext context, String key, String title) {
    Navigator.pushNamed(
      context, 
      '/list_detail',
      arguments: ListDetailScreenArguments(key, title),
    );
  }

  /// Updates ListDM's indices in database by looking at listData.
  /// 
  /// Should be called on [afterReorder] when the re-indexed list is available.
  Future<void> updateListIndices() async {
    for (int i = 0; i < listData.length; i++) {
      final tile = listData[i];
      final key = (tile.key as ValueKey).value;
      final entry = await ListTableProvider.table.getWithKey(key);
      entry.position = i;

      ListTableProvider.table.update(entry);
    }
  }
}