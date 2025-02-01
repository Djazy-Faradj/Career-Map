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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Career Map',
            style: TextStyle(
              color: Color.fromARGB(255, 20, 20, 20),
            ),
          ), Row(spacing: 10, children: [SizedBox(width: 250, child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a job',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 20, 20, 20),
                ),
              ),
            ),
          ), ElevatedButton(onPressed: (){print('search button pressed');}, child: Text('Search'))],)],
        ),
        elevation: 30,
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 163, 180, 188),

      ),
      body: Center(
        child: ElevatedButton(onPressed: (){print('create country button pressed');}, child: const Text('Create Country')),
      ),
    );
  }
}