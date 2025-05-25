import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';
import '../data/models/barang.dart';
import '../data/models/batch_barang.dart';
import '../data/models/transaction_model.dart';

class ApiService {
  final String _baseUrl = ('http://localhost:8000');

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        print('Login failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final userData = data['user'];
      final token = data['access_token'];
      final tokenType = data['token_type'];

      if (userData == null || token == null) {
        throw Exception('Invalid response format');
      }

      final user = User.fromJson(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', '$tokenType $token');
      await prefs.setString('user', jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      print('Unexpected login error: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/logout'),
        headers: headers,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');

      return response.statusCode == 200;
    } catch (e) {
      print('Unexpected logout error: $e');
      return false;
    }
  }

  Future<List<Barang>> getBarang() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/barang'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Error getBarang: ${response.body}');
        return [];
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Invalid response format');
      }

      return data.map<Barang>((item) => Barang.fromJson(item)).toList();
    } catch (e) {
      print('Error getBarang: $e');
      return [];
    }
  }

  Future<List<BatchBarang>> getBatchBarang() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/barang/batch-barang'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Error getBatchBarang: ${response.body}');
        return [];
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Invalid response format');
      }

      return data.map<BatchBarang>((item) => BatchBarang.fromJson(item)).toList();
    } catch (e) {
      print('Error getBatchBarang: $e');
      return [];
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      return {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
    } catch (e) {
      print('Error getting headers: $e');
      rethrow;
    }
  }

  Future<bool> updateBarang(int id, String namaBarang, String satuan) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/barang/update/$id'),
        headers: headers,
        body: jsonEncode({
          'nama_barang': namaBarang,
          'satuan': satuan,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updateBarang: $e');
      return false;
    }
  }

  Future<bool> deleteBarang(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/barang/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleteBarang: $e');
      return false;
    }
  }

  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    } else {
      throw Exception('User not found');
    }
  }

  Future<bool> barangMasuk({
    required String namaBarang,
    required int stok,
    required String tanggalKadaluarsa,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/barang/masuk'),
        headers: headers,
        body: jsonEncode({
          'nama_barang': namaBarang,
          'stok': stok,
          'tanggal_kadaluarsa': tanggalKadaluarsa,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error barangMasuk: $e');
      return false;
    }
  }
  static Future<List<TransactionModel>> fetchTransactions() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/transactions'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
