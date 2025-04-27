import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../data/models/barang.dart';
import '../data/models/user.dart';
import 'common/appbar.dart';
import 'common/drawer.dart';

class TransactionsPage extends StatefulWidget {
  final String? username;
  const TransactionsPage({this.username, Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? currentUser;
  List<Barang> barangList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final data = await DataService.fetchData(
        fetchBarang: true,
        fetchBatch: false,
        fetchUser: true,
      );

      setState(() {
        barangList = data['barang'] as List<Barang>;
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Transaksi',
        currentUser: currentUser,
        isLoading: isLoading,
      ),
      drawer: const CommonDrawer(),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF4796BD),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.orange,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Masuk'),
                Tab(text: 'Keluar'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Barang Masuk'),
                _buildTabContent('Barang Keluar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String title) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TransactionForm(title: title, barangList: barangList),
        ],
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  final String title;
  final List<Barang> barangList;

  const TransactionForm({required this.title, required this.barangList, Key? key}) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _stokController.dispose();
    _namaBarangController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        const SizedBox(height: 16),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.barangList
                .map((barang) => barang.namaBarang ?? '')
                .where((nama) => nama.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            _namaBarangController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: InputBorder.none,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _stokController,
          decoration: InputDecoration(
            labelText: 'Stok',
            filled: true,
            fillColor: Colors.grey.shade200,
            border: InputBorder.none,
          ),
          keyboardType: TextInputType.number,
        ),
        if (widget.title == 'Barang Masuk') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Tanggal Expired',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Implementasi tombol simpan
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Simpan',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}