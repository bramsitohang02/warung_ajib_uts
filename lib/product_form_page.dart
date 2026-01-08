import 'package:flutter/material.dart';
import 'package:warung_ajib_uts/database_helper.dart';
import 'package:warung_ajib_uts/product_model.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedImage = 'assets/images/esteh.jpeg'; 

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi form dengan data lama
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descController.text = widget.product!.description;
      _selectedImage = widget.product!.imagePath;
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = int.parse(_priceController.text);
      final desc = _descController.text;

      if (widget.product == null) {
        // --- LOGIKA TAMBAH BARU ---
        final newProduct = Product(
          name: name, price: price, imagePath: _selectedImage, description: desc
        );
        await DatabaseHelper.instance.create(newProduct);
      } else {
        // --- LOGIKA UPDATE ---
        final updatedProduct = Product(
          id: widget.product!.id, // ID lama wajib dibawa
          name: name, price: price, imagePath: _selectedImage, description: desc
        );
        await DatabaseHelper.instance.update(updatedProduct);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan!')),
      );
      Navigator.pop(context, true); // Kembali & kirim sinyal refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Tambah Produk" : "Edit Produk"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}