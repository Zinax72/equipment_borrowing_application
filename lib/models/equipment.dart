import 'package:cloud_firestore/cloud_firestore.dart';

// Data model representing a single equipment item from Firestore.
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

  // Returns true if there is at least 1 unit in stock.
  bool get isAvailable => available > 0;

  // Converts a Firestore document into an Equipment object.
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
