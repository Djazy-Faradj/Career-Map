import 'dart:convert';
import 'package:http/http.dart' as http;

class JobSalaryApi {
  // Credentials for the job salary data API
  final String _API_KEY = 'b5a76c3ea2msh89978e7ee9c068fp14ae42jsn4039dd39e680';
  final String _API_HOST = 'job-salary-data.p.rapidapi.com';

  Future<Map<String, dynamic>?> loadData(String country, String jobTitle) async { // Parameters require a country and a job title to look for
    String url = 
    'https://job-salary-data.p.rapidapi.com/job-salary?job_title=${jobTitle}&location=${country}&location_type=COUNTRY&years_of_experience=ALL';

    try {
      print('CALLING JOB SALARY API FOR $jobTitle IN $country');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-rapidapi-key': _API_KEY,
          'x-rapidapi-host': _API_HOST,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['data'].isEmpty) { // Returns false if no information is found
          return null;
        } else {
          return data['data'][0]; // Return the data
        }
      } else {
        print('Failed to load data (Status code: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}