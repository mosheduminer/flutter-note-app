import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class InputState extends ValueNotifier<String> {
  InputState(value) : super(value);
  void changeValue(newValue) {
    value = newValue;
  }
}

class ShowMarkdown extends StatefulWidget {
  final InputState inputState = InputState('');

  ShowMarkdown(data) {
    inputState.changeValue(data);
  }

  @override
  _ShowMarkdownState createState() => _ShowMarkdownState(inputState);
}

class _ShowMarkdownState extends State<ShowMarkdown> {
  InputState inputState;

  _ShowMarkdownState(this.inputState);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: inputState,
      builder: (context, value, _) {
        return Markdown(data: value,);
      },
    );
  }
}