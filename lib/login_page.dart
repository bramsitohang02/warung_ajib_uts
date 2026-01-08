import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warung_ajib_uts/dashboard_page.dart'; // Import dashboard
import 'package:warung_ajib_uts/register_page.dart'; // Import register

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi untuk cek login
  void _login() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil data yang tersimpan
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    // Ambil input user
    String inputUsername = _usernameController.text;
    String inputPassword = _passwordController.text;

    // Cek apakah username dan password cocok
    if (savedUsername == inputUsername && savedPassword == inputPassword) {
      
      // Jika cocok, simpan status login
      prefs.setBool('isLoggedIn', true);

      // Pindah ke Dashboard
      // Gunakan pushReplacement agar tidak bisa kembali ke Halaman Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      // Jika gagal, tampilkan notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username atau Password salah!')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login User"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60), // Beri jarak atas
            Text(
              "Silakan Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text("Login"),
            ),
            const SizedBox(height: 12),
            // Teks "Punya akun? Login!" di PDF [cite: 104] adalah di halaman registrasi
            // Kita buat kebalikannya di sini
            TextButton(
              onPressed: () {
                // Pindah ke Halaman Registrasi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text("Belum punya akun? Registrasi"),
            ),
          ],
        ),
      ),
    );
  }
}