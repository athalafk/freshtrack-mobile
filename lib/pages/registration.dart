import 'package:flutter/material.dart';
import 'common/appbar.dart';
import 'common/drawer.dart';
import '../services/data_service.dart';
import '../data/models/user.dart';
import '../services/api_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool isLoading = true;
  User? currentUser;
  final List<String> satuanList = ['kg', 'liter', 'pcs', 'pack', 'unit', 'gram', 'ml'];
  String? selectedSatuan;
  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController satuanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    namaBarangController.dispose();
    satuanController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final data = await DataService.fetchData(
        fetchBarang: false,
        fetchBatch: false,
        fetchUser: true,
      );

      setState(() {
        currentUser = data['user'] as User;
        isLoading = false;
      });
    } catch (e) {
      print('Error _loadData: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
      );
    }
  }

  void _saveBarang() async {
    final namaBarang = namaBarangController.text.trim();
    final satuan = selectedSatuan ?? '';

    if (namaBarang.isEmpty || selectedSatuan==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiService().createBarang(
      namaBarang: namaBarang,
      satuan: selectedSatuan!,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang "$namaBarang" berhasil disimpan.')),
      );
      namaBarangController.clear();
      setState(() {
        selectedSatuan = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan barang.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Buat Barang',
        currentUser: currentUser,
        isLoading: isLoading,
      ),
      drawer: CommonDrawer(role: currentUser?.role ?? ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Barang',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Divider(thickness: 1),
              SizedBox(height: 32),
              TextField(
                controller: namaBarangController,
                decoration: InputDecoration(
                  hintText: 'Nama Barang',
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: selectedSatuan,
                onChanged: (value) {
                  setState(() {
                    selectedSatuan = value;
                  });
                },
                items: satuanList.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'Pilih Satuan',
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveBarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4796BD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Divider(thickness: 1),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
