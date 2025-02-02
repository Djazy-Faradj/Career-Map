import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String jobSalaryApiKey = dotenv.env['SALARY_DATA_API_KEY'] ?? '';
  final String currencyApiKey = dotenv.env['CURRENCY_API_KEY'] ?? '';
  final String firebaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

  void fetchData() {
    print('API Key: $jobSalaryApiKey');
    print('api key currency URL: $currencyApiKey');
    print('FireBase api: $firebaseApiKey');
  }
}
