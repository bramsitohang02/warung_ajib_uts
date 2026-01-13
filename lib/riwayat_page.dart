import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Plugin Kamera/Galeri

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List _history = [];
  bool _isLoading = true;
  File? _selectedImage; 
  // Pastikan IP ini sesuai dengan laptop Anda saat ini
  final String _baseUrl = 'http://192.168.1.13/warung_api_uas';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/history.php?id_user=1'));
      
      if (response.statusCode == 200) {
        setState(() {
          _history = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
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
        _fetchHistory(); 
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
      appBar: AppBar(title: const Text("Riwayat Belanja")),
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
                            Text("Total: Rp ${item['total_bayar']}"),
                            Text("Metode: $metode"),
                            const SizedBox(height: 5),
                            
                            Row(
                              children: [
                                const Text("Status: "),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: status == 'pending' ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text(status, style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            if (metode == 'manual' && (bukti == null || bukti.isEmpty))
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(item['id_jual']),
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text("UPLOAD BUKTI TRANSFER"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                                ),
                              ),
                            
                            if (bukti != null && bukti.isNotEmpty)
                              Container(
                                // --- PERBAIKAN DI SINI ---
                                margin: const EdgeInsets.only(top: 10), // Ganti .top jadi .only(top: ...)
                                padding: const EdgeInsets.all(10),
                                color: Colors.green[50],
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 10),
                                    Text("Bukti sudah dikirim"),
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