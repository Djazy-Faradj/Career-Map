import 'package:career_map/firebase/firestore_methods.dart';
import 'package:flutter/material.dart';
import 'package:career_map/constant.dart';

class Country {
  final String name; // Mandatory country name
  final String path;

  // Dark-grey by default
  Color color = standard; // Will be used to color the country on the map based on job compatibility

  double medianSalary = 0.0; // Will be used to display the median salary of the country
  double convertedMedianSalary = 0.0; // Will be used to display the median salary of the country in USD
  String salaryPeriod = 'N/A'; // Will be used to display the salary period of the country
  String currency = 'N/A'; // Will be used to display the currency of the salary displayed

  String incomeGroup = 'N/A'; // Upper - Middle - Lower ?
  double ppi = 0.0; // Purchasing Power Index
  double unemploymentRate = 0.0; // Unemployment rate

  String dataConfidence = 'low'; // Indicates how much confidence we have in the data

  Country({required this.name, required this.path}) {
    //_calculateColor();
  }

  Future calculateColor() async {
    FirestoreMethods firestoreMethods = FirestoreMethods();
    int point = 0; // Will be used to calculate the color of the country
    
      // Get Income group, PPI, Unemployment rate
    await firestoreMethods.readDocumentFromFirestore('income_group', name).then((value) {
      if (value != null) {
        incomeGroup = value['income_group'];
      }
    });
    await firestoreMethods.readDocumentFromFirestore('ppi', name).then((value) {
      if (value != null) {
        ppi = value['purchasing_power'];
      }
    });
    await firestoreMethods.readDocumentFromFirestore('unemployment', name).then((value) {
      if (value != null) {
        unemploymentRate = value['unemployment'];
      }
    });

    // Convert currency to usd
    if (currency != 'N/A') { // First make sure a currency is in the country
      await firestoreMethods.readDocumentFromFirestore('currencies', currency).then((value) {
        if (value != null) {
          convertedMedianSalary = medianSalary / value['value'];
        }
      });
    }

    // Get gdp of country (in usd)
    //firestoreMethods

    // Compute ratio to determine safety of salary

    // Add main points (Salary, GDP)
      // Salary

    // Add side points (PPI, Income group, Unemployment rate)
      // Income group
    if (incomeGroup == 'Upper middle income' || incomeGroup == 'High income') {
      point += 2;
    } else if (incomeGroup == 'Lower middle income') {
      point += 1;
    }
      // PPI
    if (ppi > 75) 
    {
      point += 2;
    } else if (ppi >= 50) {
      point += 1;
    }
      // Unemployment rate
    if (unemploymentRate < 4) {
      point += 2;
    } else if (unemploymentRate <= 7) {
      point += 1;
    }

    // Pick color based on points (1/2/3 - RED, 4/5/6 - YELLOW, 7/9 - GREEN)
    if (point < 4) {
      color = red;
    } else if (point < 7) {
      color = yellow;
    } else {
      color = green;
    }
  }

  // Ill use this if I ever want to make a data base to lower API calls, store JSON data of countries with a last updated date
  // factory Country.fromJson(Map<String, dynamic> json) { 
  //   return Country(
  //     name: json['name'],
  //     code: json['code'],
  //   );
  // }
}