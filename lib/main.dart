import 'package:flutter/material.dart';
import 'package:ranking_app/screens/home_screen.dart';
import 'package:ranking_app/screens/list_detail_screen.dart';

// New ideas:
// TODO: Preference Screen (dark theme, notifications)
// TODO: Friend system with public / private lists
// TODO: ListEntryDetail Screen for detailed information about the entry (memories, first encounter, private pictures, etc.)
// TODO: Share lists to social media

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranking App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/list_detail': (context) => ListDetailScreen(),
      },
    );
  }
}
