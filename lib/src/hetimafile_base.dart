library hetimafile.base;

import 'dart:async';
import 'package:hetimacore/hetimacore.dart' as hetima;

class HetiEntry {
  String get name => "";
  String get fullPath => "";
  bool isFile() {
    return false;
  }
  bool isDirectory() {
    return false;
  }
}

abstract class HetiDirectory extends HetiEntry {
  List<HetiEntry> lastGetList = [];
  Future<HetiDirectory> getParent();
  bool isDirectory();
  String get name;
  String get fullPath;
  Future<List<HetiEntry>> getList();
  Future<HetiDirectory> createDirectory(String name, {bool exclusive: false});
  Future<HetiDirectory> getDirectory(String path);
  Future<HetiFile> createFile(String path, {bool exclusive: false});
  Future<HetiFile> getFile(String path);
  Future<dynamic> remove();
  Future<dynamic> removeRecursively();
}

abstract class HetiFile extends HetiEntry {
  String get name;
  bool isFile() {
    return true;
  }
  Future<hetima.HetimaData> getHetimaFile();
  Future<dynamic> remove();
  Future<HetiDirectory> getParent();
}


abstract class HetiFileSystem {
  HetiDirectory get root;
}


abstract class HetiFileSystemBuilder {
  Future<HetiFileSystem> getFileSystem();
}

