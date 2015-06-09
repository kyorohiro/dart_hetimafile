import 'dart:core';
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async' as async;
import 'package:hetimacore/hetimacore.dart';
import 'package:hetimacore/hetimacore_cl.dart';
import 'package:hetimafile/hetimafile.dart';
import 'package:hetimafile/hetimafile_cl.dart';

void main() {
  print("test");
  DomJSHetiFileSystemBuilder builder = new DomJSHetiFileSystemBuilder();
  builder.requestQuota().then((int v) {
    print("---a---${v}");
    return builder.getFileSystem().then((HetiFileSystem fs) {

    });
  }).catchError((e) {
    print("---e---${e}");
  });
  /*

   */
}
