import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import '../services/api_service.dart';
import 'transaction.dart';
import 'package:intl/intl.dart';

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
    {'date': '20 Dec', 'type': 'Masuk', 'item': 'Beras', 'stock': '20', 'actor': 'admin'},
    {'date': '25 Dec', 'type': 'Keluar', 'item': 'Minyak Goreng', 'stock': '35', 'actor': 'helmi'},
    {'date': '25 Dec', 'type': 'Masuk', 'item': 'Gula', 'stock': '96', 'actor': 'athala'},
    {'date': '25 Dec', 'type': 'Keluar', 'item': 'Garam', 'stock': '52', 'actor': 'bayu'},
    {'date': '25 Dec', 'type': 'Masuk', 'item': 'Gula', 'stock': '180', 'actor': 'raihan'},
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_startDate == null && _endDate == null) return _allTransactions;

    return _allTransactions.where((transaction) {
      final transactionDate = DateFormat('dd MMM').parse(transaction['date']);
      final currentYear = DateTime.now().year;
      final fullDate = DateTime(currentYear, transactionDate.month, transactionDate.day);

      if (_startDate != null && _endDate != null) {
        return (fullDate.isAfter(_startDate!) || fullDate.isAtSameMomentAs(_startDate!)) &&
            (fullDate.isBefore(_endDate!) || fullDate.isAtSameMomentAs(_endDate!));
      } else if (_startDate != null) {
        return fullDate.isAfter(_startDate!) || fullDate.isAtSameMomentAs(_startDate!);
      } else if (_endDate != null) {
        return fullDate.isBefore(_endDate!) || fullDate.isAtSameMomentAs(_endDate!);
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan Rentang Riwayat di kanan dan Cetak PDF di kiri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Cetak PDF functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('Cetak PDF', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Date Picker Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Awal Date Picker
                InkWell(
                  onTap: () => _selectDate(context, true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Awal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _startDate != null
                            ? DateFormat('dd MMM yyyy').format(_startDate!)
                            : 'Pilih Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Akhir Date Picker
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akhir',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _endDate != null
                            ? DateFormat('dd MMM yyyy').format(_endDate!)
                            : 'Pilih Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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