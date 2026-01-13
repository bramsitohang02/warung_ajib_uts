import 'package:flutter/material.dart';
import 'package:project_uas/login_page.dart'; // Sesuaikan import jika perlu

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Admin"),
        backgroundColor: Colors.red, // Pembeda warna biar jelas
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout sederhana: kembali ke Login
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const LoginPage())
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text("Halo Bos! Ini Halaman Admin.", style: TextStyle(fontSize: 20)),
            Text("Menu Kelola Produk & Laporan akan ada di sini."),
          ],
        ),
      ),
    );
  }
}