import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/list_entry_table_provider.dart';
import 'package:ranking_app/data/database/list_table_provider.dart';
import 'package:ranking_app/data/models/list_entry.dart';
import 'package:ranking_app/utility/dialogs.dart';
import 'package:ranking_app/widgets/my_reorderable_list.dart';

class ListDetailScreenArguments {
  final String listKey;
  final String title;
  ListDetailScreenArguments(this.listKey, this.title);
}

class ListDetailScreen extends StatefulWidget {
  @override
  ListDetailScreenState createState() => ListDetailScreenState();
}

class ListDetailScreenState extends State<ListDetailScreen> {
  var listData = List<Widget>();
  var listTitle = '';
  var listKey = '';

  @override
  void initState() {
    super.initState();
    
    // run 'afterFirstlayout' after first build()
    WidgetsBinding.instance.addPostFrameCallback((_) => afterFirstlayout(context));
  }

  @override
  Widget build(BuildContext context) {
    final ListDetailScreenArguments args = ModalRoute.of(context).settings.arguments;

    // only read once because listtitle can change on runtime
    listTitle = listTitle.isEmpty ? args.title : listTitle;
    listKey = args.listKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(listTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white,),
            onPressed: () => renameList(),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white,),
            onPressed: null,
          )
        ],
      ),
      body: MyReorderableList(
        listData: listData,
        afterReorder: (oldIndex, newIndex) => updateListIndices(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewEntry(context, listKey),
        tooltip: 'Add new entry',
        child: Icon(Icons.add),
      )
    );
  }

  void afterFirstlayout(BuildContext context) {
    // show search when showing screen
    reloadData();
  }

  /// Fetches the db to reload the listData
  void reloadData() async {
    listData.clear();

    // fetch list data and sort by position
    var models = await ListEntryTableProvider.table.getAllFromList(listKey);
    models.sort((a, b) => a.position.compareTo(b.position));

    for (var m in models) {
      listData.add(
        ListTile(
          key: ValueKey(m.key),
          title: Text(m.title),
          subtitle: Text(m.subtitle),
          leading: Icon(Icons.format_list_bulleted), // TODO: Change to customizable image
        )
      );
    }

    // update UI to show the list
    setState(() { 
    });
  }

  void addNewEntry(BuildContext context, String listKey) async {
    final title = await showInputDialog(context: context, title: 'New Entry', inputHint: 'Title');
    var key = '${listKey}_$title'.toLowerCase().replaceAll(' ', '_');
    final index = await ListEntryTableProvider.table.listCount(listKey);

    // this shouldn't happen
    if (title == null) {
      return;
    }

    // check if entry with key already exists
    var existingEntry = await ListEntryTableProvider.table.getWithKey(key);

    if (existingEntry != null) {
      if (existingEntry.title == title) {
        // there can only be one list with the same title
        showOKDialog(context, 'Duplicate', 'An entry with the desired name already exists. Please choose another title.');
        // alternative: ask user if he really wants to add two same titled entries
        return;
      }
      
      // only the key is duplicated (can happen when the user changed the title after creation)
      // append 'x' to the existing key
      key += 'x';
    }

    final entry = ListEntryDM(
      key: key,
      title: title,
      subtitle: '',
      position: index,
      listKey: listKey,
    );

    await ListEntryTableProvider.table.insert(entry);

    // reload data to show the new entry
    reloadData();
  }

  /// Updates ListEntryDM's indices in database by looking at listData.
  /// 
  /// Should be called on [afterReorder] when the re-indexed list is available.
  Future<void> updateListIndices() async {
    for (int i = 0; i < listData.length; i++) {
      final tile = listData[i];
      final key = (tile.key as ValueKey).value;
      final entry = await ListEntryTableProvider.table.getWithKey(key);
      entry.position = i;

      ListEntryTableProvider.table.update(entry);
    }
  }

  Future<void> renameList() async {
    // fetch list with current key
    final entry = await ListTableProvider.table.getWithKey(listKey);

    // Ask the user for the new list title - when user presses 'cancel' title will be null
    var title = await showInputDialog(
      context: context, 
      title: 'Rename list', 
      inputHint: 'New title',
    );

    if (title == null) {
      return;
    }

    // set default value instead of showing an error
    // this is not as critical as setting no title when creating a new list
    if (title.isEmpty) {
      title = '<unknown title>';
    }

    // update entry with new title
    entry.title = title;

    // update app bar title
    listTitle = title;

    ListTableProvider.table.update(entry);

    setState(() {
    });
  }
}