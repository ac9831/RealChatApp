import 'package:flutter/material.dart';

class Message {
  final String id;
  final String text;

  Message({String id, @required String text})
      : this.id = id ?? UniqueKey().toString(),
        this.text = text;
}
