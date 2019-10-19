import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/list_table_provider.dart';
import 'package:ranking_app/data/models/list.dart';

class HomeScreenListTile extends StatelessWidget {
  const HomeScreenListTile({
    Key key,
    @required this.item,
    @required this.afterDelete,
    @required this.onTap,
  }) : super(key: key);

  final ListDM item;
  final Function afterDelete;
  final Function(ListDM item) onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${item.key}'),
      background: Container(
        color: Colors.red,
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // remove item from table
        ListTableProvider.table.delete(item.key);

        // Show a snackbar. This snackbar could also contain "Undo" actions.
        Scaffold
          .of(context)
          .showSnackBar(
            SnackBar(
              content: Text("${item.title} wurde gelöscht"),
              action: SnackBarAction(
                label: 'Wiederherstellen',
                onPressed: () {
                  // TODO: Implementation
                },
              ),
            )
          );

        afterDelete();
      },
      child: ListTile(
        title: Text(item.title),
        onTap: () => onTap(item),
      ),
    );
  }
}