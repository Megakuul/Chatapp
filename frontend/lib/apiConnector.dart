import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> createSession(String uri, String code) async {
  final response;
  try {
    response = await http.post(Uri.parse(uri + "?code=$code"));
  } catch (Error) {
    return false;
  }

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<Map<String, dynamic>> fetchMessages(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    if (jsonDecode(response.body)["Success"]) {
      return json.decode(response.body);
    }

    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Messages');
  }
}

Future<bool> postMessage(String uri, Object body) async {

  final response = await http.post(Uri.parse(uri), headers: {"Content-Type": "application/json"}, body: json.encode(body));

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}