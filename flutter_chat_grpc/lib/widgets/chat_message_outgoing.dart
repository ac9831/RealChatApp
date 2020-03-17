import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import '../models/message_outgoing.dart';
import '../theme.dart';

import 'chat_message.dart';

const String _name = "Me";

class ChatMessageOutgoing extends StatelessWidget implements ChatMessage {
  final MessageOutgoing message;

  final AnimationController animationController;

  ChatMessageOutgoing({this.message, this.animationController})
      : super(key: Key(message.id));

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: _getMessageContent(context),
            ),
            Container(
              child: Icon(message.status == MessageOutgoingStatus.SENT
                  ? Icons.done
                  : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMessageContent(BuildContext context) {
    var content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_name, style: Theme.of(context).textTheme.subhead),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(message.text),
        ),
      ],
    );

    if (message.status != MessageOutgoingStatus.SENT) {
      return Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHightlightColor,
        child: content,
      );
    }

    return content;
  }
}
