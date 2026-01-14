import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; 
import 'package:project_uas/login_page.dart';
import 'package:project_uas/checkout_page.dart';
import 'package:project_uas/riwayat_page.dart';
import 'package:project_uas/update_profile_page.dart';
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
  final String _baseUrl = 'https://vesta-subcomplete-melonie.ngrok-free.dev/warung_api_uas';

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

  // --- LOGIKA MENU LENGKAP ---
  Future<void> _handleMenu(String value) async {
    if (value == 'Logout') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else if (value == 'Riwayat') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RiwayatPage()));
    } else if (value == 'Update User') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UpdateProfilePage()));
    } else {
      // --- LOGIKA CALL / SMS / MAPS ---
      Uri url;
      
      if (value == 'Call Center') {
        url = Uri.parse("tel:08123456789"); 
      } else if (value == 'SMS Center') {
        url = Uri.parse("sms:08123456789"); 
      } else if (value == 'Lokasi') {
        url = Uri.parse("https://www.google.com/maps/dir//Jl.+Pd.+Majapahit+I+No.b.13,+Bandungmulyo,+Bandungrejo,+Kec.+Mranggen,+Kabupaten+Demak,+Jawa+Tengah+59567/@-6.9858982,110.4142924,15z/data=!4m8!4m7!1m0!1m5!1m1!1s0x2e708febc39e43ff:0x3c9207d4a18386b4!2m2!1d110.5068589!2d-7.0220514?entry=ttu&g_ep=EgoyMDI2MDEwNy4wIKXMDSoASAFQAw%3D%3D");
      } else {
        return;
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal membuka fitur $value")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Warung Ajib"),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white, 
          actions: [
            // --- POPUP MENU (TITIK TIGA) ---
            PopupMenuButton<String>(
              onSelected: _handleMenu,
              itemBuilder: (context) => [
                // PERUBAHAN NOMOR 3: MENU RIWAYAT PINDAH KE PALING ATAS
                const PopupMenuItem(value: 'Riwayat', child: Text("Riwayat Belanja")),
                
                const PopupMenuItem(value: 'Call Center', child: Text("Call Center")),
                const PopupMenuItem(value: 'SMS Center', child: Text("SMS Center")),
                const PopupMenuItem(value: 'Lokasi', child: Text("Lokasi / Maps")),
                const PopupMenuItem(value: 'Update User', child: Text("Update User & Password")),
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
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product,
                                      baseUrl: _baseUrl, 
                                    ),
                                  ),
                                );

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

                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                                productTotal: _totalJual, cartItems: _cart)));

                    if (result == true) {
                      setState(() {
                        _cart.clear(); 
                        _totalJual = 0; 
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Keranjang direset")));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
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