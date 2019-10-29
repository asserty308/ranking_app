import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/list_table_provider.dart';
import 'package:ranking_app/data/models/list.dart';
import 'package:ranking_app/screens/delegates/home_screen_search_delegate.dart';
import 'package:ranking_app/utility/dialogs.dart';
import 'package:ranking_app/widgets/home_screen_list_tile.dart';
import 'package:ranking_app/widgets/my_reorderable_list.dart';

import 'list_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var listData = List<Widget>();

  // Add list validation
  var newListTitleEmpty = false;
  var newListDuplicate = false;

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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => showListSearch(context),
          )
        ],
      ),
      body: MyReorderableList(
        listData: listData,
        afterReorder: (oldIndex, newIndex) => updateListIndices(),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () {

              },
            )
          ],
        ),
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
          onTap: (item) => showScreenListDetail(context, item.key, item.title),
        )
      );
    }

    // update UI to show the list
    setState(() { 
    });
  }

  /// Creates a list tile from the name entered in a dialog
  void addNewList(BuildContext context) async  {
    // Look for errors from inputs (addNewList will be called again when the user enters invalid input)
    var error = newListTitleEmpty ? 'The title can\'t be empty' : '';
    
    if (error.isEmpty) {
      error = newListDuplicate ? 'Duplicate. Please choose another title.' : '';
    }

    // reset validations so future additions will not start with an error
    newListTitleEmpty = false;
    newListDuplicate = false;

    // Ask the user for a list title - when user presses 'cancel' title will be null
    final title = await showInputDialog(
      context: context, 
      title: 'New List', 
      inputHint: 'Title', 
      withError: error
    );

    if (title == null) {
      return;
    }

    if (title.isEmpty) {
      // retry with error message
      newListTitleEmpty = true;
      addNewList(context);
      return;
    }

    var key = 'list_$title'.toLowerCase().replaceAll(' ', '_');
    final index = await ListTableProvider.table.tableCount();

    // check if entry with key already exists
    var existingEntry = await ListTableProvider.table.getWithKey(key);

    if (existingEntry != null) {
      if (existingEntry.title == title) {
        // there can only be one list with the same title
        newListDuplicate = true;
        addNewList(context);
        return;
      }
      
      // only the key is duplicated (can happen when the user changed the title after creation)
      // append 'x' to the existing key
      key += 'x';
    }

    // Ask the user for a subtitle - when user presses 'cancel' subtitle will be empty
    final subtitle = await showInputDialog(
      context: context, 
      title: 'Insert a subtitle for the list "$title"', 
      inputHint: 'Subtitle (optional)',
    ) ?? '';

    // create ListDM and add to db
    var newList = ListDM(
      key: key,
      title: title,
      subtitle: subtitle,
      position: index
    );

    await ListTableProvider.table.insert(newList);

    // reload data to show the new entry
    reloadData();
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

  void showScreenListDetail(BuildContext context, String key, String title) {
    Navigator.pushNamed(
      context, 
      '/list_detail',
      arguments: ListDetailScreenArguments(key, title),
    ).then((value) {
      // Called when coming back from 'ListDetailScreen' (e.g. when back button was pressed)
      setState(() {
        // reload data because the list name could've changed
        reloadData();
      });
    });
  }

  Future<void> showListSearch(BuildContext context) async {
    var selectedList = await showSearch<ListDM>(
      context: context,
      delegate: HomeScreenSearchDelegate(),
    );

    // when back button was pressed [selectedList] is null
    if (selectedList == null) {
      return;
    }

    showScreenListDetail(context, selectedList.key, selectedList.title);
  }
}