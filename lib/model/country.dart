import 'package:flutter/material.dart';
import 'package:career_map/constant.dart';

class Country {
  final String name; // Mandatory country name
  final String path;

  // Dark-grey by default
  Color color = standard; // Will be used to color the country on the map based on job compatibility

  String medianSalary = 'N/A'; // Will be used to display the median salary of the country
  String salaryPeriod = 'N/A'; // Will be used to display the salary period of the country
  String currency = 'N/A'; // Will be used to display the currency of the salary displayed

  String dataConfidence = 'low'; // Indicates how much confidence we have in the data

  Country({required this.name, required this.path, medianSalary, salaryPeriod, currency}) {
    _calculateColor();
  }

  void setMedianSalary(String ms) {
    medianSalary = ms;
    _calculateColor();
  }
  void setSalaryPeriod(String sp) {
    salaryPeriod = sp;
    _calculateColor();
  }
  void setCurrency(String c) {
    currency = c;
    _calculateColor();
  }

  void _calculateColor() {
    if (medianSalary == 'N/A') {
      color = unknown;
    } else {
      double salary = double.parse(medianSalary);
      if (salary < 20000) {
        color = red;
      } else if (salary < 60000) {
        color = yellow;
      } else if (salary < 80000) {
        color = green;
      } else {
        color = standard;
      }
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