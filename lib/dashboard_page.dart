import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user yang sedang login
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              // Fungsi Logout
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Selamat Datang
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Selamat Datang!'),
                subtitle: Text(user?.email ?? 'User Email'),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Kategori Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Contoh Grid Menu/Kategori
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildMenuItem(Icons.laptop, 'Elektronik', Colors.orange),
                _buildMenuItem(Icons.checkroom, 'Fashion', Colors.pink),
                _buildMenuItem(Icons.home, 'Rumah Tangga', Colors.green),
                _buildMenuItem(Icons.fastfood, 'Makanan', Colors.red),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Aktivitas Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.blue),
              title: Text('Pesanan #12345'),
              subtitle: Text('Sedang Dikirim'),
              trailing: Text('Rp 150.000'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pendukung untuk item menu
  Widget _buildMenuItem(IconData icon, String title, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Tambahkan navigasi ke halaman kategori di sini
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
