import 'package:cloud_firestore/cloud_firestore.dart';

class Mood {
  String id;
  final String? description;
  final int? moodValue;
  final DateTime? entryDate;

  Mood({
    required this.description,
    required this.moodValue,
    required this.entryDate,
    this.id = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'moodValue': moodValue,
        'entryDate': entryDate,
      };
  static Mood fromJson(Map<String, dynamic> json) => Mood(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      moodValue: json['moodValue'],
      entryDate: (json['entryDate'] as Timestamp).toDate());
}
