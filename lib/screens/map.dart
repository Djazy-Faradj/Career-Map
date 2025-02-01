import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}


class _MapState extends State<Map> {
  String searchText = ''; 

  void updateSearchText(val) { // Keeps track of what is in the search bar
    setState(() {
      searchText = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Row(
              spacing: 5,
              children: [
              SvgPicture.asset(
                'assets/logo_svg.svg',
                width: 55,
              ),
              Text('Career Map',
                style: TextStyle(
                  color: Color.fromARGB(255, 20, 20, 20),
                ),
              ), 
          ]),
            Row(
              spacing: 10, 
              children: [
                SizedBox(width: 250, child: TextField(
                  decoration: InputDecoration(
                  hintText: 'Search for a job',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    ),),
                  onChanged: (val) => updateSearchText(val),
                  ),),
                ElevatedButton(
                  onPressed: (){print('search button pressed');}, 
                  child: Text('Search'))],)
              ],
        ),
        elevation: 30,
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 163, 180, 188),
      ),
      body: Center(
        // *** BODY ***
      ),
      bottomNavigationBar: BottomAppBar(height: 45, child: Text('Developed by Djazy Faradj for ConUHacks \'25'),),
    );
  }
}