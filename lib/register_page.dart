import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageSate();
}

class _RegisterPageSate extends State<RegisterPage> {
  // Controller untuk mengambil data dari text field
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi untuk simpan data registrasi
  void _register() async {
    // 1. Dapatkan instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 2. Simpan data
    // Kita simpan semua data, termasuk nama, siapa tahu diperlukan
    // untuk halaman "Update User" nanti.
    prefs.setString('namaLengkap', _namaController.text);
    prefs.setString('username', _usernameController.text);
    prefs.setString('password', _passwordController.text); // (Dalam aplikasi nyata, password harus di-hash!)

    // 3. Tampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
    );

    // 4. Kembali ke halaman login
    Navigator.pop(context);
  }

  // Fungsi untuk tombol reset
  void _reset() {
    _namaController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget tidak digunakan
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrasi Login"),
        // Tombol kembali otomatis ditambahkan oleh AppBar
      ),
      body: SingleChildScrollView( // Agar bisa di-scroll jika layar kecil
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true, // Untuk menyembunyikan password
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _register,
                  child: Text("Submit"),
                ),
                OutlinedButton( // Menggunakan OutlinedButton untuk "Reset"
                  onPressed: _reset,
                  child: Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}