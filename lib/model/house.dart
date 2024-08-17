import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String neighID;

  House({
    required this.id,
    required this.neighID,
  });

  // Convert a House into a Map
  Map<String, dynamic> toMap() {
    return {
      'neighID': neighID,
    };
  }

  // Create a House from a Map
  factory House.fromMap(String id, Map<String, dynamic> map) {
    return House(
      id: id,
      neighID: map['neighID'] ?? '',
    );
  }
}


class HouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _houseCollection =>
      _firestore.collection('houses');

  // Create or Update House
  Future<bool> setHouse(House house) async {
    try {
      await _houseCollection.doc(house.id).set(house.toMap());
      return true;
    } catch (e) {
      print('Error setting house: $e');
      return false;
    }
  }

  // Read House
  Future<House?> getHouse(String houseId) async {
    try {
      DocumentSnapshot doc = await _houseCollection.doc(houseId).get();
      if (doc.exists) {
        return House.fromMap(houseId, doc.data() as Map<String, dynamic>);
      } else {
        print('House not found');
        return null;
      }
    } catch (e) {
      print('Error getting house: $e');
      return null;
    }
  }

  // Update House (example of updating specific fields)
  Future<void> updateHouse(House house) async {
    try {
      await _houseCollection.doc(house.id).update(house.toMap());
    } catch (e) {
      print('Error updating house: $e');
    }
  }

  // Delete House
  Future<void> deleteHouse(String houseId) async {
    try {
      await _houseCollection.doc(houseId).delete();
    } catch (e) {
      print('Error deleting house: $e');
    }
  }

  // Check if house exists
  Future<bool> houseExists(String houseId) async {
    try {
      DocumentSnapshot doc = await _houseCollection.doc(houseId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if house exists: $e');
      return false;
    }
  }
}
