import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk membatasi input hanya angka

class PaymentPage extends StatefulWidget {
  final int totalPrice;

  const PaymentPage({super.key, required this.totalPrice});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Controller untuk input jumlah bayar
  final TextEditingController _paymentController = TextEditingController();
  // Variabel untuk menyimpan uang kembali
  int _kembalian = 0;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener ke controller
    // Ini akan memanggil _calculateKembalian setiap kali user mengetik
    _paymentController.addListener(_calculateKembalian);
  }

  // Fungsi untuk menghitung kembalian
  void _calculateKembalian() {
    // Ambil teks dari input, jika kosong anggap "0"
    String paymentText = _paymentController.text;
    int paymentAmount = int.tryParse(paymentText) ?? 0;

    // Hitung kembalian
    int calculatedKembalian = paymentAmount - widget.totalPrice;

    // Update state agar UI berubah
    setState(() {
      // Jika kembalian negatif (uang kurang), tampilkan 0
      _kembalian = (calculatedKembalian < 0) ? 0 : calculatedKembalian;
    });
  }

  @override
  void dispose() {
    // Selalu bersihkan controller
    _paymentController.removeListener(_calculateKembalian); // Hapus listener
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Pembayaran"),
      ),
      body: SingleChildScrollView( // Agar bisa di-scroll
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Total Transaksi
            Text(
              "Total Transaksi:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Rp. ${widget.totalPrice}",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 30),

            // 2. Input Jumlah Pembayaran
            TextFormField(
              controller: _paymentController,
              // Keyboard khusus angka
              keyboardType: TextInputType.number,
              // Membatasi input hanya boleh angka
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: "Jumlah Pembayaran",
                border: OutlineInputBorder(),
                prefixText: "Rp. ",
              ),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),

            // 3. Tampilan Kembalian
            Text(
              "Kembali:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Rp. $_kembalian",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 40),

            // Tombol Selesai (Opsional)
            ElevatedButton(
              onPressed: () {
                // Tampilkan notifikasi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaksi Selesai!')),
                );
                
                // Kembali ke halaman Dashboard DAN kirim sinyal 'true'
                Navigator.pop(context, true); 
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Selesai Transaksi",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}