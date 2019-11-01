import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notes_app/files.dart';
import 'package:notes_app/createNote.dart';
import 'package:notes_app/readNote.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static UniqueKey fileListViewKey = UniqueKey();

  void _navigateToNewNote() {
    Navigator.pushNamed(context, CreateNotePage.route).then((value) {
      setState(() {
        _refreshList();
      });
    });
  }

  /// used to refresh the list of notes, after a new note is created
  void _refreshList() {
    fileListView = FutureBuilder(
      future: listFiles(),
      initialData: ["Loading..."],
      builder: _createFileListView,
    );
  }

  /// see initState
  static ValueNotifier<int> valueNotifier = ValueNotifier(0);

  initState() {
    super.initState();
    /// This listener is for static methods to refresh the page, since they
    /// can't call setState
    valueNotifier.addListener(() {
      setState(() {
        _refreshList();
      });
    });
  }

  FutureBuilder fileListView = FutureBuilder(
    future: listFiles(),
    initialData: ["Loading..."],
    builder: _createFileListView,
  );

  static Future _rename(String oldFileName, newFileName) async {
    await readFile(oldFileName).then((text) {
      writeFile(text, newFileName);
    });
    deleteFile(oldFileName).then((value) {
      valueNotifier.value += 1;
    });
  }

  static void _delete(String fileName) {
    deleteFile(fileName).then((value) {
      valueNotifier.value += 1;
    });
  }

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
    } else { /// return ListView of names of saved files
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          String oldTitle = data[index];
          Widget _titleDialogBuilder(BuildContext context) {
            return TitleDialogBuilder(oldTitle);
          }
          return Card(
            elevation: 10,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, ReadNote.route, arguments: data[index]).then((value) {});
              },
              title: Text(data[index],
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              trailing: PopupMenuButton<PopupMenuSelection>(
                onSelected: (PopupMenuSelection selection) {
                  if (selection.popupMenuOption == PopupMenuOptions.Rename) {
                    showDialog(
                      context: context,
                      builder: _titleDialogBuilder,
                    );
                  } else if (selection.popupMenuOption == PopupMenuOptions.Delete) {
                    _delete(selection.fileName);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: PopupMenuSelection(PopupMenuOptions.Rename, data[index]),
                    child: Text("Rename"),
                  ),
                  PopupMenuItem(
                    value: PopupMenuSelection(PopupMenuOptions.Delete, data[index]),
                    child: Text("Delete"),
                  ),
                ],
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

enum PopupMenuOptions {Rename, Delete}

class PopupMenuSelection {
  final String fileName;
  final PopupMenuOptions popupMenuOption;
  const PopupMenuSelection(this.popupMenuOption, this.fileName);
}


class TitleDialogBuilder extends StatelessWidget {
  static String route = '/TitleDialogBuilder';
  final String _oldTitle;
  TitleDialogBuilder(this._oldTitle);

  static final _titleFormKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  String _validator(value) {
    if (value.isEmpty) {
      return 'Name cannot be empty!';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = _oldTitle;
    _titleController.selection = TextSelection(
        baseOffset: 0, extentOffset: _titleController.text.length
    );
    log(_titleFormKey.currentState.toString());
    return AlertDialog(
      title: Text(
          "Rename"
      ),
      content: Form(
        key: _titleFormKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.50,
              child: TextFormField(
                autofocus: true,
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                validator: _validator,
              ),
            ),
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  if (_titleFormKey.currentState.validate()) {
                    _titleFormKey.currentState.save();
                    _HomePageState._rename(_oldTitle, _titleController.value.text);
                    Navigator.pop(context);
                  }
                })
          ],
        ),
      ),
    );
  }
}