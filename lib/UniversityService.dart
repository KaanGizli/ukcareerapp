import 'dart:convert';
import 'package:http/http.dart' as http;

class UniversityService {
  Future<List<String>> fetchUniversities(String query) async {
    final url = 'http://universities.hipolabs.com/search?name=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<String>((item) => item['name'].toString()).toList();
    } else {
      throw Exception('Failed to load universities');
    }
  }

}
