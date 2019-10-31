import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> get _localNotePath async {
  final path = await _localPath;
  return '$path/notes';
}

Future<File> _localFile (String name) async {
  final path = await _localNotePath;
  return File('$path/$name');
}

/// this function initializes the necessary directories for app functionality,
/// in the case that they don't already exist.
/// it is called on app startup
createDirectories() {
  _localNotePath.then((String path) {
    Directory(path).exists().then((bool exists) {
      if (!exists) {
        Directory(path).create();
      }
    });
  });
}

Future<List<FileSystemEntity>> listFiles() {
  return _localNotePath.then((String path) {
    return Directory(path).list(followLinks: false).toList();
  });
}

void writeFile(String text, String name) async {
  final File file = await _localFile(name);

  // Write the file.
  file.writeAsString(text);
}

Future<String> readFile(String name) async {
  try {
    final file = await _localFile(name);

    // Read the file.
    String contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return null.
    return null;
  }
}

Future<File> deleteFile(String name) async {
  final dirObj = await _localFile(name);

  return dirObj.delete();
}