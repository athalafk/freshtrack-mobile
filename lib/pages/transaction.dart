import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import '../services/api_service.dart';

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
              Navigator.pop(context); // Tutup dialog
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text('Masuk', style: TextStyle(color: Colors.white))),
            Tab(child: Text('Keluar', style: TextStyle(color: Colors.white))),
          ],
          labelColor: Colors.white,
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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(username: widget.username)),
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

class TransactionForm extends StatelessWidget {
  final String title;

  TransactionForm({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Divider(),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Nama Barang',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Stok Barang',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Satuan',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
            ),
          ),
          if (title == 'Barang Masuk') ...[
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Expiry Date',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: InputBorder.none,
              ),
            ),
          ],
          SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, color: Colors.blue),
            label: Text('Tambah Barang', style: TextStyle(color: Colors.blue)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text('Simpan', style: TextStyle(color: Colors.white)),
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
      SnackBar(content: Text('Gagal logout: \${e.toString()}')),
    );
  }
}
