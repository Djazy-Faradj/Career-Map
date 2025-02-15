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

  // Method to write Currency API JSON data to Firestore from API response
  Future<void> writeCurrencyApiDataToFirestore(
  Future<dynamic> apiDataFuture, 
  String nameOfCollection, 
  String namingAttribute,
) async {
  try {
    // Await the API response
    final dynamic apiData = await apiDataFuture;

    if (apiData is Map<String, dynamic>) {
      // Process as a single JSON object
      final CollectionReference collectionRef = _firestore.collection(nameOfCollection);
      for (var item in apiData.entries) {
        await collectionRef.doc(item.value['code']).set({'value': item.value['value']});
        await collectionRef.doc(item.value['code']).update({'last-modified': DateTime.now().toUtc()});
      }
      print('Data written for ${apiData[namingAttribute]}');
    } else {
      print('Unexpected data format. Expected a JSON object.');
    }
  } catch (e) {
    print('Error processing API data: $e');
  }
}

 // Method to write Job Salary API JSON data to Firestore from API response
  Future<void> createJobSalaryApiDataToFirestore(
    DateTime now, 
    String nameOfCollection, 
    String nameOfDocument
) async {
  try {
        final CollectionReference collectionRef = _firestore.collection(nameOfCollection);
        await collectionRef.doc(nameOfDocument).set({
          'last-modified': now,
        });
  } catch (e) {
    print('Error creating document for: $nameOfDocument');
  }
}

 // Method to write Job Salary API JSON data to Firestore from API response
  Future writeJobSalaryApiDataToFirestore(
    Future<dynamic> apiDataFuture, 
    String nameOfCollection, 
    String namingAttribute,
) async {
  try {
    // Await the API response
    final dynamic apiData = await apiDataFuture;
    String docId = apiData[namingAttribute].toLowerCase().replaceAll(' ', '');
    
    if (apiData != false) {
      final CollectionReference collectionRef = _firestore.collection(nameOfCollection);
      await collectionRef.doc(docId).update({
        '${apiData['location']}': 
          {
            'median_salary': apiData['median_salary'],
            'salary_period': apiData['salary_period'],
            'salary_currency': apiData['salary_currency'],
            'confidence': apiData['confidence'],
          }
        });
      print('Data written for ${docId}');
    } else {
      print('Unexpected data format. Expected a JSON object.');
    }
  } catch (e) {
    print('Error processing API data: $e');
  }
}

 // Method to write JSON data to Firestore
  Future<void> writeTest(String nameOfCollection, String nameOfDocument) async {

    // Reference to the Firestore collection
    final CollectionReference countriesCollection = _firestore.collection(nameOfCollection);

      try {
        await countriesCollection.doc(nameOfDocument).set({'data': 'test'});
        await countriesCollection.doc(nameOfDocument).update({'last-modified': DateTime.now().toUtc()});
        print('Data written for ${nameOfDocument}');
      } catch (e) {
        print('Error writing data for ${nameOfDocument} $e');
      }
    }

  // Method to write JSON data to Firestore
  Future<void> writeJsonFileToFirestore(String filePath, String nameOfCollection, String namingAttribute) async {
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

  Future<bool?> salaryDataIsUpToDate(String jobTitle) async {
    String documentId = jobTitle;
    if (documentId.isNotEmpty) {
        try {
        // Reference to the specific document in the collection
        final DocumentSnapshot documentSnapshot = await _firestore.collection('salary_api').doc(documentId).get();

        // Check if the document exists
        if (documentSnapshot.exists) {
          DateTime lastModified = documentSnapshot.get('last-modified').toDate();
          DateTime lastValidDate = lastModified.add(Duration(days: 180)); // Last valid date is approximately 6 months after last update
          bool isValid = DateTime.now().toUtc().isBefore(lastValidDate);
          return isValid;
        } else {
          return false; // Need to call api
        }
      } catch (e) {
        print('Error reading document $documentId from collection salary_api: $e');
        return false;
      }
    } else {
      print('Document ID is empty');
      return null;
    }
  }

    // Method to read a specific document from a specific collection
  Future<Map<String, dynamic>?> readDocumentFromFirestore(String collectionName, String documentId) async {
    try {
      // Reference to the specific document in the collection
      final DocumentSnapshot documentSnapshot = await _firestore.collection(collectionName).doc(documentId).get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Return the document data as a Map
        return documentSnapshot.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error reading document $documentId from collection $collectionName: $e');
      return null;
    }
  }
}