library hetimafile.cl;

import 'dart:async';
import 'dart:html' as html;
import 'package:hetimacore/hetimacore.dart' as hetima;
import 'package:hetimacore/hetimacore_cl.dart' as hetima;
import 'dart:js' as js;
import 'hetimafile_base.dart';
import 'dart:typed_data' as type;

class DomJSHetiDirectory extends HetiDirectory {
  js.JsObject _directory = null;
  List<HetiEntry> lastGetList = [];

  DomJSHetiDirectory._create(js.JsObject e) {
    this._directory = e;
  }

  js.JsObject toBinary() {
    return _directory;
  }

  Future<HetiDirectory> getDirectory(String path) {
    html.Entry r;
    Completer<HetiDirectory> comp = new Completer();
    _directory.callMethod("getDirectory", [
      path,
      new js.JsObject.jsify({'create': false}),
      (a) {
        comp.complete(new DomJSHetiDirectory._create(a));
      },
      (b) {
        comp.completeError(b);
      }
    ]);
    return comp.future;
  }

  Future<HetiFile> createFile(String nameFile, {bool exclusive: false}) {
    Completer<HetiFile> comp = new Completer();
    _directory.callMethod("getFile", [
      nameFile,
      new js.JsObject.jsify({'create': true, 'exclusive': exclusive}),
      (a) {
        comp.complete(new DomJSHetiFile._create(a));
      },
      (b) {
        comp.completeError(b);
      }
    ]);
    return comp.future;
  }
  Future<HetiFile> getFile(String path) {
    Completer<HetiFile> comp = new Completer();
    _directory.callMethod("getFile", [
      path,
      new js.JsObject.jsify({'create': false}),
      (a) {
        comp.complete(new DomJSHetiFile._create(a));
      },
      (b) {
        comp.completeError(b);
      }
    ]);
    return comp.future;
  }
  Future<HetiDirectory> createDirectory(String nameDir, {bool exclusive: false}) {
    Completer<HetiDirectory> comp = new Completer();
    _directory.callMethod("getDirectory", [
      nameDir,
      new js.JsObject.jsify({'create': true, 'exclusive': exclusive}),
      (a) {
        comp.complete(new DomJSHetiDirectory._create(a));
      },
      (b) {
        comp.completeError(b);
      }
    ]);
    return comp.future;
  }

  Future<HetiDirectory> getParent() {
    Completer<HetiDirectory> ret = new Completer();
    _directory.callMethod("getParent", [
      (a) {
        if (a != null) {
          ret.complete(new DomJSHetiDirectory._create(a));
        } else {
          ret.complete(null);
        }
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }

  bool isDirectory() {
    return true;
  }

  String get name => _directory["name"] + "/";
  String get fullPath => _directory["fullPath"];

  Future<List<HetiEntry>> getList() {
    Completer<List<HetiEntry>> ret = new Completer();
    js.JsObject reader = _directory.callMethod("createReader");
    reader.callMethod("readEntries", [
      (a) {
        lastGetList.clear();
        js.JsArray b = a;
        for (js.JsObject c in b.toList()) {
          print("### getList ${c} ${c.runtimeType} ${c["isDirectory"]}");
          if (true == c["isDirectory"]) {
            lastGetList.add(new DomJSHetiDirectory._create(c));
          } else if (true == c["isFile"]) {
            lastGetList.add(new DomJSHetiFile._create(c));
          }
        }
        print("onRead ${a} ${a.runtimeType}");
        ret.complete(lastGetList);
      },
      (b) {
        print("onRead error");
        ret.completeError(b);
      }
    ]);

    return ret.future;
  }

  Future<dynamic> remove() {
    Completer<HetiDirectory> ret = new Completer();
    _directory.callMethod("remove", [
      () {
        ret.complete();
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }

  Future<dynamic> removeRecursively() {
    Completer<HetiDirectory> ret = new Completer();
    _directory.callMethod("removeRecursively", [
      () {
        ret.complete({});
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }
}

/*
class DomHetiDirectory extends HetiDirectory  {
  html.DirectoryEntry _directory = null;
  List<HetiEntry> lastGetList = [];

  DomHetiDirectory._create(html.DirectoryEntry e) {
    this._directory = e;
  }

  Future<HetiDirectory> getParent() {
    Completer<HetiDirectory> ret = new Completer();
    _directory.getParent().then((html.Entry e) {
      if (e != null) {
        ret.complete(new DomHetiDirectory._create(e));
      } else {
        ret.complete(null);
      }
    });
    return ret.future;
  }

  bool isDirectory() {
    return true;
  }

  String get name => _directory.name + "/";
  String get fullPath => _directory.fullPath;

  Future<List<HetiEntry>> getList() {
    Completer<List<HetiEntry>> ret = new Completer();
    html.DirectoryReader reader = _directory.createReader();
    reader.readEntries().then((List<html.Entry> l) {
      lastGetList.clear();
      for (html.Entry e in l) {
        if (e.isFile) {
          lastGetList.add(new DomHetiFile._create(e as html.FileEntry));
        } else {
          lastGetList.add(new DomHetiDirectory._create(e as html.DirectoryEntry));
        }
      }
      ret.complete(lastGetList);
    });
    return ret.future;
  }
}
*/

class DomJSHetiFileWriter extends hetima.HetimaFileWriter {
  js.JsObject _file = null;
  js.JsObject _writer = null;

  html.Blob _mBlob = null;
  DomJSHetiFileWriter(js.JsObject _file, html.Blob blob) {
    this._file = _file;
    _mBlob = blob;
  }

  Future<hetima.WriteResult> write(Object o, int start) {
    if (o is List<int> && !(o is type.Uint8List)) {
      o = new type.Uint8List.fromList(o);
    }
    Completer<hetima.WriteResult> ret = new Completer();
    _file.callMethod("createWriter", [
      (a) {
        _writer = a;
        print("writer ${_writer} ${_writer.runtimeType}");
        _writer["onwriteend"] = (d) {
          print("onwriteend ${d}");
          ret.complete(new hetima.WriteResult());
        };
        //
        // seel
        {
          if (_mBlob.size < start) {
            _writer.callMethod("seek", [_mBlob.size]);
            List<int> d = new type.Uint8List.fromList(new List.filled(start-_mBlob.size, 0));
            html.Blob b = new html.Blob([d,o]);
            _writer.callMethod("write", [b]);
          } else {
            _writer.callMethod("seek", [start]);            
            html.Blob b = new html.Blob([o]);
            _writer.callMethod("write", [b]);
          }
        }
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }
}

class DomJSHetiFile extends HetiFile {
  js.JsObject _file = null;
  DomJSHetiFile._create(js.JsObject file) {
    this._file = file;
  }
  String get name => _file["name"];
  String get fullPath => _file["fullPath"];
  bool isFile() {
    return true;
  }

  Future<HetiDirectory> getParent() {
    Completer<HetiDirectory> ret = new Completer();
    _file.callMethod("getParent", [
      (a) {
        if (a != null) {
          ret.complete(new DomJSHetiDirectory._create(a));
        } else {
          ret.complete(null);
        }
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }

  Future<hetima.HetimaData> getHetimaFile() {
    Completer<hetima.HetimaData> ret = new Completer();
    _file.callMethod("file", [
      (a) {
        hetima.HetimaData ff = new hetima.HetimaDataBlob(a, new DomJSHetiFileWriter(_file, a));
        ret.complete(ff);
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }

  Future<dynamic> remove() {
    Completer<dynamic> ret = new Completer();
    _file.callMethod("remove", [
      () {
        ret.complete({});
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }
}

/*
class DomHetiFile extends HetiFile {
  html.FileEntry _file = null;
  DomHetiFile._create(html.FileEntry file) {
    this._file = file;
  }
  String get name => _file.name;

  bool isFile() {
    return true;
  }

  Future<hetima.HetimaBuilder> getHetimaBuilder() {
    Completer<hetima.HetimaBuilder> ret = new Completer();
    _file.file().then((html.File f) {
      hetima.HetimaFile ff = new hetima.HetimaFileBlob(f);
      hetima.HetimaBuilder b = new hetima.HetimaFileToBuilder(ff);
      ret.complete(b);
    }).catchError((e) {
      ret.completeError(e);
    });
    return ret.future;
  }
}
*/

class DomJSHetiFileSystem extends HetiFileSystem {
  js.JsObject _fileSystem = null;
  static Future<HetiFileSystem> getFileSystem() {
    Completer<HetiFileSystem> ret = new Completer();
    js.context.callMethod("webkitRequestFileSystem", [
      1,
      5 * 1024 * 1024,
      (a) {
        ret.complete(new DomJSHetiFileSystem._create(a));
      },
      (b) {
        ret.completeError(b);
      }
    ]);
    return ret.future;
  }

  DomJSHetiFileSystem._create(js.JsObject fileSystem) {
    this._fileSystem = fileSystem;
  }

  HetiDirectory get root {
    return new DomJSHetiDirectory._create(_fileSystem["root"]);
  }
}

class DomJSHetiFileSystemBuilder extends HetiFileSystemBuilder {
  Future<HetiFileSystem> getFileSystem() {
    return DomJSHetiFileSystem.getFileSystem();
  }

  Future<int> requestQuota() {
    Completer<int> ret = new Completer();
//    js.context["webkitStorageInfo"].callMethod("requestQuota", [
//      1,

    html.window.navigator.persistentStorage.requestQuota(5 * 1024 * 1024, (a) {
      ret.complete(a);
    }, (b) {
      ret.completeError(b);
    });
    return ret.future;
  }
}

/*
class DomHetiFileSystem extends HetiFileSystem {
  html.FileSystem _fileSystem = null;
  static Future<HetiFileSystem> getFileSystem() {
    Completer<HetiFileSystem> ret = new Completer();
    html.window.requestFileSystem(100 * 1024 * 1024, persistent: true).then((html.FileSystem fileSystem) {
      ret.complete(new DomHetiFileSystem._create(fileSystem));
    }).catchError((e) {
      ret.completeError(e);
    });
    return ret.future;
  }

  DomHetiFileSystem._create(html.FileSystem fileSystem) {
    this._fileSystem = fileSystem;
  }

  HetiDirectory get root {
    html.DirectoryEntry e = _fileSystem.root;
    return new DomHetiDirectory._create(e);
  }
}
*/
