import 'package:flutter/material.dart';
import 'package:warung_ajib_uts/login_page.dart';
import 'package:warung_ajib_uts/payment_page.dart';
import 'package:warung_ajib_uts/product_detail_page.dart';
import 'package:warung_ajib_uts/update_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warung_ajib_uts/product_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warung_ajib_uts/cart_item_model.dart';
import 'package:warung_ajib_uts/product_form_page.dart';

// GANTI IMPORT DARI DATABASE KE REPOSITORY
// import 'package:warung_ajib_uts/database_helper.dart'; 
import 'package:warung_ajib_uts/product_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalPrice = 0;
  final List<CartItem> _cart = [];
  
  // Variabel Data
  List<Product> products = [];
  bool isLoading = true;
  
  // Instance Repository Baru
  ProductRepository productRepository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _refreshProducts(); 
  }

  // --- BAGIAN INI DIMODIFIKASI (MySQL) ---
  Future<void> _refreshProducts() async {
    setState(() => isLoading = true);
    
    try {
      // Ambil data dari Server MySQL via Repository
      final data = await productRepository.getProducts();
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      // Jika error (misal server mati), tampilkan pesan di console
      print("Error Server: $e");
      setState(() => isLoading = false);
    }
  }
  // ---------------------------------------

  // Fungsi Reset Keranjang
  void _resetCart() {
    setState(() {
      _cart.clear();
      _totalPrice = 0;
    });
  }

  // Fungsi Hitung Total
  void _calculateTotal() {
    int newTotal = 0;
    for (var item in _cart) {
      newTotal += (item.product.price * item.quantity);
    }
    setState(() {
      _totalPrice = newTotal;
    });
  }

  // Fungsi Tambah ke Cart
  void _addToCart(Product product) {
    int index = _cart.indexWhere((item) => item.product.name == product.name);
    setState(() {
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });
    _calculateTotal();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} ditambahkan ke keranjang!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Logic Klik Gambar (Konfirmasi Jual)
  Future<void> _showAddConfirmation(Product product) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Penjualan"),
          content: Text("Tambahkan ${product.name} ke total penjualan?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Ya, Tambah"),
              onPressed: () {
                _addToCart(product);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
    );
  }

  void _goToPaymentPage() {
    if (_cart.isEmpty) {
      _showError("Keranjang masih kosong");
      return;
    }
    // SAYA KEMBALIKAN KE KODE ASLI ANDA (KARENA SUDAH BENAR)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(totalPrice: _totalPrice)),
    ).then((success) {
      if (success == true) _resetCart();
    });
  }

  // --- MENU & LAUNCHER ---
  Future<void> _launchCall() async {
    final Uri url = Uri(scheme: 'tel', path: '+6281234567890');
    if (!await launchUrl(url)) _showError('Gagal memanggil');
  }
  Future<void> _launchSMS() async {
    final Uri url = Uri(scheme: 'sms', path: '+6281234567890');
    if (!await launchUrl(url)) _showError('Gagal SMS');
  }
  Future<void> _launchMaps() async {
    final Uri url = Uri.parse('https://maps.google.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) _showError('Gagal Maps');
  }
  void _showError(String msg) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onMenuSelected(String value) async {
    if (value == 'update_user') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfilePage()));
    } else if (value == 'tambah_produk') { 
      // Navigasi ke Form Tambah
      bool? result = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ProductFormPage())
      );
      if (result == true) _refreshProducts();
    } else if (value == 'call_center') _launchCall();
    else if (value == 'sms_center') _launchSMS();
    else if (value == 'maps') _launchMaps();
    else if (value == 'logout') _logout();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Warung Ajib (MySQL)"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: "tambah_produk", child: Text("Tambah Produk (+)")),
                PopupMenuItem(child: PopupMenuDivider()),
                PopupMenuItem(value: "call_center", child: Text("Call Center")),
                PopupMenuItem(value: "sms_center", child: Text("SMS Center")),
                PopupMenuItem(value: "maps", child: Text("Lokasi/Maps")),
                PopupMenuItem(value: "update_user", child: Text("Update User")),
                PopupMenuItem(child: PopupMenuDivider()),
                PopupMenuItem(value: "logout", child: Text("Logout")),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. GRID DAFTAR PRODUK
          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator())
              : products.isEmpty
                  // Pesan jika gagal konek atau data kosong
                  ? Center(child: Text("Gagal Konek Server / Data Kosong"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showAddConfirmation(product),
                                  child: Image.network(
                                    // Gunakan imagePath dari database (URL Gambar)
                                    // Jika tidak valid, akan masuk errorBuilder
                                    product.imagePath, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => 
                                        Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showProductDetail(product),
                                      child: Text(
                                        product.name,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text("Rp. ${product.price}", style: TextStyle(color: Colors.green[700])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          
          // 2. TOTAL DI BAWAH
          GestureDetector(
            onTap: _goToPaymentPage, 
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Text(
                "Total : Rp. $_totalPrice",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}