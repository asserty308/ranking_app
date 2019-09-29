import 'package:flutter/material.dart';
import 'package:ranking_app/widgets/my_reorderable_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var listData = List<Widget>();

  /// Creates a list tile from the name entered in a dialog
  void addNewList(BuildContext context) async  {
    var name = await showAddListDialog(context);
    var key = 'list_$name';

    setState(() {
      if (name == null) {
        return;
      }

      // TODO: check name already exists
        
      listData.add(
        ListTile(
          key: ValueKey(key),
          title: Text(name),
          onTap: () {
            showList(key);
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

  void showList(String key) {
    // TODO: go to 'ListDetailScreen'
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