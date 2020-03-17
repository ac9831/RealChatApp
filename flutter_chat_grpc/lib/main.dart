import 'package:flutter/material.dart';

import 'api/chat_service.dart';

import 'blocs/application_bloc.dart';
import 'blocs/bloc_provider.dart';
import 'blocs/message_events.dart';

import 'pages/home.dart';

import 'theme.dart';

/// main is entry point of Flutter application
void main() {
  return runApp(BlocProvider<ApplicationBloc>(
    bloc: ApplicationBloc(),
    child: App(),
  ));
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  ApplicationBloc _appBloc;

  ChatService _service;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit == false) {
      _appBloc = BlocProvider.of<ApplicationBloc>(context);

      _service = ChatService(
          onMessageSent: _onMessageSent,
          onMessageSendFailed: _onMessageSendFailed,
          onMessageReceived: _onMessageReceived,
          onMessageReceiveFailed: _onMessageReceiveFailed);
      _service.start();

      _listenMessagesToSend();

      if (mounted) {
        setState(() {
          _isInit = true;
        });
      }
    }
  }

  void _listenMessagesToSend() async {
    await for (var event in _appBloc.outMessageSend) {
      _service.send(event.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendlychat',
      theme: isIOS(context) ? kIOSTheme : kDefaultTheme,
      home: HomePage(),
    );
  }

  @override
  void dispose() {
    _service.shutdown();
    _service = null;

    super.dispose();
  }

  void _onMessageSent(MessageSentEvent event) {
    debugPrint('Message "${event.id}" sent to the server');
    _appBloc.inMessageSent.add(event);
  }

  void _onMessageSendFailed(MessageSendFailedEvent event) {
    debugPrint(
        'Failed to send message "${event.id}" to the server: ${event.error}');
    _appBloc.inMessageSendFailed.add(event);
  }

  void _onMessageReceived(MessageReceivedEvent event) {
    debugPrint('Message received from the server: ${event.text}');
    _appBloc.inMessageReceived.add(event);
  }

  void _onMessageReceiveFailed(MessageReceiveFailedEvent event) {
    debugPrint('Failed to receive messages from the server: ${event.error}');
  }
}
