import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import kedua halaman
import 'package:warung_ajib_uts/login_page.dart';
import 'package:warung_ajib_uts/dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Ganti timer lama dengan pengecekan status login
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Tunggu 3 detik untuk efek splash screen
    await Future.delayed(Duration(seconds: 3));

    // Cek SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil status login. Jika tidak ada (null), anggap false.
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Pastikan widget masih ada (mounted) sebelum navigasi
    if (!mounted) return;

    // Navigasi berdasarkan status login
    if (isLoggedIn) {
      // Jika sudah login, langsung ke Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      // Jika belum login, ke Halaman Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Pastikan path ini benar
              width: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Selamat Datang",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "di",
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              "Warung Ajib",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}