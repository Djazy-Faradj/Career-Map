import 'package:flutter/material.dart';

class Country {
  final String name; // Mandatory country name and code
  final String code;

  // Dark-grey by default
  Color color = Color.fromARGB(255, 50, 50, 50); // Will be used to color the country on the map based on job compatibility

  String medianSalary = 'N/A'; // Will be used to display the median salary of the country
  String salaryPeriod = 'N/A'; // Will be used to display the salary period of the country
  String currency = 'N/A'; // Will be used to display the currency of the salary displayed

  String dataConfidence = 'low'; // Indicates how much confidence we have in the data

  Country({required this.name, required this.code, medianSalary, salaryPeriod, currency});

  void setMedianSalary(String ms) {
    medianSalary = ms;
  }
  void setSalaryPeriod(String sp) {
    salaryPeriod = sp;
  }
  void setCurrency(String c) {
    currency = c;
  }

  // Ill use this if I ever want to make a data base to lower API calls, store JSON data of countries with a last updated date
  // factory Country.fromJson(Map<String, dynamic> json) { 
  //   return Country(
  //     name: json['name'],
  //     code: json['code'],
  //   );
  // }
}