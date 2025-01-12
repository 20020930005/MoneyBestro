import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/collections.dart';

class HiveService {
  static late Box<Collection> collectionBox;

  /// Initialize the Hive box
  static Future<void> initialize() async {
    collectionBox = await Hive.openBox<Collection>('collections');
  }

  /// Load collections safely with null checks
  static List<Collection> loadCollections() {
    try {
      return collectionBox.values.whereType<Collection>().toList();
    } catch (e) {
      print('Error loading collections: $e');
      return [];
    }
  }
}
