import 'dart:convert';
import 'dart:io'; // Perlu import ini untuk File
import 'package:http/http.dart' as http;
import 'product_model.dart';

class ProductRepository {
  final String _baseUrl = 'http://10.0.2.2/warung_api_pbb13'; 

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/read.php'));
      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        List<Product> products = it.map((e) => Product.fromJson(e)).toList();
        return products;
      } else {
        throw Exception('Gagal ambil data');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- FUNGSI UPLOAD GAMBAR ---
  // Parameter 'imageFile' adalah file gambar dari HP
  Future<bool> addProduct(Product product, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/create.php'));

      // 1. Kirim Data Teks
      request.fields['nmbrg'] = product.name;
      request.fields['harga'] = product.price.toString();
      request.fields['stok'] = product.stock.toString();
      request.fields['deskripsi'] = product.description;

      // 2. Kirim File Gambar (Jika User Memilih Gambar dari Galeri)
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      } else {
        // Jika tidak pilih gambar, kirim URL manual (jika ada)
        request.fields['gambar_manual'] = product.imagePath;
      }

      // Kirim Request
      var response = await request.send();

      // Cek Respon
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error upload: $e");
      return false;
    }
  }
}