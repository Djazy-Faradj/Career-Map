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
  double gdp = 0.0; // Gross Domestic Product
  int point = 0; // Will be used to color the country on the map based on job compatibility

  String dataConfidence = 'low'; // Indicates how much confidence we have in the data

  Country({required this.name, required this.path});

  Future calculateColor() async {
    FirestoreMethods firestoreMethods = FirestoreMethods();

      // Get Income group, PPI, Unemployment rate, GDP
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
    await firestoreMethods.readDocumentFromFirestore('gdp', name).then((value) {
      if (value != null) {
        gdp = value['GDP'];
      }
    });

    // If median salary is given in monthly, convert it to yearly
    if (salaryPeriod == 'MONTH') {
      medianSalary *= 12;
    }

    // Convert currency to usd
    if (currency != 'N/A') { // First make sure a currency is in the country
      await firestoreMethods.readDocumentFromFirestore('currencies', currency).then((value) {
        if (value != null) {
          convertedMedianSalary = medianSalary / value['value'];
        }
      });
    }

    //print('Country: $name\nMedian salary: $medianSalary\nConverted median salary: $convertedMedianSalary\nSalary period: $salaryPeriod\nCurrency: $currency\nIncome group: $incomeGroup\nPPI: $ppi\nUnemployment rate: $unemploymentRate\nGDP: $gdp\nData confidence: $dataConfidence');

    // Compute ratio to determine safety of salary
    double salaryToGdpRatio = convertedMedianSalary / gdp;
    // Add main points (Salary, GDP)
    if (salaryToGdpRatio > 1.5) {
      point += 10; // Strong indicator of financial well-being
    } else if (salaryToGdpRatio >= 0.75) {
      point += 5; // Moderate financial health
    } else {
      point += 2; // Low financial health
    }

// Add side points (PPI, Income group, Unemployment rate)
    // Income group
    if (incomeGroup == 'Upper middle income' || incomeGroup == 'High income') {
      point += 3; // High correlation with strong economic health
    } else if (incomeGroup == 'Lower middle income') {
      point += 1; // Moderate impact
    }

    // PPI
    if (ppi > 75) {
      point += 3; // Indicates high purchasing power
    } else if (ppi >= 50) {
      point += 2; // Moderate purchasing power
    } else {
      point += 1; // Low purchasing power
    }

    // Unemployment rate
    if (unemploymentRate < 4) {
      point += 3; // Very strong economic indicator
    } else if (unemploymentRate <= 7) {
      point += 2; // Moderately good economic indicator
    } else {
      point += 1; // Poor economic indicator
    }

    // Pick color based on points (1-7 RED, 7-14 YELLOW, 14+ GREEN)
    if (point < 7) {
      color = red;
    } else if (point < 14) {
      color = yellow;
    } else {
      color = green;
    }
  }
}