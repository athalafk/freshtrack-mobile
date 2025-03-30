import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';
import '../data/models/barang.dart';
import '../data/models/batch_barang.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://freshtrack-backup-production.up.railway.app'));

  Future<User?> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });

      final userData = response.data['user'];
      final token = response.data['token'];

      if (userData == null || token == null) {
        throw Exception('Invalid response format');
      }

      final user = User.fromJson(userData);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toJson()));

      return user;
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      print('Unexpected login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  Future<List<Barang>> getBarang() async {
    try {
      final response = await _dio.get(
        '/api/barang',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data is! List) {
        throw Exception('Invalid response format');
      }

      return (response.data as List)
          .map((item) => Barang.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print('Error getBarang: ${e.response?.data ?? e.message}');
      return [];
    }
  }

  Future<List<BatchBarang>> getBatchBarang() async {
    try {
      final response = await _dio.get(
        '/api/barang/batch-barang',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data is! List) {
        throw Exception('Invalid response format');
      }

      return (response.data as List)
          .map((item) => BatchBarang.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print('Error getBatchBarang: ${e.response?.data ?? e.message}');
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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    } catch (e) {
      print('Error getting headers: $e');
      rethrow;
    }
  }

  Future<bool> updateBarang(int id, String namaBarang, String satuan) async {
    try {
      final response = await _dio.put(
        '/api/barang/$id',
        options: Options(headers: await _getHeaders()),
        data: {
          'nama_barang': namaBarang,
          'satuan': satuan,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error updateBarang: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  Future<bool> deleteBarang(int id) async {
    try {
      final response = await _dio.delete(
        '/api/barang/$id',
        options: Options(headers: await _getHeaders()),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error deleteBarang: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}