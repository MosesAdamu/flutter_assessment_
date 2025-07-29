import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String mediaUrl;
  final bool isImage;
  final double lat;
  final double lng;
  final DateTime timestamp;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.mediaUrl,
    required this.isImage,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      mediaUrl: data['media_url'] ?? '',
      isImage: data['is_image'] ?? true,
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'media_url': mediaUrl,
      'is_image': isImage,
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp,
    };
  }
}
