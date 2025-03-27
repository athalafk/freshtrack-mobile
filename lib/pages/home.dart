import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'login.dart';
import '../models/barang.dart';
import '../models/batch_barang.dart';

class HomePage extends StatefulWidget {
  final String? username;

  const HomePage({Key? key, this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = 'Daftar Barang';
  bool isLoading = true;
  List<Barang> daftarBarang = [];
  List<BatchBarang> batchBarang = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
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
              await _performLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      await ApiService().logout();
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

  Future<void> _fetchData() async {
    try {
      setState(() => isLoading = true);

      print('Mengambil data barang...');
      List<Barang> barangData = await ApiService().getBarang();
      print('Jumlah barang: ${barangData.length}');

      print('Mengambil data batch...');
      List<BatchBarang> batchData = await ApiService().getBatchBarang();
      print('Jumlah batch: ${batchData.length}');

      setState(() {
        daftarBarang = barangData;
        batchBarang = batchData;
        isLoading = false;
      });
    } catch (e) {
      print('Error _fetchData: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
      );
    }
  }

  int getRemainingDays(String expiredDate) {
    try {
      DateTime expiryDate = DateTime.parse(expiredDate);
      DateTime today = DateTime.now();
      return expiryDate.difference(today).inDays;
    } catch (e) {
      return -1; // Jika format tanggal tidak valid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventori', style: TextStyle(color: Colors.white)),
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
                      Text(
                        widget.username ?? 'Pengguna',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text("Inventori"),
              onTap: (){
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
              onTap: (){
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => TransactionPage()),
                // );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Riwayat"),
              onTap: (){
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => HistoryPage()),
                // );
              },
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('Daftar Barang'),
                SizedBox(width: 16),
                _buildTabButton('Status Kadaluarsa'),
              ],
            ),
          ),

          // Search and Sort
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Barang',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () => _showSortDialog(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : selectedTab == 'Daftar Barang'
                  ? _buildInventoryList(daftarBarang)
                  : _buildExpiryStatusList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    return ChoiceChip(
      label: Text(title),
      selected: selectedTab == title,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: selectedTab == title ? Colors.white : Colors.black,
      ),
      onSelected: (_) => setState(() => selectedTab = title),
    );
  }

  Widget _buildInventoryList(List<Barang> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Barang', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Stok', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Satuan', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: items.map((item) => DataRow(
            cells: [
              DataCell(Text(item.namaBarang)),
              DataCell(Text(item.totalStok.toString())),
              DataCell(Text(item.satuan)),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, item),
                    ),
                  ],
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildExpiryStatusList() {
    if (batchBarang.isEmpty) return Center(child: Text('Tidak ada data kadaluarsa'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        dataRowHeight: 48,
        headingRowHeight: 56,
        columns: [
          DataColumn(label: Text('Barang')),
          DataColumn(label: Text('Stok'), numeric: true),
          DataColumn(label: Text('Tanggal Kadaluarsa')),
          DataColumn(label: Text('Sisa Hari'), numeric: true),
          DataColumn(label: Text('Status')),
        ],
        rows: batchBarang.map((item) {
          final days = item.hariMenujuKadaluarsa;
          return DataRow(
            cells: [
              DataCell(Text(item.namaBarang)),
              DataCell(Text(item.stok.toString())),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(item.tanggalKadaluarsa)))),
              DataCell(Text(days > 0 ? '$days hari' : 'Expired')),
              DataCell(
                days > 14
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.warning, color: days > 0 ? Colors.orange : Colors.red),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {

  }

  void _showEditDialog(BuildContext context, Barang barang) {
    final namaController = TextEditingController(text: barang.namaBarang);
    String selectedUnit = barang.satuan;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${barang.namaBarang}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama Barang'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedUnit,
              items: ['kg', 'liter', 'pcs', 'pack', 'unit'].map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) => selectedUnit = value!,
              decoration: InputDecoration(labelText: 'Satuan'),
            ),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Simpan'),
            onPressed: () async {
              bool success = await ApiService().updateBarang(
                barang.id,
                namaController.text,
                selectedUnit,
              );

              if (success) {
                setState(() {
                  final updatedBarang = barang.copyWith(
                    namaBarang: namaController.text,
                    satuan: selectedUnit,
                  );

                  // Update daftarBarang
                  final barangIndex = daftarBarang.indexWhere((b) => b.id == barang.id);
                  if (barangIndex != -1) {
                    daftarBarang[barangIndex] = updatedBarang;
                  }

                  // Update batchBarang untuk memastikan perubahan nama muncul di "Status Kadaluarsa"
                  setState(() {
                    batchBarang = batchBarang.map((batch) {
                      if (batch.barangId == barang.id) {
                        return batch.copyWith(namaBarang: namaController.text);
                      }
                      return batch;
                    }).toList();
                  });
                });

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal memperbarui barang")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Barang item) {

  }
}