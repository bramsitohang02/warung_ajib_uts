import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:project_uas/city.dart';
import 'package:project_uas/rajaongkir_repository.dart';
import 'package:project_uas/payment_page.dart';

class CheckoutPage extends StatefulWidget {
  final int productTotal;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.productTotal, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final RajaOngkirRepository _repository = RajaOngkirRepository();
  City? _selectedOrigin;
  City? _selectedDestination;
  String _selectedCourier = 'jne'; // Default
  int _totalWeight = 0;
  List<dynamic> _shippingCosts = [];
  int _selectedShippingCost = 0;
  String _paymentMethod = 'manual';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateTotalWeight();
  }

  void _calculateTotalWeight() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item['berat'] as int);
    }
    setState(() => _totalWeight = total > 0 ? total : 1000);
  }

  void _cekOngkir() async {
    if (_selectedOrigin == null || _selectedDestination == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await _repository.checkCost(
        originId: _selectedOrigin!.id,
        destinationId: _selectedDestination!.id,
        weight: _totalWeight,
        courier: _selectedCourier,
      );
      setState(() {
        _shippingCosts = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _processOrder() async {
    if (_selectedShippingCost == 0) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih ongkir dulu!")));
       return;
    }
    setState(() => _isLoading = true);
    int grandTotal = widget.productTotal + _selectedShippingCost;

    try {
      // Pastikan IP ini sesuai dengan Laptop Anda (192.168.1.13)
      final response = await http.post(
        Uri.parse("http://192.168.1.13/warung_api_uas/transaksi.php"),
        body: jsonEncode({
          "id_user": "1", // Sementara Hardcode
          "total_bayar": grandTotal,
          "metode_pembayaran": _paymentMethod,
          "items": widget.cartItems
        }),
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        if (_paymentMethod == 'midtrans') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentPage(totalPrice: grandTotal)));
        } else {
          // Dialog Sukses Manual
          showDialog(
            context: context, 
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Order Berhasil"),
              content: Text("ID Transaksi: #${data['id_jual']}\nSilakan cek menu Riwayat untuk upload bukti bayar."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // 1. Tutup Dialog Popup
                    // 2. Tutup Halaman Checkout DAN kirim sinyal 'true' ke Dashboard
                    // (Ini yang membuat Total di Dashboard jadi 0)
                    Navigator.pop(context, true); 
                  }, 
                  child: const Text("OK")
                )
              ]
            )
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // DROPDOWN LOKASI
          DropdownSearch<City>(
            popupProps: const PopupProps.menu(showSearchBox: true, isFilterOnline: true),
            asyncItems: (String filter) => _repository.fetchCities(filter),
            itemAsString: (City u) => u.name,
            onChanged: (data) => setState(() => _selectedOrigin = data),
            dropdownDecoratorProps: const DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(labelText: "Asal", border: OutlineInputBorder())),
          ),
          const SizedBox(height: 10),
          DropdownSearch<City>(
            popupProps: const PopupProps.menu(showSearchBox: true, isFilterOnline: true),
            asyncItems: (String filter) => _repository.fetchCities(filter),
            itemAsString: (City u) => u.name,
            onChanged: (data) => setState(() => _selectedDestination = data),
            dropdownDecoratorProps: const DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(labelText: "Tujuan", border: OutlineInputBorder())),
          ),
          const SizedBox(height: 10),
          
          // PILIHAN KURIR
          DropdownButtonFormField<String>(
            value: _selectedCourier,
            decoration: const InputDecoration(labelText: "Pilih Jasa Kirim", border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'jne', child: Text("JNE")),
              DropdownMenuItem(value: 'pos', child: Text("POS Indonesia")),
              DropdownMenuItem(value: 'tiki', child: Text("TIKI")),
            ],
            onChanged: (val) => setState(() => _selectedCourier = val!),
          ),
          const SizedBox(height: 10),

          ElevatedButton(onPressed: _cekOngkir, child: const Text("CEK ONGKIR")),
          
          // HASIL ONGKIR
          if (_shippingCosts.isNotEmpty) 
             ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _shippingCosts.length,
                itemBuilder: (context, index) {
                  final item = _shippingCosts[index];
                  int cost = item['cost'] ?? 0;
                  return Card(
                    color: (cost == _selectedShippingCost) ? Colors.green[100] : null,
                    child: ListTile(
                      onTap: () => setState(() => _selectedShippingCost = cost),
                      title: Text("${item['service']} - Rp $cost"),
                    ),
                  );
                },
              ),
          
          const Divider(),
          const Text("Metode Bayar:", style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile(title: const Text("Transfer Manual"), value: 'manual', groupValue: _paymentMethod, onChanged: (val) => setState(() => _paymentMethod = val.toString())),
          RadioListTile(title: const Text("Midtrans"), value: 'midtrans', groupValue: _paymentMethod, onChanged: (val) => setState(() => _paymentMethod = val.toString())),
          
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _processOrder, child: const Text("BUAT PESANAN"))),
        ]),
      ),
    );
  }
}