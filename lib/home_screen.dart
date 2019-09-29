import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var listData = <String>[
    'Test 1',
    'Test 2',
    'Test 3',
  ];

  void addNewList() {
    setState(() {
     //todo 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meine Sammlung'),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            // prevents out-of-bounds exception because the item will be removed before inserted again
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }

           // remove item at old index and add to new index
           final item = listData.removeAt(oldIndex);
           listData.insert(newIndex, item);
          });
        },
        children: <Widget>[
          for (final item in listData) 
            ListTile(
              key: ValueKey(item),
              title: Text(item)
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewList,
        tooltip: 'Add new list',
        child: Icon(Icons.add),
      ),
    );
  }
}