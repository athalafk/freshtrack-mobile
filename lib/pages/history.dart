import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import '../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
        title: Text('Riwayat', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4796BD),
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rentang Riwayat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('Cetak PDF', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text('Awal'),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Akhir'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Tipe')),
                    DataColumn(label: Text('Barang')),
                    DataColumn(label: Text('Stok')),
                    DataColumn(label: Text('Pelaku')),
                  ],
                  rows: [
                    _buildDataRow('20 Dec', 'Masuk', 'Beras', '20', 'admin'),
                    _buildDataRow('25 Dec', 'Keluar', 'Minyak Goreng', '35', 'helmi'),
                    _buildDataRow('25 Dec', 'Masuk', 'Gula', '96', 'athala'),
                    _buildDataRow('25 Dec', 'Keluar', 'Garam', '52', 'bayu'),
                    _buildDataRow('25 Dec', 'Masuk', 'Gula', '180', 'raihan'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            Center(
              child: Text(
                'Copyright © | Fresh Track',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String date, String type, String item, String stock, String actor) {
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(type)),
        DataCell(Text(item)),
        DataCell(
          Text(
            stock,
            style: TextStyle(
              color: type == 'Keluar' ? Colors.red : null,
            ),
          ),
        ),
        DataCell(Text(actor)),
      ],
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