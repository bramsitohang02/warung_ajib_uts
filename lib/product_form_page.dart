import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Wajib ada untuk galeri
import 'package:project_uas/product_model.dart';
import 'package:project_uas/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller Text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  // Variabel Gambar
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Isi data jika mode Edit
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descController.text = widget.product!.description;
    }
  }

  // FUNGSI BUKA GALERI
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Tambah Produk (Upload)" : "Edit Produk"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. AREA KOTAK GAMBAR (Pengganti Input URL)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : (widget.product != null && widget.product!.imagePath.isNotEmpty)
                          ? Image.network(
                              widget.product!.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => 
                                  const Center(child: Icon(Icons.broken_image, size: 50)),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text("Klik untuk Pilih Gambar"),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. INPUT DATA
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // 3. TOMBOL UPLOAD
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sedang mengupload...")),
                      );

                      Product newProduct = Product(
                        id: widget.product?.id,
                        name: _nameController.text,
                        price: int.parse(_priceController.text),
                        description: _descController.text,
                        imagePath: '', // Nanti diisi server
                        stock: 10,
                      );

                      ProductRepository repo = ProductRepository();
                      bool sukses = await repo.addProduct(newProduct, _selectedImage);

                      if (sukses) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sukses Upload!")),
                        );
                        Navigator.pop(context, true);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Gagal Upload")),
                        );
                      }
                    }
                  },
                  child: const Text("UPLOAD & SIMPAN"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}