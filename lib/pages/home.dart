import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';
import '../data/models/barang.dart';
import '../data/models/batch_barang.dart';
import '../data/sources/barang_data_source.dart';
import '../data/sources/batch_data_source.dart';
import '../data/models/user.dart';
import 'common/appbar.dart';
import 'common/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool isLoading = true;
  List<Barang> daftarBarang = [];
  List<BatchBarang> batchBarang = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final data = await DataService.fetchData(
        fetchBarang: true,
        fetchBatch: true,
        fetchUser: true,
      );

      setState(() {
        daftarBarang = data['barang'] as List<Barang>;
        batchBarang = data['batch'] as List<BatchBarang>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Inventori',
        currentUser: currentUser,
        isLoading: isLoading,
      ),
      drawer: CommonDrawer(role: currentUser?.role ?? ''),

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
                  onRefresh: _loadData,
                  child: _buildInventoryList(daftarBarang),
                ),

                // Tab 2: Status Kadaluarsa
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: _loadData,
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
        columns: [
          DataColumn(label: Text('Barang')),
          DataColumn(label: Text('Stok'), numeric: true),
          DataColumn(label: Text('Satuan')),
          if (currentUser?.role == 'admin')
            const DataColumn(label: Text('Aksi')),
        ],
        source: BarangDataSource(
          data: items,
          onEdit: (item) async {
            final bool? updated = await _showEditDialog(context, item);
            if (updated == true){
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Berhasil memperbarui barang")),
              );
            } else if (updated == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Gagal memperbarui barang")),
              );
            }
          },
          onDelete: (item) async {
            final bool? confirmed = await _showDeleteDialog(context, item);
            if (confirmed == true) {
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Berhasil menghapus barang")),
              );
            }else if (confirmed == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Gagal menghapus barang")),
              );
            }
          },
          userRole: currentUser?.role ?? '',
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

  Future<bool?> _showEditDialog(BuildContext context, Barang barang) {
    final namaController = TextEditingController(text: barang.namaBarang);
    String selectedUnit = barang.satuan;
    String? namaErrorText;

    return showDialog<bool?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateInternal) {
            return AlertDialog(
              title: Text('Edit ${barang.namaBarang}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Barang',
                      errorText: namaErrorText,
                    ),
                    onChanged: (text) {
                      if (namaErrorText != null && text.trim().isNotEmpty) {
                        setStateInternal(() {
                          namaErrorText = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    items: ['kg', 'liter', 'pcs', 'pack', 'unit'].map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) => selectedUnit = value!,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.pop(dialogContext, false), // Mengembalikan false jika batal
                ),
                TextButton(
                  child: const Text('Simpan'),
                  onPressed: () async {
                    if (namaController.text.trim().isEmpty) {
                      setStateInternal(() {
                        namaErrorText = "Nama Barang tidak boleh kosong!";
                      });
                      return;
                    }

                    setStateInternal(() {
                      namaErrorText = null;
                    });

                    bool success = await ApiService().updateBarang(
                      barang.id,
                      namaController.text,
                      selectedUnit,
                    );
                    Navigator.pop(dialogContext, success); // Mengembalikan hasil operasi API
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, Barang barang) {
    return showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${barang.namaBarang}?'),
        content: const Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () async {
              bool success = await ApiService().deleteBarang(barang.id);
              Navigator.pop(context, success);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}