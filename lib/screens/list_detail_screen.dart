import 'package:flutter/material.dart';
import 'package:ranking_app/widgets/my_reorderable_list.dart';

class ListDetailScreenArguments {
  final String key;
  final String title;
  ListDetailScreenArguments(this.key, this.title);
}

class ListDetailScreen extends StatefulWidget {
  @override
  ListDetailScreenState createState() => ListDetailScreenState();
}

class ListDetailScreenState extends State<ListDetailScreen> {
  var listData = List<Widget>();
  
  void addNewEntry(BuildContext context) {
    // TODO: Implementation
  }

  @override
  Widget build(BuildContext context) {
    final ListDetailScreenArguments args = ModalRoute.of(context).settings.arguments;
    final String title = args.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: MyReorderableList(
        listData: listData,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewEntry(context),
        tooltip: 'Add new entry',
        child: Icon(Icons.add),
      )
    );
  }
}