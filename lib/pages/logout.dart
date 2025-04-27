import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login.dart';

Future<void> showLogoutDialog(BuildContext context) {
  return showDialog(
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
            await performLogout(context);
          },
        ),
      ],
    ),
  );
}

Future<void> performLogout(BuildContext context) async {
  final navigator = Navigator.of(context);
  final scaffold = ScaffoldMessenger.of(context);

  // Menampilkan dialog loading
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
    navigator.pop(); // Tutup dialog loading
    scaffold.showSnackBar(
      SnackBar(content: Text('Gagal logout: ${e.toString()}')),
    );
  }
}
