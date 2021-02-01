import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  final firebaseMessaging = FirebaseMessaging();
  final controllerTopic = TextEditingController();
  bool isSubcribed = false;
  String token = '';
  static String dataNama = '';
  static String dataAge = '';

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessage : $message');
    if (message.containsKey('data')) {
      String name = '';
      String age = ' ';
      if (Platform.isIOS) {
        name = message['name'];
        age = message['age'];
      } else if (Platform.isAndroid) {
        var data = message['data'];
        name = data['name'];
        age = data['age'];
      }
      dataNama = name;
      dataAge = age;
    }
    return null;
  }

  @override
  void initState() {
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          debugPrint('onMessage: $message');
          getDataFcm(message);
        },
        onBackgroundMessage: onBackgroundMessage,
        onResume: (Map<String, dynamic> message) async {
          debugPrint('onResume : $message');
          getDataFcm(message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          debugPrint("onLaunce : $message");
          getDataFcm(message);
        });
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      debugPrint('Settings registered : $settings');
    });
    firebaseMessaging.getToken().then((token) => setState(() {
          this.token = token;
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('token : $token');
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Flutter FCM'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'TOKEN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(token),
            Divider(
              thickness: 1,
            ),
            Text(
              'TOPIC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: controllerTopic,
              enabled: !isSubcribed,
              decoration: InputDecoration(
                hintText: 'Enter a topic',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    child: Text('Subscribe'),
                    onPressed: isSubcribed
                        ? null
                        : () {
                            String topic = controllerTopic.text;
                            if (topic.isEmpty) {
                              scaffoldState.currentState.showSnackBar(SnackBar(
                                content: Text('Topic Invalid'),
                              ));
                              return;
                            }
                            firebaseMessaging.subscribeToTopic(topic);
                            setState(() {
                              isSubcribed = true;
                            });
                          },
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('Unsubcribe'),
                    onPressed: !isSubcribed
                        ? null
                        : () {
                            String topic = controllerTopic.text;
                            firebaseMessaging.unsubscribeFromTopic(topic);
                            setState(() {
                              isSubcribed = false;
                            });
                          },
                  ),
                )
              ],
            ),
            Divider(
              thickness: 1,
            ),
            Text(
              'Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildWidgetTextDataFcm()
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetTextDataFcm() {
    if (dataNama == null ||
        dataAge.isEmpty ||
        dataAge == null ||
        dataNama.isEmpty) {
      return Text('Your data FCM is here');
    } else {
      return Text('Name : $dataNama & Age: $dataAge');
    }
  }

  void getDataFcm(Map<String, dynamic> message) {
    String name = '';
    String age = '';
    if (Platform.isIOS) {
      name = message['name'];
      age = message['age'];
    } else if (Platform.isAndroid) {
      var data = message['data'];
      name = data['name'];
      age = data['age'];
    }
    if (name.isNotEmpty && age.isNotEmpty) {
      setState(() {
        dataNama = name;
        dataAge = age;
      });
    }
    debugPrint('getDataFcm : name : $name & age: $age');
  }
}
