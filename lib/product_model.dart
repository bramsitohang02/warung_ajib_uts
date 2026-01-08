class Product {
  final int? id;
  final String name;
  final int price;
  final String imagePath;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imagePath: map['imagePath'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'description': description,
    };
  }
}