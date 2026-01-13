import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'city.dart'; // Pastikan Model City sudah diupdate ke V2 (id & name)
import 'rajaongkir_repository.dart';

class CekOngkirPage extends StatefulWidget {
  const CekOngkirPage({super.key});

  @override
  State<CekOngkirPage> createState() => _CekOngkirPageState();
}

class _CekOngkirPageState extends State<CekOngkirPage> {
  // Repository
  final RajaOngkirRepository _repository = RajaOngkirRepository();

  // Variabel Pilihan User
  City? _selectedOrigin;
  City? _selectedDestination;
  String _selectedCourier = 'jne'; // Default JNE
  final TextEditingController _weightController = TextEditingController(text: '1000'); // Default 1kg

  // Variabel Hasil
  List<dynamic> _shippingCosts = [];
  bool _isLoading = false;

  // Fungsi Panggil API Cek Ongkir
  void _cekOngkir() async {
    if (_selectedOrigin == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon pilih lokasi asal & tujuan")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _repository.checkCost(
        // PERUBAHAN V2: Menggunakan .id (int) bukan .cityId
        originId: _selectedOrigin!.id, 
        destinationId: _selectedDestination!.id,
        weight: int.tryParse(_weightController.text) ?? 1000,
        courier: _selectedCourier,
      );

      setState(() {
        _shippingCosts = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cek Ongkir (V2 Komerce)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. DROPDOWN LOKASI ASAL (SEARCH MODE)
            DropdownSearch<City>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                // PENTING: Aktifkan mode online filter agar tidak mencari di lokal
                isFilterOnline: true, 
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Ketik kecamatan/kota (min 3 huruf)...",
                    labelText: "Cari Lokasi",
                  ),
                ),
              ),
              // PENTING: Kirim teks filter ke repository
              asyncItems: (String filter) => _repository.fetchCities(filter),
              
              // Tampilan item di list
              itemAsString: (City u) => u.name, 
              
              // Saat dipilih
              onChanged: (City? data) {
                setState(() => _selectedOrigin = data);
              },
              
              // Dekorasi kotak input
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Lokasi Asal",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 2. DROPDOWN LOKASI TUJUAN (SEARCH MODE)
            DropdownSearch<City>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                isFilterOnline: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Ketik kecamatan/kota (min 3 huruf)...",
                    labelText: "Cari Lokasi",
                  ),
                ),
              ),
              asyncItems: (String filter) => _repository.fetchCities(filter),
              itemAsString: (City u) => u.name,
              onChanged: (City? data) {
                setState(() => _selectedDestination = data);
              },
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Lokasi Tujuan",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 3. BERAT & KURIR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Berat (gram)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCourier,
                    decoration: const InputDecoration(
                      labelText: "Kurir",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'jne', child: Text("JNE")),
                      DropdownMenuItem(value: 'sicepat', child: Text("SiCepat")),
                      DropdownMenuItem(value: 'jnt', child: Text("J&T")),
                      // Note: POS & TIKI kadang tidak ada di Komerce Free, coba JNE dulu
                    ],
                    onChanged: (val) => setState(() => _selectedCourier = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. TOMBOL CEK
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _cekOngkir,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CEK ONGKOS KIRIM"),
              ),
            ),
            const SizedBox(height: 20),

            // 5. HASIL (LIST HARGA)
            Expanded(
              child: _shippingCosts.isEmpty
                  ? const Center(child: Text("Hasil ongkir akan muncul di sini"))
                  : ListView.builder(
                      itemCount: _shippingCosts.length,
                      itemBuilder: (context, index) {
                        final item = _shippingCosts[index];
                        
                        // PERBAIKAN CARA BACA DATA (Sesuai Log Anda)
                        String service = item['service'] ?? '-';
                        String desc = item['description'] ?? '-';
                        int cost = item['cost'] ?? 0;   // Langsung ambil int, bukan list
                        String etd = item['etd'] ?? '-'; // Langsung ambil string

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(Icons.local_shipping, color: Colors.blue),
                            title: Text("$service - $desc",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Estimasi: $etd"), // "4-6 day"
                            trailing: Text(
                              "Rp $cost",
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}