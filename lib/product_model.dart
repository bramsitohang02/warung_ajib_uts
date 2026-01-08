class Product {
  final int? id;
  final String name;
  final int price;
  final int stock;       // <-- INI YANG KITA TAMBAHKAN
  final String imagePath;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock, // <-- WAJIB ADA DI CONSTRUCTOR
    required this.imagePath,
    required this.description,
  });

  // --- 1. KHUSUS MYSQL (PHP) ---
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()),
      name: json['nmbrg'] ?? 'Tanpa Nama',
      price: int.tryParse(json['hrgjual'].toString()) ?? 0,
      
      // Ambil stok dari database (jika null anggap 0)
      stock: int.tryParse(json['stok'].toString()) ?? 0, 
      
      imagePath: json['gambar'] ?? '',
      description: json['deskripsi'] ?? '-',
    );
  }

  // --- 2. KHUSUS SQLITE (DatabaseHelper Lama) ---
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      // Ambil stok dari SQLite (jika tidak ada anggap 0)
      stock: map['stock'] != null ? int.parse(map['stock'].toString()) : 0,
      imagePath: map['imagePath'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock, // Simpan stok
      'imagePath': imagePath,
      'description': description,
    };
  }
}