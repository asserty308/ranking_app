import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/list_table_provider.dart';
import 'package:ranking_app/data/models/list.dart';
import 'package:ranking_app/widgets/dismissible_background.dart';

class HomeScreenListTile extends StatelessWidget {
  const HomeScreenListTile({
    Key key,
    @required this.item,
    @required this.shouldReloadData,
    @required this.onTap,
  }) : super(key: key);

  final ListDM item;
  final Function shouldReloadData;
  final Function(ListDM item) onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${item.key}'),
      background: DismissibleBackground(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => deleteEntry(item.key, context),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.position % 2 == 0 ? Colors.blue.shade800 : Colors.blue.shade200,
            child: Text('${item.title[0]}'),
          ),
          title: Text(item.title),
          subtitle: Text('This will show a short description of the list.'),
          onTap: () => onTap(item),
        ),
      ),
    );
  }

  /// Deletes the list with the given [key] as well as all its content.
  /// Shows a [SnackBar] to inform the user about the deletion and provides an 'undo' action to restore the list.
  void deleteEntry(String key, BuildContext context) async {
    // make a copy of the dismissed item to let the user undo the deletion
    var copy = await ListTableProvider.table.getWithKey(key);

    // TODO: Keep a reference of all list entries
    // Cannot wait for deletion of the items until the snackbar has disappeared because the user could close the app before. This will lead to unreferenced entries.

    // remove item from table
    ListTableProvider.table.delete(key);

    // TODO: Delete all list entries

    // reload after deletion
    shouldReloadData();
    
    // Show a snackbar. This snackbar also contains an 'undo' action.
    Scaffold
      .of(context)
      .showSnackBar(
        SnackBar(
          content: Text("${item.title} has been deleted"),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              ListTableProvider.table.insert(copy);
              // TODO: Insert all list entries

              // reload after restoring
              shouldReloadData();
            },
          ),
        )
      );
  }
}