import 'package:flutter/material.dart';
import '../models/message.dart';

abstract class ChatMessage extends Widget {
  Message get message;

  AnimationController get animationController;
}
