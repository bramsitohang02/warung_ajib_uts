import 'package:flutter/material.dart';
import 'package:warung_ajib_uts/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengubah warna AppBar agar sesuai tema
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BAGIAN FOTO PRODUK (BARU) ---
            Container(
              height: 250, // Tinggi gambar
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200], // Warna background jika gambar transparan
              ),
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.cover, // Agar gambar memenuhi kotak
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 60, color: Colors.grey),
                      Text("Gambar tidak ditemukan"),
                    ],
                  );
                },
              ),
            ),
            // --- AKHIR BAGIAN FOTO ---

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Harga Produk
                  Text(
                    "Harga: Rp. ${product.price}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary, // Warna oranye/kuning
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(), // Garis pemisah
                  SizedBox(height: 10),
                  
                  // Judul Deskripsi
                  Text(
                    "Deskripsi Produk:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Isi Deskripsi
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5, // Jarak antar baris agar enak dibaca
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}