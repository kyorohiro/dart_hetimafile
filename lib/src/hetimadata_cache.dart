library hetimafile.cache;

import 'dart:async' as async;
import 'dart:core';
import 'package:hetimacore/hetimacore.dart';
import 'hetimafile_base.dart';

class CashInfo {
  int index = 0;
  int length = 0;
  HetimaDataMemory dataBuffer = null;
  CashInfo(int index, int length) {
    this.index = index;
    this.length = length;
    this.dataBuffer = new HetimaDataMemory();
  }
}

class CashInfoManager extends HetimaData {
  List<CashInfo> _cashInfoList = [];
  HetimaData _cashData = null;
  int cashSize = 1024;
  int cashNum = 3;

  bool get writable => true;
  bool get readable => true;
  int cashLength = 0;

  CashInfoManager(HetimaData cashData, {cacheSize: 1024, cacheNum: 3}) {
    this._cashInfoList = [];
    this._cashData = cashData;
    this.cashSize = cashSize;
    this.cashNum = cashNum;
  }

  async.Future<int> getLength() {
    async.Completer<int> com = new async.Completer();
    _cashData.getLength().then((int len) {
      if (cashLength > len) {
        com.complete(cashLength);
      }
    }).catchError(com.completeError);
    return com.future;
  }

  async.Future<CashInfo> getCashInfo(int startA) {
    async.Completer<CashInfo> com = new async.Completer();

    //
    for (CashInfo c in _cashInfoList) {
      if (c.index <= startA && startA <= (c.index + c.length)) {
        _cashInfoList.remove(c);
        _cashInfoList.add(c);
        com.complete(c);
        return com.future;
      }
    }

    // not found
    if (_cashInfoList.length >= 3) {
      _cashInfoList.removeAt(0);
    }
    {
      _cashData.read(startA, cashSize).then((ReadResult r) {
        CashInfo ret = new CashInfo(startA - startA % cashSize, cashSize);
        _cashInfoList.add(ret);
        return ret.dataBuffer.write(r.buffer, 0).then((WriteResult r) {
          com.complete(ret);
        });
      }).catchError((e) {
        com.completeError(e);
      });

      return com.future;
    }
  }

  async.Future<WriteResult> write(List<int> buffer, int start) {
    return getCashInfo(start).then((CashInfo ret) {
      int l = start + buffer.length;
      if (cashLength < l) {
        cashLength = l;
      }
      return ret.dataBuffer.write(buffer, start - ret.index);
    });
  }

  async.Future<ReadResult> read(int start, int end) {
    return getCashInfo(start).then((CashInfo ret) {
      return ret.dataBuffer.read(start - ret.index, end - start);
    });
  }

  void beToReadOnly() {}
}

class HetimaDataCache extends HetimaData {
  bool get writable => true;
  bool get readable => true;

  HetiDirectory _cashDirectory = null;
  HetimaData _cashData = null;
  String _id = "";
  String get id => _id;

  CashInfoManager _manager = null;
  int cacheSize = 1024;
  int cacheNum = 3;
  HetimaDataCache(String id, HetiDirectory cashDirectory, {cacheSize: 1024, cacheNum: 3}) {
    this._cashDirectory = cashDirectory;
    this._id = id;
    this._manager = null;
    this.cacheSize = cacheSize;
    this.cacheNum = cacheNum;
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
      _manager = new CashInfoManager(data, cacheSize: cacheSize, cacheNum: cacheNum);
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
    return _manager.write(buffer, start);
  }

  async.Future<ReadResult> read(int start, int end) {
    return _manager.read(start, end);
  }

  void beToReadOnly() {
    if (_cashData == null) {
      init().then((_) {
        return _cashData.beToReadOnly();
      }).catchError((e) {
        ;
      });
    } else {
      _cashData.beToReadOnly();
    }
  }
}
