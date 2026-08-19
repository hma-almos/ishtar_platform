import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl="http://192.168.0.105:9030";
  final http.Client _client;

  ApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET ALL - Fetches list & maps into List<T> models
  Future<List<T>> getAll<T>(
    String endpoint, 
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await _client.get(uri, headers: _headers);
    final List<dynamic> data = _processResponse(response) as List<dynamic>;
    
    return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  /// GET ONE - Fetches single resource & maps into Model T
  Future<T> get<T>(
    String endpoint, 
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await _client.get(uri, headers: _headers);
    final Map<String, dynamic> data = _processResponse(response);
    
    return fromJson(data);
  }

  /// POST - Creates data & returns created Model T
  Future<T> post<T>(
    String endpoint, 
    dynamic bodyData, 
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(bodyData),
    );
    final Map<String, dynamic> data = _processResponse(response);
    
    return fromJson(data);
  }

  /// DELETE - Removes a resource by endpoint
  Future<bool> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await _client.delete(uri, headers: _headers);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw HttpException('Server Error [${response.statusCode}]: ${response.body}');
    }
  }
}