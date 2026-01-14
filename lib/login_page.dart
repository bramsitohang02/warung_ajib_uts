import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_uas/dashboard_page.dart';
import 'package:project_uas/admin/admin_dashboard_page.dart';
import 'package:project_uas/register_page.dart';

// --- (KITA MATIKAN IMPORT GOOGLE SEMENTARA AGAR TIDAK ERROR) ---
// import 'package:google_sign_in/google_sign_in.dart' as google_lib; 
// import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false; 

  // --- LINK NGROK STATIC ANDA ---
  final String _baseUrl = 'https://vesta-subcomplete-melonie.ngrok-free.dev/warung_api_uas';

  // --- FUNGSI LOGIN GOOGLE (DUMMY / SEMENTARA) ---
  Future<void> _handleGoogleSignIn() async {
    // Tampilkan pesan bahwa fitur sedang maintenance
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fitur Login Google sedang dalam pemeliharaan sistem (Maintenance). Silakan gunakan Login Email."),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      )
    );

    /* --- KODE ASLI DISIMPAN DI SINI (UNCOMMENT NANTI SETELAH UAS) ---
    setState(() => _isLoading = true);
    try {
      final google_lib.GoogleSignIn googleSignIn = google_lib.GoogleSignIn();
      final google_lib.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final google_lib.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // ... logika auth lainnya ...
    } catch (e) {
      // ... error handling ...
    }
    */
  }

  // --- LOGIN BIASA (MANUAL) ---
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email dan Password harus diisi!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login.php"),
        body: {
          "email": _emailController.text,
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          String id = data['id'];
          String nama = data['nama'];
          String role = data['role'] ?? 'user';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('id_user', id); 
          await prefs.setString('nama_user', nama);
          await prefs.setString('role_user', role);
          await prefs.setBool('is_login', true);

          if (!mounted) return;
          
          if (role == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${data['message']}")));
        }
      } 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Koneksi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo_icon.png', 
              height: 100, 
              width: 100,
            ),
            
            const SizedBox(height: 20),
            const Text("WARUNG AJIB", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            
            // TOMBOL MASUK BIASA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("MASUK"),
              ),
            ),
            const SizedBox(height: 15),
            
            // --- TOMBOL GOOGLE (TETAP ADA TAPI MAINTENANCE) ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleGoogleSignIn, // Memanggil fungsi dummy
                icon: Image.asset('assets/images/google_logo.png', height: 24), 
                label: const Text("Masuk dengan Google"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
              },
              child: const Text("Belum punya akun? Daftar disini"),
            ),
          ],
        ),
      ),
    );
  }
}