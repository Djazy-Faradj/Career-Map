import 'package:career_map/constant.dart';
import 'package:career_map/model/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
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
  List<Country> countries = [];
  Rect svgBounds = Rect.zero;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      setState(() {}); // Trigger a rebuild when the transformation changes
    });
    loadRegions().then((value) {
      countries = value;
      setState(() {});
    });
  }
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void updateSearchText(val) {
    setState(() {
      searchText = val;
    });
  }

  loadRegions() async {
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

      // Calculate bounds of the SVG
      final pathBounds = parseSvgPathData(partPath).getBounds();
      svgBounds = svgBounds.expandToInclude(pathBounds);
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
              spacing: 0,
              children: [
                SvgPicture.asset(
                  'assets/logo_svg.svg',
                  width: 55,
                ),
                SvgPicture.asset(
                  'assets/title.svg',
                  height: 150,
                )
              ],
            ),
            Row(
              spacing: 10,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a job',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                    onChanged: (val) => updateSearchText(val),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async { 
                    print('boom');},
                  child: Text('Search'),
                ),
              ],
            ),
          ],
        ),
        elevation: 30,
        shadowColor: Colors.black,
        backgroundColor: bannerBlue,
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: EdgeInsets.symmetric(horizontal:500, vertical: 250),
          minScale: 0.9,
          maxScale: 5,
          child: GestureDetector(
            onTapUp: (details) {
              // Convert the tap position to the coordinate system of the map
              final offset = _transformationController.toScene(details.localPosition);
              // Find the country that was tapped
              for (var country in countries) {
                final path = parseSvgPathData(country.path);
                if (path.contains(offset)) {
                  setState(() {
                    selectedCountry = country.name;
                  });
                  print('Tapped country: ${country.name}');
                  break;
                }
              }
            },
            child: SizedBox(
              width: svgBounds.width,
              height: svgBounds.height,
              child: CustomPaint(
                painter: MapPainter(
                  countries: countries,
                  transformationMatrix: _transformationController.value,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 45,
        child: Text('Developed by Djazy Faradj for ConUHacks \'25'),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final List<Country> countries;
  final Matrix4 transformationMatrix;

  MapPainter({
    required this.countries,
    required this.transformationMatrix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

    for (var country in countries) {
      final path = parseSvgPathData(country.path);
      final transformedPath = path.transform(transformationMatrix.storage);
      canvas.drawPath(transformedPath, paint..color = country.color);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.countries != countries ||
        oldDelegate.transformationMatrix != transformationMatrix;
  }
}