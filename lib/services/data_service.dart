import 'api_service.dart';
import '../data/models/barang.dart';
import '../data/models/batch_barang.dart';
import '../data/models/user.dart';

class DataService {
  static Future<Map<String, dynamic>> fetchData({
    bool fetchBarang = false,
    bool fetchBatch = false,
    bool fetchUser = false,
  }) async {
    try {
      Map<String, dynamic> result = {};

      if (fetchBarang) {
        print('Mengambil data barang...');
        List<Barang> barangData = await ApiService().getBarang();
        print('Jumlah barang: ${barangData.length}');
        result['barang'] = barangData;
      }

      if (fetchBatch) {
        print('Mengambil data batch...');
        List<BatchBarang> batchData = await ApiService().getBatchBarang();
        print('Jumlah batch: ${batchData.length}');
        result['batch'] = batchData;
      }

      if (fetchUser) {
        print('Mengambil data user...');
        User user = await ApiService().getCurrentUser();
        result['user'] = user;
      }

      return result;
    } catch (e) {
      print('Error fetchData: $e');
      rethrow;
    }
  }
}
