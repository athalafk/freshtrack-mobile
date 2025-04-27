import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import '../services/api_service.dart';
import 'transaction.dart';
import 'package:intl/intl.dart';

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Apakah Anda yakin ingin logout?'),
        actions: <Widget>[
          TextButton(
            child: Text('Batal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              // Lakukan proses logout di sini
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      );
    },
  );
}

class HistoryPage extends StatefulWidget {
  final String? username;
  HistoryPage({this.username});
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _allTransactions = [
    {'date': '20 Dec 2024', 'type': 'Masuk', 'item': 'Beras', 'stock': '20', 'actor': 'admin'},
    {'date': '25 Dec 2024', 'type': 'Keluar', 'item': 'Minyak Goreng', 'stock': '35', 'actor': 'helmi'},
    {'date': '25 Dec 2024', 'type': 'Masuk', 'item': 'Gula', 'stock': '96', 'actor': 'athala'},
    {'date': '25 Dec 2024', 'type': 'Keluar', 'item': 'Garam', 'stock': '52', 'actor': 'bayu'},
    {'date': '30 Dec 2024', 'type': 'Masuk', 'item': 'Gula', 'stock': '180', 'actor': 'raihan'},
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_startDate == null && _endDate == null) return _allTransactions;

    return _allTransactions.where((transaction) {
      final transactionDate = DateFormat('dd MMM yyyy').parse(transaction['date']);

      if (_startDate != null && _endDate != null) {
        return (transactionDate.isAfter(_startDate!) || transactionDate.isAtSameMomentAs(_startDate!)) &&
            (transactionDate.isBefore(_endDate!) || transactionDate.isAtSameMomentAs(_endDate!));
      } else if (_startDate != null) {
        return transactionDate.isAfter(_startDate!) || transactionDate.isAtSameMomentAs(_startDate!);
      } else if (_endDate != null) {
        return transactionDate.isBefore(_endDate!) || transactionDate.isAtSameMomentAs(_endDate!);
      }
      return true;
    }).toList();
  }


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4796BD),
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
                ],
              ),
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
          ]
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment_outlined),
                title: Text("Transaksi"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransactionsPage(username: widget.username)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text("Riwayat"),
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => HistoryPage()),
                  // );
                },
              ),
            ],
          ),
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan Cetak PDF dan Rentang Tanggal dalam satu Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Cetak PDF
                Padding(
                  padding: const EdgeInsets.only(top: 40.0), // Tambahin top padding buat nurunin tombol
                  child: ElevatedButton(
                    onPressed: () {
                      // Cetak PDF functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Cetak PDF', style: TextStyle(color: Colors.white)),
                  ),
                ),

                SizedBox(width: 16), // Jarak tombol ke fitur Rentang Riwayat

                // Rentang Riwayat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rentang Riwayat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Awal',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            Text(
                              _startDate != null
                                  ? DateFormat('dd MMM yyyy').format(_startDate!)
                                  : 'Pilih Tanggal',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Akhir',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            Text(
                              _endDate != null
                                  ? DateFormat('dd MMM yyyy').format(_endDate!)
                                  : 'Pilih Tanggal',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            SizedBox(height: 24),

            // Data Table
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
                  rows: _filteredTransactions.map((transaction) {
                    return DataRow(
                      cells: [
                        DataCell(Text(transaction['date'])),
                        DataCell(Text(transaction['type'])),
                        DataCell(Text(transaction['item'])),
                        DataCell(
                          Text(
                            transaction['stock'],
                            style: TextStyle(
                              color: transaction['type'] == 'Keluar' ? Colors.red : null,
                            ),
                          ),
                        ),
                        DataCell(Text(transaction['actor'])),
                      ],
                    );
                  }).toList(),
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
}