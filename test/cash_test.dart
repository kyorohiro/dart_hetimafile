import 'dart:core';
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async';
import 'package:hetimacore/hetimacore.dart';
import 'package:hetimacore/hetimacore_cl.dart';
import 'package:hetimafile/hetimafile.dart';
import 'package:hetimafile/hetimafile_cl.dart';
import 'package:chrome/chrome_app.dart' as chrome;

void main() {
  print("test");
  DomJSHetiFileSystemBuilder builder = new DomJSHetiFileSystemBuilder();
  builder.requestQuota().then((int v) {
    print("---a---${v}");
    saveFile();
  }).catchError((e) {
    print("---e---${e}");
  });
}

Future saveFileA([int begin = 0, int end = null, String name = "rawdata"]) {
  Completer c = new Completer();
  chrome.fileSystem.chooseEntry(new chrome.ChooseEntryOptions(type: chrome.ChooseEntryType.SAVE_FILE, suggestedName: name)).then((chrome.ChooseEntryResult chooseEntryResult) {
    chrome.fileSystem.getWritableEntry(chooseEntryResult.entry).then((chrome.ChromeFileEntry copyTo) {
      ///
      DomJSHetiFile hetiCopyTo = new DomJSHetiFile.create(copyTo.jsProxy);
      hetiCopyTo.getHetimaFile().then((HetimaData data) {
        return data.write(convert.UTF8.encode("abc"),3).then((WriteResult r) {
          return data.write(convert.UTF8.encode("def"), 0).then((WriteResult r) {
            return data.write(convert.UTF8.encode("ghi"), 6);      
          });
        }).then((_){
          print("#######-----------------------[A]");
        });
      });
    }).catchError(c.completeError);
  }).catchError(c.completeError);

  return c.future;
}

Future saveFile([int begin = 0, int end = null, String name = "rawdata"]) {
  Completer c = new Completer();
  chrome.fileSystem.chooseEntry(new chrome.ChooseEntryOptions(type: chrome.ChooseEntryType.SAVE_FILE, suggestedName: name)).then((chrome.ChooseEntryResult chooseEntryResult) {
    chrome.fileSystem.getWritableEntry(chooseEntryResult.entry).then((chrome.ChromeFileEntry copyTo) {
      ///
      int length = 1 * 1000 * 1000 * 1000;
      {
        //
        if (end == null) {
          end = length;
        }
        num d = 32 * 1024 * 1024;
        num b = begin;
        num e = b + d;
        DomJSHetiFile hetiCopyTo = new DomJSHetiFile.create(copyTo.jsProxy);
        hetiCopyTo.getHetimaFile().then((HetimaData data) {
          a() {
            //copyFrom.read(b, e - b).then((ReadResult readResult) {
            //print("${b} ${e} ${readResult.buffer.length}");

            data.write(new List.filled(d, 0xff), b - begin).then((WriteResult w) {
              b = e;
              e = b + d;
              if (e > end) {
                e = end;
              }
              if (b < end) {
                return a();
              } else {
                c.complete({});
              }
              /// }).catchError(c.completeError);
            }).catchError((e) {
              return new Future.delayed(new Duration(seconds:1)).then((_){
                return a();
              });
            });
          }
          a();
        }).catchError(c.completeError);

        // copyFrom.getLength().then((int length) {
      }
      ///
    }).catchError(c.completeError);
  }).catchError(c.completeError);

  return c.future;
}
