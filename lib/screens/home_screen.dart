import 'package:flutter/material.dart';
import 'package:ranking_app/screens/list_detail_screen.dart';
import 'package:ranking_app/widgets/my_reorderable_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var listData = List<Widget>();

  /// Creates a list tile from the name entered in a dialog
  void addNewList(BuildContext context) async  {
    var title = await showAddListDialog(context);
    var key = 'list_$title';

    setState(() {
      if (title == null) {
        return;
      }

      // TODO: check if title already exists
      // TODO: create ListDM and add to db
        
      listData.add(
        ListTile(
          key: ValueKey(key),
          title: Text(title),
          onTap: () {
            showList(context, key, title);
          },
         )
       );
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

  void showList(BuildContext context, String key, String title) {
    Navigator.pushNamed(
      context, 
      '/list_detail',
      arguments: ListDetailScreenArguments(key, title),
    );
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
}