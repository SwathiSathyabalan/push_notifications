import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demone/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  //late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
 // late AndroidNotificationChannel channel;
  //late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  //String? selectedNotificationPayload;
  String? mtoken = "";

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState(){
    super.initState();
    notificationServices.requestNotificationPermission();

    notificationServices.firebaseInit();

    notificationServices.getDeviceToken().then((value){

        print('device token');
        print(value);

    });

  //  requestpermission();
    //loadFCM();
//    listenFCM();
//    getToken();
  //   FirebaseMessaging.instance.unsubscribeFromTopic("Jobs");
  }

  /*initInfo(){
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationsSettings = InitializationSettings(android: androidInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {

        }
        else {

        }
      } catch (e) {

      }
      return;
    } );
  }*/

  void saveToken(String token) async{
    await FirebaseFirestore.instance.collection("UserToken").doc("User32").set(
        {
           'token': token,
        });

  }

  void sendPushMessage() async{
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAASpBac4g:APA91bGUF2n3yZaJ8VbwUR6vleYjcreotcdSL6Uj3PQmnkc3WrOi0rpHJ9szztLJ62Kt9eZjtCE18SM2eu9eDqWgRazccB4_vN5r3olL3oP3jeIo-CEwGrMBcU5W3lH7vsJqbMAeSJBo',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Test',
              'title': 'Test Title',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": "",
          },
        ),
      );
      
    } catch (e) {
      print("error push notification $e");
    
    
    }
  }

  void getToken() async{
    await FirebaseMessaging.instance.getToken().then(
            (token) {
              setState(() {
                mtoken = token;
                print("My token is $mtoken");
              });
              saveToken(token!);
            }
    );
  }




  void requestpermission() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       title: const Text('Flutter Notification'),
     ),
      body: Center(
        child: TextButton(onPressed: (){
          notificationServices.getDeviceToken().then((value) async{
            var data ={
              "to": value.toString(),
              'priority': 'high',
              'notification': {
                'body': 'Test',
                'title': 'Test Title',
              }
            };

            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers:{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key=AAAASpBac4g:APA91bGUF2n3yZaJ8VbwUR6vleYjcreotcdSL6Uj3PQmnkc3WrOi0rpHJ9szztLJ62Kt9eZjtCE18SM2eu9eDqWgRazccB4_vN5r3olL3oP3jeIo-CEwGrMBcU5W3lH7vsJqbMAeSJBo',
          } );
          });
        },
            child: Text('Send Notification')),
      ),
    );
  }


}
