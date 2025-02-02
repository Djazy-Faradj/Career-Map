import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApi {
  // Credentials for the job salary data API
  final String _API_KEY = 'cur_live_zKKLDqkN5oWqIdl27lE3Cb2q4CDMIcrIT8ErX0Gr';

  Future<dynamic> loadData() async { // Parameters require a country and a job title to look for
    String url = 
    'https://api.currencyapi.com/v3/latest?apikey=${_API_KEY}&currencies=EUR%2CUSD%2CCAD';

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['data'].isEmpty) { // Returns false if no information is found
          return false;
        } else {
          return data['data']; // Return the data
        }
      } else {
        throw Exception('Failed to load data (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}