library hetimafile.base;

import 'dart:async';
import 'dart:html' as html;
import 'package:hetimacore/hetimacore.dart' as hetima;
import 'package:hetimacore/hetimacore_cl.dart' as hetima;
import 'dart:js' as js;

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
}




abstract class HetiFile extends HetiEntry {
  String get name;
  bool isFile() {
    return true;
  }
  Future<hetima.HetimaBuilder> getHetimaBuilder();
}


abstract class HetiFileSystem {
  HetiDirectory get root;
}


