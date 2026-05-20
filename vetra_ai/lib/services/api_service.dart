import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://vetra-backend-695711956978.asia-south1.run.app';

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

  Future<Map<String, dynamic>> postImageIntake(
    String base64Image,
    String caseId,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/intake/image');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image, 'case_id': caseId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post image intake: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling image intake API: $e');
    }
  }

  Future<Map<String, dynamic>> postDiagnose(
    List<String> symptoms,
    String animalType, [
    List<String>? visionFindings,
  ]) async {
    final url = Uri.parse('$baseUrl/api/v1/diagnose');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'symptoms': symptoms,
          'animal_type': animalType,
          if (visionFindings != null) 'vision_findings': visionFindings,
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

  Future<Map<String, dynamic>> getNearbyVets(
    double lat,
    double lng,
    String specialty,
    String urgency,
    int complexity,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/v1/vets/nearby?lat=$lat&lng=$lng&specialty=$specialty&urgency=$urgency&complexity=$complexity',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get nearby vets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling nearby vets API: $e');
    }
  }

  Future<List<dynamic>> getAllVets() async {
    final url = Uri.parse('$baseUrl/api/v1/vets');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to get all vets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling all vets API: $e');
    }
  }

  Future<Map<String, dynamic>> postDecide(
    List<dynamic> vets,
    Map<String, dynamic> diagnosis,
    String urgency,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/vets/decide');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vets': vets,
          'diagnosis': diagnosis,
          'urgency': urgency,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post decide: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling decide API: $e');
    }
  }

  Future<Map<String, dynamic>> getPricing({
    required String vetId,
    required String urgency,
    required int complexityLevel,
    int farmerTotalBookings = 5,
    bool budgetSensitive = false,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/pricing');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vet_id': vetId,
          'urgency': urgency,
          'complexity_level': complexityLevel,
          'farmer_total_bookings': farmerTotalBookings,
          'budget_sensitive': budgetSensitive,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get pricing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling pricing API: $e');
    }
  }

  Future<Map<String, dynamic>> postWorkflow({
    required Map<String, dynamic> vet,
    required Map<String, dynamic> diagnosis,
    required Map<String, dynamic> pricing,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/workflow');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vet': vet,
          'diagnosis': diagnosis,
          'pricing': pricing,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to execute workflow: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling workflow API: $e');
    }
  }

  Future<Map<String, dynamic>> postBooking({
    required String vetId,
    required String caseId,
    required String farmerId,
    required Map<String, dynamic> pricing,
    String? appointmentTime,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/booking');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vet_id': vetId,
          'case_id': caseId,
          'farmer_id': farmerId,
          'pricing': pricing,
          if (appointmentTime != null) 'appointment_time': appointmentTime,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling booking API: $e');
    }
  }
}
