import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String id;
  final String name;
  final String category;
  final int available;
  final String description;
  final String imageUrl;

  const Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.available,
    required this.description,
    required this.imageUrl,
  });

  bool get isAvailable => available > 0;

  factory Equipment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Equipment(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      available: (data['available'] as num?)?.toInt() ?? 0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
