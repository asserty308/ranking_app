import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyReorderableList extends StatefulWidget {
  MyReorderableList({this.listData});

  final List<Widget> listData;

  @override
  MyReorderableListState createState() => MyReorderableListState(listData: listData);
}

class MyReorderableListState extends State<MyReorderableList> {
  MyReorderableListState({this.listData});

  final List<Widget> listData;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
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
        children: listData,
      );
  }
}