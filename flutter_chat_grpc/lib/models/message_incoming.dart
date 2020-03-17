import 'package:meta/meta.dart';

import 'message.dart';

class MessageIncoming extends Message {
  MessageIncoming({String id, @required String text})
      : super(id: id, text: text);

  MessageIncoming.copy(MessageIncoming original)
      : super(id: original.id, text: original.text);
}
