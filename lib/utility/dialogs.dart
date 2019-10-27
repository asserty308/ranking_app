import 'package:flutter/material.dart';

/// Returns the name of the list entered in the textfield
Future<String> showInputDialog(BuildContext context, String title, String inputHint, [String withError = '']) async {
  String inputText;

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: inputHint,
            errorText: withError.isNotEmpty ? withError : null,
          ),
          onChanged: (value) {
            inputText = value;
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(inputText)
          )
        ],
      );
    }
  );
}

void showOKDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop()
          )
        ],
      );
    }
  );
}