import 'dart:convert';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future sendCustomNotificationByTopic(String title, String description, String targetUsersTopic) async {
    final String body = AppService.getNormalText(description);
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Config.firebaseServerToken}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title, 'sound': 'default'},
          'priority': 'normal',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'notification_type': 'custom',
            'description': description
          },
          'to': "/topics/$targetUsersTopic",
        },
      ),
    );
  }
}
