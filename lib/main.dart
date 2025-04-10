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

      String? notificationType = event.data['notificationType'] ?? 'regular';
      String title = event.notification?.title ?? 'New Notification';
      String body = event.notification?.body ?? 'You have a new message.';

      setState(() {
        notificationText = body;
        notificationHistory.add(body);
      });

      AndroidNotificationDetails androidDetails;

      if (notificationType == 'important') {
        androidDetails = AndroidNotificationDetails(
          'important_channel',
          'Important Notifications',
          channelDescription: 'This channel is for important notifications',
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFFE53935),
          playSound: true,
          visibility: NotificationVisibility.public,
          enableLights: true,
          enableVibration: true
        );
      } else {
        androidDetails = AndroidNotificationDetails(
          'regular_channel',
          'Regular Notifications',
          channelDescription: 'This channel is for regular notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority
        );
      }

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(android: androidDetails),
      );
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
