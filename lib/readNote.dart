import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notes_app/createNote.dart';
import 'package:notes_app/files.dart';

class ReadNote extends StatelessWidget {
  static const route = '/readNote';

  @override
  Widget build(BuildContext context) {
    final String noteName = ModalRoute.of(context).settings.arguments;
    return FileView(noteName);
  }
}

class FileView extends StatefulWidget {
  final String fileName;
  FileView(this.fileName);
  @override
  _FileViewState createState() => _FileViewState(fileName);
}

class _FileViewState extends State<FileView> {
  static String fileName;
  _FileViewState(fileName) {
    _FileViewState.fileName = fileName;
  }

  void initState() {
    super.initState();
    /// This is needed because otherwise, the last selected note will be displayed.
    /// I think this has to do with the fact that `fileName` is static (which
    /// it needs to be to be used in a FutureBuilder). in any case, this function
    /// seems to solve the problem.
    setState(() {
      _refreshNote();
    });
  }

  void _navigateToEditNote() async {
    var returned = await Navigator.pushNamed(context, CreateNotePage.route, arguments: fileName);
    if (returned != null) {
      fileName = returned;
      setState(() {
        _refreshNote();
      });
    }
  }

  void _refreshNote() {
    _fileView = FutureBuilder(
      future: readFile(fileName),
      builder: _createFileView,
    );
  }

  FutureBuilder _fileView = FutureBuilder(
    future: readFile(fileName),
    builder: _createFileView,
  );

  static Widget _createFileView(BuildContext context, AsyncSnapshot snapshot) {
    String data = snapshot.data;
    if (data != null) {
      return Container(
        color: Colors.white60,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Markdown(
            data: data,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 25),
      child: Column(
        children: <Widget>[
          Center(
            child: Text("Loading...",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: _fileView,
      floatingActionButton: FloatingActionButton(
        tooltip: "edit",
        onPressed: _navigateToEditNote,
        child: Icon(Icons.edit),
      ),
    );
  }
}