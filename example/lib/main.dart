import 'package:flutter/material.dart';

import 'samples/avatar.dart';
import 'samples/basic.dart';
import 'samples/media.dart';
import 'samples/quick_replies_sample.dart';
import 'samples/typing_users_sample.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dash Chat Demo',
      supportedLocales: [Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Chat Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => push(Basic()),
              child: const Text('Basic'),
            ),
            ElevatedButton(
              onPressed: () => push(Media()),
              child: const Text('Chat media'),
            ),
            ElevatedButton(
              onPressed: () => push(AvatarSample()),
              child: const Text('All user possibilities'),
            ),
            ElevatedButton(
              onPressed: () => push(QuickRepliesSample()),
              child: const Text('Quick replies'),
            ),
            ElevatedButton(
              onPressed: () => push(TypingUsersSample()),
              child: const Text('Typing users'),
            ),
          ],
        ),
      ),
    );
  }

  void push(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }
}

//         messageOptions: const MessageOptions(showTime: true),
//         messageListOptions: MessageListOptions(
//           loadEarlierBuilder: Center(
//             child: ElevatedButton(
//               onPressed: () {},
//               child: const Text('toto'),
//             ),
//           ),
//           separatorFrequency: SeparatorFrequency.hours
//         ),
//       ),