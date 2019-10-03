import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyReorderableList extends StatefulWidget {
  MyReorderableList({this.listData, this.afterReorder});

  final List<Widget> listData;
  final Function(int oldIndex, int newIndex) afterReorder;

  @override
  MyReorderableListState createState() => MyReorderableListState(listData: listData, afterReorder: afterReorder);
}

class MyReorderableListState extends State<MyReorderableList> {
  MyReorderableListState({this.listData, this.afterReorder});

  /// A list containing all elements of the ListView.
  final List<Widget> listData;

  /// A [Funtion] which will be executed at the end of [onReorder].
  Function(int oldIndex, int newIndex) afterReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          // prevents out-of-bounds exception because the item will be removed before inserted again
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }

          // Delay needed as a workaround for the error 'Multiple widgets used the same GlobalKey'
          // Flutter needs 20-50ms to refresh the keys 
          Future.delayed(Duration(milliseconds: 20), () {
            setState(() {
              // remove item at old index and add to new index
              final item = listData.removeAt(oldIndex);
              listData.insert(newIndex, item);

              afterReorder(oldIndex, newIndex);
            });
          });
        },
        children: listData,
      );
  }
}