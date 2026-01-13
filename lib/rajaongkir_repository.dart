import 'dart:convert';
import 'package:http/http.dart' as http;
import 'city.dart';

class RajaOngkirRepository {
  // Masukkan API Key Komerce Anda di sini
  final String _apiKey = 'ZGywPeuAe6f08410ca791e0b45eJTRu4';

  // URL BARU (Versi Komerce V2)
  final String _baseUrl = 'https://rajaongkir.komerce.id/api/v1';

  // 1. Fungsi Cari Lokasi (Auto-Search)
  Future<List<City>> fetchCities(String query) async {
    // Jika user belum ketik apa-apa, kembalikan list kosong
    if (query.isEmpty) {
      return [];
    }

    try {
      // Endpoint V2 untuk mencari lokasi domestik
      final response = await http.get(
        Uri.parse('$_baseUrl/destination/domestic-destination?search=$query'),
        headers: {
          'key': _apiKey, // Header tetap 'key'
        },
      );

      print("Status Cari: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Struktur V2: { meta: ..., data: [...] }
        List results = data['data']; 
        
        return results.map((json) => City.fromJson(json)).toList();
      } else {
        throw Exception('Gagal cari lokasi: ${response.body}');
      }
    } catch (e) {
      print("Error Fetch: $e");
      // Kembalikan list kosong biar aplikasi gak crash
      return [];
    }
  }

  // 2. Fungsi Cek Ongkir (V2)
  Future<List<dynamic>> checkCost({
    required int originId,
    required int destinationId,
    required int weight,
    required String courier,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calculate/domestic-cost'),
        headers: {
          'key': _apiKey,
          'content-type': 'application/x-www-form-urlencoded',
        },
        body: {
          'origin': originId.toString(),
          'destination': destinationId.toString(),
          'weight': weight.toString(),
          'courier': courier,
        },
      );
      
      print("DEBUG RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // PERBAIKAN DI SINI:
        // Data langsung ada di dalam key ['data'], tidak perlu masuk ke [0]['costs']
        if (data['data'] != null) {
          return data['data']; // Langsung kembalikan list-nya
        }
        
        return [];
      } else {
        throw Exception('Gagal cek ongkir: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}