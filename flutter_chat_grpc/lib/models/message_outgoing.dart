import 'package:meta/meta.dart';

import 'message.dart';

enum MessageOutgoingStatus { NEW, SENT, FAILED }

class MessageOutgoing extends Message {
  MessageOutgoingStatus status;

  MessageOutgoing(
      {String id,
      @required String text,
      MessageOutgoingStatus status = MessageOutgoingStatus.NEW})
      : this.status = status,
        super(id: id, text: text);

  MessageOutgoing.copy(MessageOutgoing original)
      : this.status = original.status,
        super(id: original.id, text: original.text);
}
