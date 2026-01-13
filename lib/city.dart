class City {
  int id;          // ID Lokasi (Kecamatan/Subdistrict)
  String name;     // Label lengkap (misal: "Gambir, Jakarta Pusat, DKI Jakarta")

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      // Di API V2, id berupa integer, bukan string string
      id: json['id'],
      // Di API V2, nama lokasi ada di field 'label'
      name: json['label'] ?? json['city_name'] ?? 'Unknown',
    );
  }

  @override
  String toString() => name; // Agar muncul cantik di Dropdown
}