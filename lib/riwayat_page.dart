import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // WAJIB: Import ini agar bisa baca sesi login

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List _history = [];
  bool _isLoading = true;
  File? _selectedImage; 
  
  // Pastikan IP Address Sesuai
  final String _baseUrl = 'https://vesta-subcomplete-melonie.ngrok-free.dev/warung_api_uas';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // --- PERBAIKAN LOGIKA DI SINI ---
  Future<void> _fetchHistory() async {
    // 1. Ambil ID User yang sedang login dari Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id_user');

    // Jika tidak ada sesi login, stop
    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Sesi login tidak ditemukan"))
      );
      return;
    }

    try {
      // 2. Panggil API dengan ID yang dinamis (bukan id_user=1 lagi)
      final response = await http.get(Uri.parse('$_baseUrl/history.php?id_user=$userId'));
      
      if (response.statusCode == 200) {
        setState(() {
          _history = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(String idJual) async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
      _uploadBukti(idJual); 
    }
  }

  Future<void> _uploadBukti(String idJual) async {
    if (_selectedImage == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sedang mengupload...")));

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_bukti.php'));
      
      request.fields['id_jual'] = idJual;
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Upload!")));
        _fetchHistory(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal Upload")));
      }
    } catch (e) {
      print("Error upload: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Belanja"),
        backgroundColor: Colors.orange[800], // Sesuaikan tema
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text("Belum ada transaksi"))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    String status = item['status'];
                    String metode = item['metode'];
                    String? bukti = item['bukti_bayar'];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Order #${item['id_jual']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(item['tgl_jual'], style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const Divider(),
                            Text("Total: Rp ${item['total_bayar']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Metode: $metode"),
                            const SizedBox(height: 10),
                            
                            // Badge Status
                            Row(
                              children: [
                                const Text("Status: "),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: status == 'pending' ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text(
                                    status.toUpperCase(), 
                                    style: const TextStyle(color: Colors.white, fontSize: 12)
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // Tombol Upload (Hanya jika Transfer Manual & Belum ada bukti)
                            if (metode == 'manual' && (bukti == null || bukti.isEmpty))
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(item['id_jual']),
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text("UPLOAD BUKTI TRANSFER"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
                                ),
                              ),
                            
                            // Info jika sudah upload
                            if (bukti != null && bukti.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.green)
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 10),
                                    Text("Bukti pembayaran diterima"),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}