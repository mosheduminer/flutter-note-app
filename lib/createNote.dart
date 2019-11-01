import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notes_app/files.dart';
import 'package:notes_app/markdown.dart';


class CreateNotePage extends StatelessWidget {
  static const route = "/editNote";

  final String noteName;

  CreateNotePage(this.noteName);

  @override
  Widget build(BuildContext context) {
    return CreateNote(noteName);
  }

}

class CreateNote extends StatefulWidget {
  final String noteName;
  CreateNote(this.noteName);

  @override
  _CreateNotePageState createState() => _CreateNotePageState(noteName);
}

class _CreateNotePageState extends State<CreateNote> {
  static String noteName;
  _CreateNotePageState(String noteName) {
    _CreateNotePageState.noteName = noteName;
  }
  bool _editing = false;

  final _inputFormKey = GlobalKey<FormState>();

  final _titleFormKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _inputController = TextEditingController();

  String _title = new DateTime.now().toString();
  String _input = "";

  ShowMarkdown showMarkdown = ShowMarkdown("");

  void refreshMarkdown() {
    showMarkdown.inputState.changeValue(_input);
  }

  String _validator(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    } else {
      return null;
    }
  }

  void initState() {
    super.initState();
    if (noteName != null) {
      _editing = true;
      _title = noteName;
      readFile(noteName).then((data) {
        _input = data;
        setState(() {
          _inputController.text = data;
        });
        refreshMarkdown();
      });
    }
  }

  void _saveInput() {
    writeFile(_input, _title);
    Navigator.pop(context, _title);
  }

  Widget _titleDialogBuilder(BuildContext context) {
    _titleController.text = _title;
    _titleController.selection = TextSelection(
      baseOffset: 0, extentOffset: _titleController.text.length
    );
    return AlertDialog(
      title: Text(
          "Title"
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
                    setState(() {
                      _title = _titleController.value.text;
                    });
                    Navigator.pop(context);
                  }
                })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [
      IconButton(
        icon: Icon(Icons.save),
        onPressed: () {
          if (_inputFormKey.currentState.validate()) {
            _saveInput();
          }
          return null;
        },
      ),
    ];
    if (!_editing) {
      actions.insert(0,
        IconButton(
          icon: Icon(Icons.title),
          onPressed: () {
            showDialog(
              context: context,
              builder: _titleDialogBuilder,
            );
          },
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: actions,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.text_fields)),
              Tab(icon: Icon(Icons.text_format)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              child: Form(
                key: _inputFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    autofocus: true,
                    controller: _inputController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dashed
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: "Type here. Markdown is supported.",
                        border: InputBorder.none
                    ),

                    validator: _validator,
                    onChanged: (String input) {
                      this._input = input;
                      refreshMarkdown();
                    },
                  ),
                ),
              ),
            ),
            showMarkdown
          ],
        ),
      ),
    );
  }
}
