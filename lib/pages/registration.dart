import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home.dart';
import 'transaction.dart';
import 'history.dart';

class RegistrationPage extends StatefulWidget {
  final String? username;

  const RegistrationPage({Key? key, this.username}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController satuanController = TextEditingController();

  @override
  void dispose() {
    namaBarangController.dispose();
    satuanController.dispose();
    super.dispose();
  }

  void _saveBarang() {
    final namaBarang = namaBarangController.text.trim();
    final satuan = satuanController.text.trim();

    if (namaBarang.isEmpty || satuan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barang "$namaBarang" dengan satuan "$satuan" disimpan.')),
    );

    namaBarangController.clear();
    satuanController.clear();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              await Future.delayed(Duration(milliseconds: 100));
              await _performLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await ApiService().logout();
      navigator.pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      navigator.pop();
      scaffold.showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Barang', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4796BD),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(50, 70, 0, 0),
                items: [
                  PopupMenuItem(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username ?? 'Pengguna',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4796BD)),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text("Inventori"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_outlined),
              title: Text("Daftar Barang"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_outlined),
              title: Text("Transaksi"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Riwayat"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
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
              TextField(
                controller: satuanController,
                decoration: InputDecoration(
                  hintText: 'Satuan',
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
