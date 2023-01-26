import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchMessages(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Messages');
  }
}

Future<bool> postMessage(String uri, Object body) async {
  final response;
  try {
    response = await http.post(Uri.parse(uri), body: json.encode(body), headers: {"Content-Type": "application/json"});
  } catch (Error) {
    return false;
  }

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}