import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> getFirebaseInstallationId() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("Token: $token");
}
// Simple in-memory notification history
List<String> notificationHistory = [];

// Background message handler
Future<void> _messageHandler(RemoteMessage message) async {
  print('background message: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  // Android-specific initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("Notification action tapped: ${response.actionId}");
      // Handle button actions here
    },
  );

  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;
  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;

  @override
  void initState() {
    super.initState();
    // Request permission for iOS
    messaging = FirebaseMessaging.instance;
    messaging
        .requestPermission(
          alert: true,
          badge: true,
          provisional: false,
          sound: true,
        )
        .then((NotificationSettings settings) {
          print("User granted permission: ${settings.authorizationStatus}");
        });
    // Get the FCM token
    messaging.getToken().then((String? token) {
      print("FCM Token: $token");
    });
    messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("Message received: ${event.notification?.body}");

      setState(() {
        notificationText = event.notification?.body;
        if (notificationText != null) {
          notificationHistory.add(notificationText!);
        }
      });

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction('REPLY', 'Reply'),
              AndroidNotificationAction('MARK_READ', 'Mark as Read'),
            ],
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        event.notification?.title,
        event.notification?.body,
        platformChannelSpecifics,
        payload: 'notification_payload',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Notification clicked from background!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Messaging Tutorial"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text("Notification History"),
                        content: Container(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: notificationHistory.length,
                            itemBuilder:
                                (context, index) =>
                                    Text("- ${notificationHistory[index]}"),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Close"),
                          ),
                        ],
                      ),
                );
              },
              child: Text("Show Notification History"),
            ),
          ],
        ),
      ),
    );
  }
}
