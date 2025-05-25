import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common/appbar.dart';
import 'common/drawer.dart';
import '../services/data_service.dart';
import '../data/models/user.dart';
import '../data/models/transaction_model.dart';
import '../services/api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  List<TransactionModel> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactionData();
    _fetchUserData(); // Add this if you need user data
  }

  void _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Riwayat Transaksi', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Tanggal', 'Tipe', 'Barang', 'Stok', 'Pelaku'],
                data: _filteredTransactions.map((tx) {
                  return [
                    DateFormat('dd/MM/yyyy').format(DateTime.parse(tx.date)),
                    tx.type,
                    tx.item,
                    tx.stock,
                    tx.actor,
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
    // Langsung preview dan cetak
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _fetchUserData() async {
    try {
      // Add your user fetching logic here
      ApiService apiService = ApiService();
      User userData = await apiService.getCurrentUser();
      setState(() {
        currentUser = userData;
      });
    } catch (e) {
      print("Gagal mengambil data user: $e");
    }
  }

  Future<void> _fetchTransactionData() async {
    try {
      final apiService = ApiService();
      List<TransactionModel> data = await apiService.fetchTransactions();
      setState(() {
        _allTransactions = data;
        isLoading = false; 
      });
    } catch (e) {
      print("Gagal mengambil data: $e");
      setState(() {
        isLoading = false; 
      });
    }
  }

  List<TransactionModel> get _filteredTransactions {
    if (_startDate == null && _endDate == null) return _allTransactions;

    return _allTransactions.where((transaction) {
      try {
        
        final transactionDate = DateFormat('yyyy-MM-dd').parse(transaction.date);

        if (_startDate != null && _endDate != null) {
          return (transactionDate.isAfter(_startDate!) || transactionDate.isAtSameMomentAs(_startDate!)) &&
              (transactionDate.isBefore(_endDate!) || transactionDate.isAtSameMomentAs(_endDate!));
        } else if (_startDate != null) {
          return transactionDate.isAfter(_startDate!) || transactionDate.isAtSameMomentAs(_startDate!);
        } else if (_endDate != null) {
          return transactionDate.isBefore(_endDate!) || transactionDate.isAtSameMomentAs(_endDate!);
        }
        return true;
      } catch (e) {
        print("Error parsing date: ${transaction.date}, error: $e");
        return false; // Skip transactions with invalid dates
      }
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
                  padding: const EdgeInsets.only(top: 40.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _generatePdf(context);
                      // Cetak PDF functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Cetak PDF', style: TextStyle(color: Colors.white)),
                  ),
                ),

                SizedBox(width: 16),

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
                                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
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
                                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredTransactions.isEmpty
                  ? Center(child: Text("Tidak ada data transaksi"))
                  : SingleChildScrollView(
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
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(transaction.date)))),
                        DataCell(Text(transaction.type)),
                        DataCell(Text(transaction.item)),
                        DataCell(Text(
                          transaction.stock,
                          style: TextStyle(
                            color: transaction.type == 'keluar' ? Colors.red : null,
                          ),
                        )),
                        DataCell(Text(transaction.actor)),
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