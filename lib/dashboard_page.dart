import 'package:flutter/material.dart';
import 'package:warung_ajib_uts/login_page.dart';
import 'package:warung_ajib_uts/payment_page.dart';
import 'package:warung_ajib_uts/product_detail_page.dart';
import 'package:warung_ajib_uts/update_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warung_ajib_uts/product_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warung_ajib_uts/cart_item_model.dart';
// IMPORT BARU
import 'package:warung_ajib_uts/database_helper.dart';
import 'package:warung_ajib_uts/product_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalPrice = 0;
  final List<CartItem> _cart = [];
  
  // Variabel untuk menampung data dari Database
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshProducts(); // Load data saat awal buka
  }

  // FUNGSI LOAD DATA DARI SQLITE
  Future<void> _refreshProducts() async {
    setState(() => isLoading = true);
    this.products = await DatabaseHelper.instance.readAllProducts();
    setState(() => isLoading = false);
  }

  // FUNGSI HAPUS DATA DARI SQLITE
  Future<void> _deleteProduct(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshProducts(); // Refresh list setelah hapus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Produk berhasil dihapus")),
    );
  }

  // Fungsi Reset Keranjang (Standard)
  void _resetCart() {
    setState(() {
      _cart.clear();
      _totalPrice = 0;
    });
  }

  // Fungsi Hitung Total (Standard)
  void _calculateTotal() {
    int newTotal = 0;
    for (var item in _cart) {
      newTotal += (item.product.price * item.quantity);
    }
    setState(() {
      _totalPrice = newTotal;
    });
  }

  // Fungsi Tambah ke Cart (Standard)
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

  // Logic Klik Gambar (Konfirmasi Jual - Ketentuan 3.c)
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

  // Logic Long Press (Untuk Edit/Hapus Produk - Syarat Modifikasi Praktikum 9)
  void _showAdminOptions(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Kelola Produk: ${product.name}", style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text("Edit Produk"),
                onTap: () async {
                  Navigator.pop(context);
                  // Buka Form dengan membawa data produk (Mode Edit)
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductFormPage(product: product)),
                  );
                  if (result == true) _refreshProducts();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Hapus Produk"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProduct(product.id!); // Hapus berdasarkan ID
                },
              ),
            ],
          ),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(totalPrice: _totalPrice)),
    ).then((success) {
      if (success == true) _resetCart();
    });
  }

  // --- MENU & LAUNCHER (Standard) ---
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
      // MENU TAMBAH PRODUK BARU
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

  // Dialog Keranjang (Standard)
  void _showCartDialog() {
     // ... (Kode sama persis seperti sebelumnya, tidak ada perubahan logika)
     // Untuk mempersingkat jawaban, saya asumsikan Anda pakai kode dialog keranjang sebelumnya.
     // Isinya: showModalBottomSheet berisi ListView keranjang.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Warung Ajib"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) {
              return [
                // MENU BARU UNTUK PRAKTIKUM 9
                PopupMenuItem(value: "tambah_produk", child: Text("Tambah Produk (+)")),
                PopupMenuItem(child: PopupMenuDivider()),
                
                PopupMenuItem(value: "call_center", child: Text("Call Center")),
                PopupMenuItem(value: "sms_center", child: Text("SMS Center")),
                PopupMenuItem(value: "maps", child: Text("Lokasi/Maps")),
                PopupMenuItem(value: "update_user", child: Text("Update User & Password")),
                PopupMenuItem(child: PopupMenuDivider()),
                PopupMenuItem(value: "logout", child: Text("Logout")),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. GRID DAFTAR PRODUK (DARI SQLITE)
          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? Center(child: Text("Produk Kosong. Silakan Tambah!"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          child: InkWell(
                            // Fitur Tambahan: Tekan lama untuk Edit/Hapus
                            onLongPress: () => _showAdminOptions(product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    // Ketentuan 3.c: Gambar diketuk -> Penjualan
                                    onTap: () => _showAddConfirmation(product),
                                    child: Image.asset(
                                      product.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Center(child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        // Ketentuan 3.b: Nama diketuk -> Deskripsi
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
                          ),
                        );
                      },
                    ),
          ),
          
          // 2. TOTAL DI BAWAH (Ketentuan 3.c & 3.d)
          GestureDetector(
            onTap: _goToPaymentPage, // Atau _showCartDialog jika mau pakai fitur keranjang advanced
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
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