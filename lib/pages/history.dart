import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common/appbar.dart';
import 'common/drawer.dart';
import '../services/data_service.dart';
import '../data/models/user.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  User? currentUser;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      appBar: CommonAppBar(
        title: 'Riwayat',
        currentUser: currentUser,
        isLoading: isLoading,
      ),
      drawer: CommonDrawer(role: currentUser?.role ?? ''),
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
          ],
        ),
      ),
    );
  }
}
