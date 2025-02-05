import 'package:career_map/APIs/job_salary_data.dart';
import 'package:career_map/constant.dart';
import 'package:career_map/firebase/firestore_methods.dart';
import 'package:career_map/model/country.dart';
import 'package:career_map/widgets/loading.dart';
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
  bool loading = false;
  String searchText = '';
  String selectedCountry = '';
  List<Country> countries = [];
  Rect svgBounds = Rect.zero;
  final TransformationController _transformationController = TransformationController();

  FirestoreMethods firestoreMethods = FirestoreMethods();

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

  loadData() async {
    setState(() { loading = true; });
    Set<String> names = {}; 
    for (var country in countries) {
      country.color = standard;
      country.point = 0;
    }
    if (searchableJobTitles.contains(searchText.toLowerCase().replaceAll(' ', ''))) {
      bool? isDataValid = await firestoreMethods.salaryDataIsUpToDate(searchText.toLowerCase().replaceAll(' ', ''));
      if (isDataValid == false) {
        int i = 0; // keeps track of how many requests have been made
        await firestoreMethods.createJobSalaryApiDataToFirestore(DateTime.now().toUtc(), 'salary_api', searchText.toLowerCase().replaceAll(' ', ''));
        for (var country in countries) {
          if (!names.add(country.name.toLowerCase().trim())) { // If the country has already been queried to salaryDataApi, skip it
            continue;
          }
          var jobSalaryDataFuture = JobSalaryApi().loadData(country.name, searchText); // Get the job salary data
          var jobSalaryData = await jobSalaryDataFuture;
          if (jobSalaryData == null) {
            continue;
          }
          // limit of 5 requests per second...
          await firestoreMethods.writeJobSalaryApiDataToFirestore(Future.value(jobSalaryData), 'salary_api', 'job_title');
          
          i++;
          if (i == 5) {
            await Future.delayed(Duration(seconds: 6));
            i = 0;
          }
        }
      } else if (isDataValid == null){ // No job in search bar, reset colors
        for (var country in countries) {
          country.color = standard;
        }
      } 
      if (isDataValid != null) {
        await firestoreMethods.readDocumentFromFirestore('salary_api', searchText.toLowerCase().replaceAll(' ', '')).then((value) {
          if (value != null) {
            for (var country in countries) {
              if (value.containsKey(country.name)) {
                country.medianSalary = value[country.name]['median_salary'];
                country.salaryPeriod = value[country.name]['salary_period'];
                country.currency = value[country.name]['salary_currency'];
                country.dataConfidence = value[country.name]['confidence'];
              }
              setState(() {
                country.calculateColor();
              });
            }
          }
        });
      }
      }
    setState(() { loading = false; });
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
                  'assets/logo.svg',
                  width: 55,
                ),
                SvgPicture.asset(
                  'assets/title.svg',
                  height: 150,
                ),
              ],
            ),
            Row(
              spacing: 15,
              children: [
                if (loading) Loading(),
                SizedBox(
                  width: 250,
                  child: DropdownButton<String>(
                    value: searchText.isNotEmpty ? searchText : null,
                    hint: Text(
                      'Select a job',
                      style: TextStyle(color: Colors.black54),
                    ),
                    isExpanded: true,
                    items: searchableJobTitles.map((String jobTitle) {
                      return DropdownMenuItem<String>(
                        value: jobTitle.toLowerCase().replaceAll(' ', ''),
                        alignment: Alignment.center,
                        child: Text(jobTitle),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        searchText = newValue!.toLowerCase().replaceAll(' ', '');
                      });
                      print('Selected: $newValue');
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async { await loadData(); },
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
          maxScale: 2.5,
          scaleFactor: 6000.0,
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
                  print('Tapped country: ${country.name}\nMedian salary: ${country.medianSalary}\nSalary period: ${country.salaryPeriod}\nCurrency: ${country.currency}\nIncome group: ${country.incomeGroup}\nPPI: ${country.ppi}\nUnemployment rate: ${country.unemploymentRate}\nGDP: ${country.gdp}\nData confidence: ${country.dataConfidence}\nPoints: ${country.point}\nConverted Salary: ${country.convertedMedianSalary}\$');
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
        child: Text('CareerMap©2025, Developed by Djazy Faradj for ConUHacks \'25'),
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