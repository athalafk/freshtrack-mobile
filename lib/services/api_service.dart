import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/barang.dart';
import '../models/batch_barang.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.1.6:3000'));

  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });

      String token = response.data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);

      return token; // Sukses login
    } catch (e) {
      return null; // Gagal login
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
  }

  Future<List<Barang>> getBarang() async {
    try {
      final response = await _dio.get(
        '/api/barang',
        options: Options(headers: await _getHeaders()),
      );

      print('Response barang: ${response.data}'); // Debug

      return (response.data as List)
          .map((item) => Barang.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print('Error getBarang: ${e.response?.data}');
      return [];
    }
  }

  Future<List<BatchBarang>> getBatchBarang() async {
    try {
      final response = await _dio.get(
        '/api/barang/batch-barang',
        options: Options(headers: await _getHeaders()),
      );

      print('Response batch: ${response.data}'); // Debug

      return (response.data as List)
          .map((item) => BatchBarang.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print('Error getBatchBarang: ${e.response?.data}');
      return [];
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'Authorization': 'Bearer ${prefs.getString('token')}',
    };
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
    } catch (e) {
      print('Error updateBarang: $e');
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
    } catch (e) {
      print('Error deleteBarang: $e');
      return false;
    }
  }
  
}
