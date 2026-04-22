import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_product_page.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  // Fungsi Konfirmasi Hapus Barang
  void _confirmDelete(BuildContext context, String id, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Hapus Barang?", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            "Yakin mau menghapus '$productName' dari garasi? Data yang dihapus tidak bisa dikembalikan.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "BATAL",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(id)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Barang berhasil dihapus"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text("HAPUS"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi Tandai Habis
  void _toggleSold(String id, bool current) {
    FirebaseFirestore.instance.collection('products').doc(id).update({
      'isSoldOut': !current,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "MANAJEMEN STOK",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.orangeAccent,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      // --- TOMBOL TAMBAH BARANG (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_box, size: 24),
        label: const Text(
          "TAMBAH BARANG",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddProductPage()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );

          var data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Garasi masih kosong",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 100,
              top: 10,
            ), // Padding bawah agar tidak ketutup FAB
            itemCount: data.length,
            itemBuilder: (context, index) {
              var p = data[index];

              // Safe Access Data (Mencegah Eror)
              final Map<String, dynamic> productData =
                  p.data() as Map<String, dynamic>;
              bool isSold = productData.containsKey('isSoldOut')
                  ? productData['isSoldOut']
                  : false;
              String name = productData['name'] ?? 'Tanpa Nama';
              String price = productData['price'] ?? 'Rp -';
              String imageUrl = productData['imageUrl'] ?? '';
              String category = productData['category'] ?? 'Lainnya';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSold
                        ? Colors.redAccent.withOpacity(0.3)
                        : Colors.white10,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // --- GAMBAR BARANG ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ColorFiltered(
                          colorFilter: isSold
                              ? const ColorFilter.mode(
                                  Colors.black54,
                                  BlendMode.darken,
                                )
                              : const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                ),
                          child: Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // --- DETAIL BARANG ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kategori Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.orangeAccent.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              style: TextStyle(
                                color: isSold ? Colors.white54 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              price,
                              style: TextStyle(
                                color: isSold
                                    ? Colors.white38
                                    : Colors.greenAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- TOMBOL AKSI ---
                      Column(
                        children: [
                          // Toggle Status Habis/Tersedia
                          GestureDetector(
                            onTap: () => _toggleSold(p.id, isSold),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSold
                                    ? Colors.redAccent.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSold
                                      ? Colors.redAccent
                                      : Colors.green,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSold ? Icons.cancel : Icons.check_circle,
                                    size: 14,
                                    color: isSold
                                        ? Colors.redAccent
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSold ? "HABIS" : "READY",
                                    style: TextStyle(
                                      color: isSold
                                          ? Colors.redAccent
                                          : Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tombol Hapus
                          InkWell(
                            onTap: () => _confirmDelete(context, p.id, name),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
