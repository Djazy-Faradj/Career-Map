import 'package:career_map/APIs/job_salary_data.dart';
import 'package:career_map/model/country.dart';
import 'package:flutter/material.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}


class _MapState extends State<Map> {
  @override


  Future createCountry() async {
    var data = await JobSalaryApi().loadData('canada', 'software engineer');
    print(data);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Map!'),
      ),
      body: Center(
        child: ElevatedButton(onPressed: createCountry, child: const Text('Create Country')),
      ),
    );
  }
}