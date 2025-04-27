import 'package:flutter/material.dart';
import '../home.dart';
import '../registration.dart';
import '../transaction.dart';
import '../history.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4796BD)),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory,
            title: "Inventori",
            page: HomePage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment_outlined,
            title: "Daftar Barang",
            page: RegistrationPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment_outlined,
            title: "Transaksi",
            page: TransactionsPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: "Riwayat",
            page: HistoryPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required Widget page}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
