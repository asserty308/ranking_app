import 'package:flutter/material.dart';
import 'package:ranking_app/data/database/list_table_provider.dart';
import 'package:ranking_app/data/models/list.dart';

class HomeScreenSearchDelegate extends SearchDelegate<ListDM> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // add a 'clear query' button
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // show a back button to close the search
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return showSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return showSearchResults();
  }

  Widget showSearchResults() {
    final searchResults = ListTableProvider.table.search(query);

    return FutureBuilder<List<ListDM>>(
      future: searchResults,
      builder: (BuildContext context, AsyncSnapshot<List<ListDM>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var widgetList = <Widget>[];

          if (snapshot.data == null) {
            return Center(child: Text('Nothing found.'));
          }

          for (var list in snapshot.data) {
            widgetList.add(
              ListTile(
                title: Text(list.title),
                onTap: () {
                  Navigator.pop(context, list); // pop search delegate
                },
              )
            );
          }

          return ListView.builder(
            itemCount: widgetList.length,
            itemBuilder: (context, index) {
              return widgetList[index];
            }
          );
        }

        // show progress indicator when search results aren't available
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}