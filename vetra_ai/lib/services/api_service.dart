import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<Map<String, dynamic>> postVoiceIntake(String text) async {
    final url = Uri.parse('$baseUrl/api/v1/intake/voice');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post voice intake: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling voice intake API: $e');
    }
  }

  Future<Map<String, dynamic>> postDiagnose(List<String> symptoms, String animalType) async {
    final url = Uri.parse('$baseUrl/api/v1/diagnose');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'symptoms': symptoms,
          'animalType': animalType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post diagnose: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling diagnose API: $e');
    }
  }
}
