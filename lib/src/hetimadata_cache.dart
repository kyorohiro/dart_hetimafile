library hetimafile.cache;

import 'dart:async' as async;
import 'dart:core';
import 'package:hetimacore/hetimacore.dart';
import 'hetimafile_base.dart';

class CashInfo {
  int index = 0;
  int length = 0;
  ArrayBuilder dataBuffer = null;
  CashInfo(int index, int length) {
    this.index = index;
    this.length = length;
    this.dataBuffer = new ArrayBuilder();
  }
}

class CashInfoManager {
  List<CashInfo> _cashInfoList = [];
  HetimaData _cashData = null;
  int cashSize = 1024;
  int cashNum = 3;

  CashInfoManager(HetimaData cashData, {cashSize: 1024, cashNum: 3}) {
    this._cashInfoList = [];
    this._cashData = cashData;
    this.cashSize = cashSize;
    this.cashNum = cashNum;
  }

  CashInfo getCashInfo(int startA) {
    //
    for (CashInfo c in _cashInfoList) {
      if (c.index <= startA && startA <= (c.index + c.length)) {
        _cashInfoList.remove(c);
        _cashInfoList.add(c);
        return c;
      }
    }
    // not found
    if (_cashInfoList.length < 3) {
      _cashInfoList.add(new CashInfo(startA - startA % cashSize, cashSize));
    } else {
      _cashInfoList.removeAt(0);
    }
  }
  async.Future<WriteResult> write(List<int> buffer, int start) {
    int startA = start;
    int lenA = 0;
    while (true) {
      startA = startA + lenA;
      lenA = cashSize - (startA + cashSize) % 10;
      if (buffer.length > startA) {
        break;
      }
      {}
    }
  }

  List<int> read(int) {
    ;
  }

  void flush() {}
}

class HetimaDataCache extends HetimaData {
  bool get writable => true;
  bool get readable => true;

  HetiDirectory _cashDirectory = null;
  HetimaData _cashData = null;
  String _id = "";
  String get id => _id;

  HetimaDataCache(String id, HetiDirectory cashDirectory, {cashSize: 1024, cashNum: 3}) {
    this._cashDirectory = cashDirectory;
    this._id = id;
  }

  async.Future<dynamic> init() {
    if (_cashData != null) {
      async.Completer<dynamic> comp = new async.Completer();
      comp.complete(_cashData);
      return comp.future;
    }

    async.Completer<dynamic> comp = new async.Completer();
    _cashDirectory.createFile(_id).then((HetiFile f) {
      return f.getHetimaFile();
    }).then((HetimaData data) {
      _cashData = data;
      comp.complete(data);
    }).catchError((e) {
      comp.completeError(e);
    });
    return comp.future;
  }

  async.Future<int> getLength() {
    if (_cashData == null) {
      return init().then((_) {
        return _cashData.getLength();
      });
    } else {
      return _cashData.getLength();
    }
  }
  async.Future<WriteResult> write(Object buffer, int start) {
    async.Completer<WriteResult> comp = new async.Completer();
    if (buffer is List<int>) {
      if (_cashData == null) {
        return init().then((_) {
          return _cashData.write(buffer, start);
        });
      } else {
        return _cashData.write(buffer, start);
      }
    } else {
      throw new UnsupportedError("");
    }
    return comp.future;
  }

  async.Future<ReadResult> read(int start, int end) {
    if (_cashData == null) {
      return init().then((_) {
        return _cashData.read(start, end);
      });
    } else {
      return _cashData.read(start, end);
    }
  }

  void beToReadOnly() {
    if (_cashData == null) {
      init().then((_) {
        return _cashData.beToReadOnly();
      }).catchError((e){;});
    } else {
      _cashData.beToReadOnly();
    }
  }
}
