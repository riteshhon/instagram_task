import 'dart:convert';

import 'package:flutter/services.dart';

/// Base service for loading JSON from assets (mock API).
abstract class BaseApiService {
  /// Loads and decodes JSON from [path] under assets.
  Future<Map<String, dynamic>> getJsonFromAsset(String path) async {
    final String jsonString =
        await rootBundle.loadString(path);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Loads and decodes a JSON array from [path].
  Future<List<dynamic>> getJsonListFromAsset(String path) async {
    final data = await getJsonFromAsset(path);
    final key = data.keys.first;
    final value = data[key];
    if (value is List<dynamic>) return value;
    throw FormatException('Expected list at key "$key" in $path');
  }
}
