import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login.dart';
import '../data/models/barang.dart';
import '../data/models/batch_barang.dart';
import '../data/sources/barang_data_source.dart';
import '../data/sources/batch_data_source.dart';
import 'transaction.dart';
import 'history.dart';

class HomePage extends StatefulWidget {
  final String? username;

  const HomePage({Key? key, this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool isLoading = true;
  List<Barang> daftarBarang = [];
  List<BatchBarang> batchBarang = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
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

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      navigator.pop();
      scaffold.showSnackBar(
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
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventori', style: TextStyle(color: Colors.white)),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Riwayat"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            )
          ],
        ),
      ),

      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Color(0xFF4796BD),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicatorColor: Colors.orange,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Daftar Barang'),
                Tab(text: 'Status Kadaluarsa'),
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

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Daftar Barang
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: _buildInventoryList(daftarBarang),
                ),

                // Tab 2: Status Kadaluarsa
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: _buildExpiryStatusList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(List<Barang> items) {
    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.bold)),
        rowsPerPage: _calculateRowsPerPage(),
        columns: const [
          DataColumn(label: Text('Barang')),
          DataColumn(label: Text('Stok'), numeric: true),
          DataColumn(label: Text('Satuan')),
          DataColumn(label: Text('Aksi')),
        ],
        source: BarangDataSource(
          data: items,
          onEdit: (item) => _showEditDialog(context, item),
          onDelete: (item) => _showDeleteDialog(context, item),
        ),
      ),
    );
  }

  Widget _buildExpiryStatusList() {
    if (batchBarang.isEmpty) return Center(child: Text('Tidak ada data kadaluarsa'));

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: Text('Status Kadaluarsa', style: TextStyle(fontWeight: FontWeight.bold)),
        rowsPerPage: _calculateRowsPerPage(),
        columns: const [
          DataColumn(label: Text('Barang')),
          DataColumn(label: Text('Stok'), numeric: true),
          DataColumn(label: Text('Tanggal Kadaluarsa')),
          DataColumn(label: Text('Sisa Hari'), numeric: true),
          DataColumn(label: Text('Status')),
        ],
        source: BatchBarangDataSource(data: batchBarang),
      ),
    );
  }

  int _calculateRowsPerPage() {
    final mediaQuery = MediaQuery.of(context);
    return (mediaQuery.size.height / kMinInteractiveDimension).floor().clamp(3, 10);
  }

  void _showSortDialog(BuildContext context) {
    // Implement your sort dialog here
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

                  final barangIndex = daftarBarang.indexWhere((b) => b.id == barang.id);
                  if (barangIndex != -1) {
                    daftarBarang[barangIndex] = updatedBarang;
                  }

                  batchBarang = batchBarang.map((batch) {
                    if (batch.barangId == barang.id) {
                      return batch.copyWith(namaBarang: namaController.text);
                    }
                    return batch;
                  }).toList();
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

  void _showDeleteDialog(BuildContext context, Barang barang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${barang.namaBarang}?'),
        content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Hapus'),
            onPressed: () async {
              bool success = await ApiService().deleteBarang(barang.id);

              if (success) {
                setState(() {
                  daftarBarang.removeWhere((b) => b.id == barang.id);
                  batchBarang.removeWhere((batch) => batch.barangId == barang.id);
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menghapus barang")),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}