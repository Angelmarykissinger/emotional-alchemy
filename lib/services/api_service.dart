import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator → localhost backend
  final String baseUrl = "http://10.0.2.2:8000";

  // --------------------------
  // ✅ Chat Companion API
  // --------------------------
  Future<String> chat(String msg) async {
    try {
      final url = Uri.parse("$baseUrl/chat");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": msg}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)["response"];
      }

      return "Server error 💜";
    } catch (e) {
      return "Connection failed. Run backend first 💜";
    }
  }

  // --------------------------
  // ✅ Mood Analyzer API
  // --------------------------
  Future<Map<String, dynamic>> analyzeMood(String text) async {
    try {
      final url = Uri.parse("$baseUrl/analyze_mood");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          "analysis": {"label": data["label"], "score": (data["score"] as num).toDouble()},
          "recommendation": data["recommendation"]
        };
      }
    } catch (e) {
      print("API Error: $e");
    }
    
    // Fallback
    return {
      "analysis": {"label": "Neutral", "score": 5.0},
      "recommendation": "Take a deep breath 💜"
    };
  }
}
