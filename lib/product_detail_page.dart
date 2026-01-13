import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  // Kita terima data mentah dari API (Map), bukan Class Product lama
  final Map<String, dynamic> product;
  final String baseUrl; // Butuh URL untuk load gambar

  const ProductDetailPage({
    super.key, 
    required this.product,
    required this.baseUrl
  });

  @override
  Widget build(BuildContext context) {
    // Siapkan Data agar tidak error null
    String nama = product['nmbrg'] ?? 'Tanpa Nama';
    String deskripsi = product['deskripsi'] ?? 'Tidak ada deskripsi.';
    String harga = product['hrgjual']?.toString() ?? '0';
    String gambar = product['gambar'] ?? '';
    String imageUrl = "$baseUrl/gambar/$gambar";

    return Scaffold(
      appBar: AppBar(
        title: Text(nama),
        backgroundColor: Colors.orange[800], // Sesuaikan tema Warung Ajib
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FOTO PRODUK (NETWORK IMAGE) ---
            Container(
              height: 300, // Gambar besar
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.broken_image, size: 60, color: Colors.grey),
                      Text("Gambar tidak ditemukan"),
                    ],
                  );
                },
              ),
            ),
            
            // --- DETAIL TEKS ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          nama,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Rp $harga",
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.orange
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2), 
                  const SizedBox(height: 10),
                  
                  // Deskripsi
                  const Text(
                    "Deskripsi Produk:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deskripsi,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- TOMBOL BELI DI BAWAH (OPSIONAL TAPI BAGUS) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.5))]
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[800],
            padding: const EdgeInsets.symmetric(vertical: 15)
          ),
          onPressed: () {
            // Kembali ke dashboard dengan sinyal 'beli'
            Navigator.pop(context, true); 
          },
          child: const Text("BELI SEKARANG", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}