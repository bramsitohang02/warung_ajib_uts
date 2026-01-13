import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_uas/login_page.dart';
import 'package:project_uas/checkout_page.dart';
import 'package:project_uas/riwayat_page.dart';
// IMPORT HALAMAN DETAIL (Pastikan file product_detail_page.dart sudah diupdate sesuai diskusi sebelumnya)
import 'package:project_uas/product_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List _products = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _cart = [];
  int _totalJual = 0;

  // Pastikan IP Address Sesuai
  final String _baseUrl = 'http://192.168.1.13/warung_api_uas';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/read.php'));
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _addToCart(Map product) {
    setState(() {
      String nama = product['nmbrg'] ?? 'Produk';
      int harga = int.tryParse(product['hrgjual']?.toString() ?? '0') ?? 0;
      int berat = 1000;
      String gambar = product['gambar'] ?? '';

      _cart.add({
        'id': product['id'],
        'nama_barang': nama,
        'harga': harga,
        'berat': berat,
        'gambar': gambar
      });
      _totalJual += harga;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${product['nmbrg']} masuk keranjang!"),
        duration: const Duration(milliseconds: 500)));
  }

  // --- FUNGSI _showDescription SUDAH DIHAPUS ---
  // Kita ganti dengan navigasi langsung di tombolnya

  // --- LOGIKA MENU LENGKAP ---
  void _handleMenu(String value) {
    if (value == 'Logout') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else if (value == 'Riwayat') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RiwayatPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fitur $value belum tersedia")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Warung Ajib"),
          // Agar seragam oranye seperti permintaan
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white, // Agar teks putih
          actions: [
            // MENU LENGKAP SESUAI PERMINTAAN
            PopupMenuButton<String>(
              onSelected: _handleMenu,
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'Call Center', child: Text("Call Center")),
                const PopupMenuItem(
                    value: 'SMS Center', child: Text("SMS Center")),
                const PopupMenuItem(value: 'Lokasi', child: Text("Lokasi / Maps")),
                const PopupMenuItem(
                    value: 'Update User', child: Text("Update User & Password")),
                const PopupMenuItem(
                    value: 'Riwayat', child: Text("Riwayat Belanja")),
                const PopupMenuItem(value: 'Logout', child: Text("Logout")),
              ],
            ),
          ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      String gambar = product['gambar'] ?? '';
                      String imageUrl = "$_baseUrl/gambar/$gambar";

                      return Card(
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _addToCart(product),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 40, color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              // --- PERUBAHAN UTAMA DI SINI ---
                              // Mengganti Popup dengan Pindah Halaman Detail
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product,
                                      baseUrl: _baseUrl, // Kirim URL Server
                                    ),
                                  ),
                                );

                                // Jika user klik tombol "BELI SEKARANG" di halaman detail
                                if (result == true) {
                                  _addToCart(product);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product['nmbrg'] ?? '-',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text("Rp ${product['hrgjual']}",
                                        style: const TextStyle(
                                            color: Colors.deepOrange)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (_cart.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Keranjang kosong")));
                      return;
                    }

                    // --- LOGIKA RESET KERANJANG ---
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                                productTotal: _totalJual, cartItems: _cart)));

                    if (result == true) {
                      setState(() {
                        _cart.clear(); // Kosongkan keranjang
                        _totalJual = 0; // Reset harga jadi 0
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Keranjang direset")));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    // --- WARNA ORANYE ---
                    color: Colors.orange[800],
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Penjualan:",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text("Rp $_totalJual",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ),
                ),
              ],
            ),
    );
  }
}