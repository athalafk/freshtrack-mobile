import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'history.dart';
import 'registration.dart';
import '../services/api_service.dart';
import '../data/models/barang.dart';

class TransactionsPage extends StatefulWidget {
  final String? username;
  TransactionsPage({this.username});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text('Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4796BD),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(50, 70, 0, 0),
                items: [
                  PopupMenuItem(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.username ?? 'Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text('Masuk', style: TextStyle(color: Colors.white))),
            Tab(child: Text('Keluar', style: TextStyle(color: Colors.white))),
          ],
        ),
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
              title: Text("Daftar Barang"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          TransactionForm(title: 'Barang Masuk'),
          TransactionForm(title: 'Barang Keluar'),
        ],
      ),
    );
  }
}
class TransactionForm extends StatefulWidget {
  final String title;
  TransactionForm({required this.title});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  List<Barang> barangList = [];
  bool isLoading = true;

  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
    try {
      List<Barang> barangData = await ApiService().getBarang();
      setState(() {
        barangList = barangData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data barang: $e')),
      );
    }
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
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(),
          SizedBox(height: 16),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return barangList
                  .map((barang) => barang.namaBarang ?? '') // <- pakai field yg benar dari model
                  .where((nama) => (nama ?? '').toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              // nanti implementasi pilihan di sini
            },
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
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
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Stok',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
          if (widget.title == 'Barang Masuk') ...[
            SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Tanggal Expired',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
          ],
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // nanti implementasi simpan di sini
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Simpan',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
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