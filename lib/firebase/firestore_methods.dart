import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to read JSON data from a file
  Future<List<Map<String, dynamic>>> _readJsonFromFile(String filePath) async {
    try {
      // Load the JSON file from the assets
      final String jsonString = await rootBundle.loadString(filePath);
      // Decode the JSON string into a List of Maps
      final List<dynamic> jsonData = jsonDecode(jsonString);
      // Convert the List of dynamic to List<Map<String, dynamic>>
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error reading JSON file: $e');
      return [];
    }
  }

  // Method to write JSON data to Firestore
  Future<void> writeJsonToFirestore(String filePath, String nameOfCollection, String namingAttribute) async {
    // Read JSON data from the file
    final List<Map<String, dynamic>> jsonData = await _readJsonFromFile(filePath);

    if (jsonData.isEmpty) {
      print('No data to write.');
      return;
    }

    // Reference to the Firestore collection
    final CollectionReference countriesCollection = _firestore.collection(nameOfCollection);

    // Write each country's data to Firestore
    for (final data in jsonData) {
      try {
        await countriesCollection.doc(data[namingAttribute]).set(data);
        await countriesCollection.doc(data[namingAttribute]).update({'last-modified': DateTime.now().toUtc()});
        print('Data written for ${data[namingAttribute]}');
      } catch (e) {
        print('Error writing data for ${data[namingAttribute]}: $e');
      }
    }

    print('All data written to Firestore successfully!');
  }

  // Optional: Method to read data from Firestore (for verification)
  Future<void> readDataFromFirestore(String nameOfCollection) async {
    final CollectionReference countriesCollection = _firestore.collection(nameOfCollection);

    try {
      final QuerySnapshot snapshot = await countriesCollection.get();
      for (final doc in snapshot.docs) {
        print('${doc.id} => ${doc.data()}');
      }
    } catch (e) {
      print('Error reading data: $e');
    }
  }
}