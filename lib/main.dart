import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:notes_app/files.dart';
import 'package:notes_app/home.dart';
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
      title: 'Solid Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Notes'),
      onGenerateRoute: (settings) {
        if (settings.name == ReadNote.route) {
          return MaterialPageRoute<String>(
            builder: (context) {
              return ReadNote(settings.arguments);
            }
          );
        } else if (settings.name == CreateNotePage.route) {
          return MaterialPageRoute<String>(
            builder: (context) {
              return CreateNotePage(settings.arguments);
            }
          );
        }
        return null;
      },
    );
  }
}

