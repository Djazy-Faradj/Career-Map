import 'package:career_map/constant.dart';
import 'package:career_map/model/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}


class _MapState extends State<Map> {
  String searchText = ''; 
  String selectedCountry = '';
  List<Country> countries = []; // List of countries to be displayed on the map

  @override
  void initState() {
    super.initState();
    loadRegions().then((value) {
      countries = value;
      setState(() {});
    });
    
  }

  void updateSearchText(val) { // Keeps track of what is in the search bar
    setState(() {
      searchText = val;
    });
  }

  loadRegions() async {
    // Load the regions of the map
    final path = 'assets/world.svg';
    final content = await rootBundle.loadString(path);
    final document = XmlDocument.parse(content);
    final paths = document.findAllElements('path');
    final regions = <Country>[];

    for (var element in paths) {
      final partPath = element.getAttribute('d').toString();
      String n = element.getAttribute('name').toString();
      String c = element.getAttribute('class').toString();
      if (n == 'null' && c != 'null') {
        regions.add(Country(name: c, path: partPath));
      } else if (c == 'null' && n != 'null') {
        regions.add(Country(name: n, path: partPath));
      }
    }
    return regions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Row(
              spacing: 1,
              children: [
              SvgPicture.asset(
                'assets/logo_svg.svg',
                width: 55,
              ),
              SvgPicture.asset(
                'assets/title.svg',
                height: 150,
              )
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
                  onPressed: (){}, 
                  child: Text('Search'))],)
              ],
        ),
        elevation: 30,
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 163, 180, 188),
      ),
      body: Center(
        // *** BODY ***
        child: InteractiveViewer(
          maxScale: 5,
          minScale: 1.0,
          child: Stack(
            children: [
                ... countries.map((country) {
                  return _getRegionImage(country); 
                })
            ]
          ),
          ),
      ),
      //bottomNavigationBar: BottomAppBar(height: 45, child: Text('Developed by Djazy Faradj for ConUHacks \'25'),),
    );
  }

  Widget _getRegionImage(Country country) {
    return ClipPath(
      clipper: RegionClipper(svgPath: country.path),
      child: GestureDetector(
        onTap: (() {
          print('Country: ${country.name}');
          }),
        child: Container(
          color: country.color,
        ),
      ),
    );
  }
}

class RegionClipper extends CustomClipper<Path> {
  final String svgPath;

  RegionClipper({super.reclip, required this.svgPath});

  @override
  Path getClip(Size size) {
    final path = parseSvgPathData(this.svgPath);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}