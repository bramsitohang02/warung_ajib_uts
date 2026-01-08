import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Controller untuk setiap text field
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true; // Untuk status loading

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memuat data saat halaman dibuka
    _loadUserData();
  }

  // Fungsi untuk mengambil data dari SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data, jika null (??) gunakan string kosong
    String nama = prefs.getString('namaLengkap') ?? '';
    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';

    // Set teks di controller
    setState(() {
      _namaController.text = nama;
      _usernameController.text = username;
      _passwordController.text = password;
      _isLoading = false; // Hentikan loading
    });
  }

  // Fungsi untuk menyimpan data baru
  Future<void> _updateUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan data baru dari controller
    await prefs.setString('namaLengkap', _namaController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);

    // Tampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data berhasil diperbarui!')),
    );

    // Kembali ke halaman dashboard
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Bersihkan controller
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update User & Password"),
      ),
      // Tampilkan loading spinner selagi data diambil
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sesuai layout [cite: 126, 127, 132]
                  Text(
                    "User",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Sesuai layout [cite: 133, 134]
                  Text(
                    "Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Sembunyikan password
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Tambahan: Form untuk Nama Lengkap
                  Text(
                    "Nama Lengkap",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Tombol Update & Cancel [cite: 135, 136]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updateUserData,
                        child: Text("Update"), // 
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Kembali
                        },
                        child: Text("Cancel"), // [cite: 136]
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}