import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notes_app/files.dart';
import 'package:notes_app/createNote.dart';
import 'package:notes_app/readNote.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  MyApp() {
    createDirectories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        ReadNote.route: (context) => ReadNote(),
        CreateNotePage.route: (context) => CreateNotePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static UniqueKey fileListViewKey = UniqueKey();

  void _navigateToNewNote() {
      // Use `Navigator` widget to push the second screen to out stack of screens
      Navigator.push(context, MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new CreateNotePage();
      })).then((value) {
        setState(() {}); /// refresh the route
      });
  }

  FutureBuilder fileListView = FutureBuilder(
    future: listFiles(),
    initialData: ["Loading..."],
    builder: _createFileListView,
  );

  /// this function is called by the builder in `fileListView`
  static Widget _createFileListView(BuildContext context, AsyncSnapshot snapshot) {
    /// extract the file paths (`data`), strip, and leave the names
    List data = snapshot.data.map((item) {
      String itemString = item.toString();
      return itemString.substring(itemString.lastIndexOf('/') + 1, itemString.length - 1);
    }).toList();
    if (data.length == 0) { /// check for the possibility that no files have been saved
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 25),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                "Hey! You haven't saved anything yet. Begin by tapping the Create button",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(120, 120, 120, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w400
                ),
              ),
            )
          ],
        ),
      );
    } else { /// return names of saved files as a list of widgets
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, ReadNote.route, arguments: data[index]);
              },
              title: Text(data[index],
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: fileListView,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewNote,
        tooltip: 'Create',
        child: Icon(Icons.create),
      ),
    );
  }
}