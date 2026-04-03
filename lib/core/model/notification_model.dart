import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class NotificationModel {
  final String id;
  final String message;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.message,
    required this.timestamp,
  });

  factory NotificationModel.createNew(String message) {
    return NotificationModel(
      id: const Uuid().v4(),
      message: message,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
