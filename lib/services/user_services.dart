import 'dart:convert';
import 'package:http/http.dart' as http;

class UserServices {
  static String? userEmail; // Static variable to store the email

  static Future login({required String email, required String password}) async {
    try {
      final uri = Uri.parse('http://192.168.1.112:3000/login');
      final response = await http.post(uri,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        userEmail = email; // Store the email when login is successful
        return;
      } else if (response.statusCode == 404) {
        throw "User Not Found";
      } else if (response.statusCode == 400) {
        throw "Invalid Password";
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static String getEmail() {
    return userEmail ?? ''; // Provide a default value if userEmail is null
  }
}
