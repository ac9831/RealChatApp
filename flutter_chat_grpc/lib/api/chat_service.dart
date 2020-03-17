import 'dart:isolate';
import 'dart:io';
import 'package:grpc/grpc.dart';

import '../blocs/message_events.dart';
import '../models/message_outgoing.dart';

import 'v1/chat.pbgrpc.dart' as grpc;
import 'v1/google/protobuf/empty.pb.dart';
import 'v1/google/protobuf/wrappers.pb.dart';

const serverIP = '10.0.2.2';
const serverPort = 8080;

class ChatService {
  Isolate _isolateSending;
  Isolate _isolateReceiving;

  SendPort _portSending;
  ReceivePort _portSendStatus;

  ReceivePort _portReceiving;

  final void Function(MessageSentEvent event) onMessageSent;
  final void Function(MessageSendFailedEvent event) onMessageSendFailed;
  final void Function(MessageReceivedEvent event) onMessageReceived;
  final void Function(MessageReceiveFailedEvent event) onMessageReceiveFailed;

  ChatService(
      {this.onMessageSent,
      this.onMessageSendFailed,
      this.onMessageReceived,
      this.onMessageReceiveFailed})
      : _portSendStatus = ReceivePort(),
        _portReceiving = ReceivePort();

  void start() {
    _startSending();
    _startReceiving();
  }

  void _startSending() async {
    _isolateSending =
        await Isolate.spawn(_sendingIsolate, _portSendStatus.sendPort);

    await for (var event in _portSendStatus) {
      if (event is SendPort) {
        _portSending = event;
      } else if (event is MessageSentEvent) {
        if (onMessageSent != null) {
          onMessageSent(event);
        }
      } else if (event is MessageSendFailedEvent) {
        if (onMessageSendFailed != null) {
          onMessageSendFailed(event);
        }
      } else {
        assert(false, 'Unknown event type ${event.runtimeType}');
      }
    }
  }

  static void _sendingIsolate(SendPort portSendStatus) async {
    ReceivePort portSendMessages = ReceivePort();

    portSendStatus.send(portSendMessages.sendPort);

    ClientChannel client;

    await for (MessageOutgoing message in portSendMessages) {
      var sent = false;
      do {
        client ??= ClientChannel(
          serverIP,
          port: serverPort,
          options: ChannelOptions(
            credentials: ChannelCredentials.insecure(),
            idleTimeout: Duration(seconds: 1),
          ),
        );

        try {
          var request = StringValue.create();
          request.value = message.text;
          await grpc.ChatServiceClient(client).send(request);
          portSendStatus.send(MessageSentEvent(id: message.id));
          sent = true;
        } catch (e) {
          portSendStatus.send(
              MessageSendFailedEvent(id: message.id, error: e.toString()));
          client.shutdown();
          client = null;
        }

        if (!sent) {
          sleep(Duration(seconds: 5));
        }
      } while (!sent);
    }
  }

  void _startReceiving() async {
    _isolateReceiving =
        await Isolate.spawn(_receivingIsolate, _portReceiving.sendPort);

    await for (var event in _portReceiving) {
      if (event is MessageReceivedEvent) {
        if (onMessageReceived != null) {
          onMessageReceived(event);
        }
      } else if (event is MessageReceiveFailedEvent) {
        if (onMessageReceiveFailed != null) {
          onMessageReceiveFailed(event);
        }
      }
    }
  }

  static void _receivingIsolate(SendPort portReceive) async {
    ClientChannel client;

    do {
      client ??= ClientChannel(
        serverIP,
        port: serverPort,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 1),
        ),
      );

      var stream = grpc.ChatServiceClient(client).subscribe(Empty.create());

      try {
        await for (var message in stream) {
          portReceive.send(MessageReceivedEvent(text: message.text));
        }
      } catch (e) {
        portReceive.send(MessageReceiveFailedEvent(error: e.toString()));
        client.shutdown();
        client = null;
      }

      sleep(Duration(seconds: 5));
    } while (true);
  }

  void shutdown() {
    _isolateSending?.kill(priority: Isolate.immediate);
    _isolateSending = null;
    _portSendStatus?.close();
    _portSendStatus = null;

    _isolateReceiving?.kill(priority: Isolate.immediate);
    _isolateReceiving = null;
    _portReceiving?.close();
    _portReceiving = null;
  }

  void send(MessageOutgoing message) {
    assert(_portSending != null, "Port to send message can't be null");
    _portSending.send(message);
  }
}
