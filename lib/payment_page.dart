import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  final int totalPrice;

  const PaymentPage({super.key, required this.totalPrice});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _paymentUrl;

  @override
  void initState() {
    super.initState();
    // 1. Saat halaman dibuka, langsung minta Link Pembayaran ke Server Next.js
    _getToken();
  }

  Future<void> _getToken() async {
    // --- GANTI KE IP ASLI ANDA ---
    final url = Uri.parse('http://192.168.1.7:3000/api');

    try {
      String orderId = "ORDER-${DateTime.now().millisecondsSinceEpoch}";
      
      final response = await http.post(
        url,
        // PENTING: Tambahkan Header ini agar Server Next.js paham kita kirim JSON
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode({
          "id": orderId,
          "productName": "Total Belanja Warung Ajib",
          "price": widget.totalPrice,
          "quantity": 1
        }),
      );

      print("Respon Server Next.js: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _paymentUrl = data['redirect_url']; 
          _isLoading = false;
        });

        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(_paymentUrl!));
          
      } else {
        // Tampilkan pesan error dari server jika ada
        throw Exception("Gagal: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      // Tampilkan error di layar HP biar terlihat jelas
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Err: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran Midtrans")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading saat minta token
          : WebViewWidget(controller: _controller), // Tampilkan Halaman Bayar Midtrans
    );
  }
}