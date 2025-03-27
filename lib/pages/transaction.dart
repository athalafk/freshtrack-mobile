import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import '../services/api_service.dart';


class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              Navigator.pop(context); // Tutup dialog
              await _performLogout(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle_outlined, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
                      Divider(),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Masuk'),
            Tab(text: 'Keluar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TransactionForm(title: 'Barang Masuk'),
          TransactionForm(title: 'Barang Keluar'),
        ],
      ),
    );
  }
}

class TransactionForm extends StatelessWidget {
  final String title;

  TransactionForm({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Divider(),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Nama Barang',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Stok Barang',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Satuan',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
          ),
          if (title == 'Barang Masuk') ...[
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Expiry Date',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: InputBorder.none,
              ),
            ),
          ],
          SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, color: Colors.blue),
            label: Text('Tambah Barang', style: TextStyle(color: Colors.blue)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
            ),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

Future<void> _performLogout(BuildContext context) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Panggil API logout
    await ApiService().logout();

    // Navigasi ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } catch (e) {
    Navigator.pop(context); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal logout: ${e.toString()}')),
    );
  }
}
