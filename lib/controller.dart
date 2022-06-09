import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

toast(msg) {
  Fluttertoast.showToast(
      msg: msg.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

setPref(key, cont) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, cont);
}

getPref(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? res = prefs.getString(key);
  print(res);
  return res;
}
