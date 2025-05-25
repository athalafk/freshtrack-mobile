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
  List<Barang> filteredDaftarBarang = [];
  List<BatchBarang> batchBarang = [];
  List<BatchBarang> filteredBatchBarang = [];
  User? currentUser;

  final TextEditingController _searchController = TextEditingController();

  String _sortByBarang = 'nama_barang';
  bool _sortAscendingBarang = true;

  String _sortByBatch = 'tanggal_kadaluarsa';
  bool _sortAscendingBatch = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

        _applyFiltersAndSorts();
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

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase(); // Ambil teks pencarian dalam huruf kecil
    setState(() {
      if (query.isEmpty) {
        filteredDaftarBarang = List.from(daftarBarang);
      } else {
        filteredDaftarBarang = daftarBarang
            .where((barang) => barang.namaBarang.toLowerCase().contains(query))
            .toList();
      }

      if (query.isEmpty) {
        filteredBatchBarang = List.from(batchBarang);
      } else {
        filteredBatchBarang = batchBarang
            .where((batch) => batch.namaBarang.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _applyFiltersAndSorts() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      filteredDaftarBarang = List.from(daftarBarang);
      filteredBatchBarang = List.from(batchBarang);
    } else {
      filteredDaftarBarang = daftarBarang
          .where((barang) => barang.namaBarang.toLowerCase().contains(query))
          .toList();
      filteredBatchBarang = batchBarang
          .where((batch) => batch.namaBarang.toLowerCase().contains(query))
          .toList();
    }
    filteredDaftarBarang.sort((a,b) {
      int compareResult;
      if(_sortByBarang == 'nama_barang') {
        compareResult = a.namaBarang.toLowerCase().compareTo(b.namaBarang.toLowerCase());
      } else if (_sortByBarang == 'total_stok') {
        compareResult = (a.totalStok ?? 0).compareTo(b.totalStok ?? 0);
      } else {
        compareResult = 0;
      }
      return _sortAscendingBarang ? compareResult : -compareResult;
    });

    filteredBatchBarang.sort((a, b) {
      int compareResult;
      if(_sortByBatch == 'tanggal_kadaluarsa') {
        final dateA = DateTime.parse(a.tanggalKadaluarsa);
        final dateB = DateTime.parse(b.tanggalKadaluarsa);
        compareResult = dateA.compareTo(dateB);
      } else if (_sortByBatch == 'nama_barang') {
        compareResult = a.namaBarang.toLowerCase().compareTo(b.namaBarang.toLowerCase());
      } else if (_sortByBatch == 'stok') {
        compareResult = a.stok.compareTo(b.stok);
      }
      else if (_sortByBatch == 'hari_menuju_kadaluarsa') {
        compareResult = (a.hariMenujuKadaluarsa ?? 0).compareTo(b.hariMenujuKadaluarsa ?? 0);
      }
      else {
        compareResult = 0;
      }
      return _sortAscendingBatch ? compareResult : -compareResult;
    });
    setState(() {});
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
                    controller: _searchController,
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
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildInventoryList(filteredDaftarBarang),
                ),

                // Tab 2: Status Kadaluarsa
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildExpiryStatusList(filteredBatchBarang),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(List<Barang> items) {
    if (items.isEmpty && !isLoading && _searchController.text.isNotEmpty) {
      return const Center(child: Text('Tidak ada barang yang ditemukan dengan kriteria pencarian ini.'));
    } else if (items.isEmpty && !isLoading) {
      return const Center(child: Text('Tidak ada barang yang tersedia'));
    }

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.bold)),
        rowsPerPage: _calculateRowsPerPage(),
        columns: [
          DataColumn(
            label: const Text('Barang'),
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortByBarang = 'nama_barang';
                _sortAscendingBarang = ascending;
                _applyFiltersAndSorts(); // Terapkan sorting
              });
            },
          ),
          DataColumn(
            label: const Text('Stok'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortByBarang = 'total_stok';
                _sortAscendingBarang = ascending;
                _applyFiltersAndSorts(); // Terapkan sorting
              });
            },
          ),
          const DataColumn(label: Text('Satuan')),
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

  Widget _buildExpiryStatusList(List<BatchBarang> items) {
    if (items.isEmpty && !isLoading && _searchController.text.isNotEmpty) {
      return const Center(child: Text('Tidak ada status kadaluarsa yang ditemukan dengan kriteria pencarian ini'));
    } else if (items.isEmpty && !isLoading) {
      return const Center(child: Text('Tidak ada data kaduluarsa yang tersedia'));
    }

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: Text('Status Kadaluarsa', style: TextStyle(fontWeight: FontWeight.bold)),
        rowsPerPage: _calculateRowsPerPage(),
        columns: [
          DataColumn(
            label: const Text('Barang'),
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortByBatch = 'nama_barang';
                _sortAscendingBatch = ascending;
                _applyFiltersAndSorts();
              });
            },
          ),
          DataColumn(
            label: const Text('Stok'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortByBatch = 'stok';
                _sortAscendingBatch = ascending;
                _applyFiltersAndSorts();
              });
            },
          ),
          DataColumn(
            label: const Text('Tanggal Kadaluarsa'),
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortByBatch = 'tanggal_kadaluarsa';
                _sortAscendingBatch = ascending;
                _applyFiltersAndSorts();
              });
            },
          ),
          DataColumn(
            label: const Text('Sisa Hari'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortByBatch = 'hari_menuju_kadaluarsa';
                _sortAscendingBatch = ascending;
                _applyFiltersAndSorts();
              });
            },
          ),
          const DataColumn(label: Text('Status')),
        ],
        source: BatchBarangDataSource(data: items),
      ),
    );
  }

  int _calculateRowsPerPage() {
    final mediaQuery = MediaQuery.of(context);
    return (mediaQuery.size.height / kMinInteractiveDimension).floor().clamp(3, 10);
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? currentSortBy;
        bool? currentSortAscending;

        if (_tabController.index == 0) {
          currentSortBy = _sortByBarang;
          currentSortAscending = _sortAscendingBarang;
        } else {
          currentSortBy = _sortByBatch;
          currentSortAscending = _sortAscendingBatch;
        }

        return StatefulBuilder(
          builder: (context, setStateInternal) {
            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_tabController.index == 0) ...[
                    RadioListTile<String>(
                      title: const Text('Nama Barang'),
                      value: 'nama_barang',
                      groupValue: currentSortBy,
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortBy = value;
                          _sortByBarang = value!;
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Total Stok'),
                      value: 'total_stok',
                      groupValue: currentSortBy,
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortBy = value;
                          _sortByBarang = value!;
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                  ],
                  // Opsi sorting untuk Tab Status Kadaluarsa
                  if (_tabController.index == 1) ...[
                    RadioListTile<String>(
                      title: const Text('Tanggal Kadaluarsa'),
                      value: 'tanggal_kadaluarsa',
                      groupValue: currentSortBy,
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortBy = value;
                          _sortByBatch = value!;
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Nama Barang'),
                      value: 'nama_barang',
                      groupValue: currentSortBy,
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortBy = value;
                          _sortByBatch = value!;
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Stok Batch'),
                      value: 'stok',
                      groupValue: currentSortBy,
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortBy = value;
                          _sortByBatch = value!;
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Sisa Hari Kadaluarsa'),
                      value: 'hari_menuju_kadaluarsa',
                      groupValue: currentSortBy,
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortBy = value;
                          _sortByBatch = value!;
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    title: const Text('Urutan'),
                    trailing: DropdownButton<bool>(
                      value: currentSortAscending,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('Ascending'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Descending'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateInternal(() {
                          currentSortAscending = value;
                          if (_tabController.index == 0) {
                            _sortAscendingBarang = value!;
                          } else {
                            _sortAscendingBatch = value!;
                          }
                          _applyFiltersAndSorts();
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
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
                  onPressed: () => Navigator.pop(dialogContext, false),
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
                    Navigator.pop(dialogContext, success);
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