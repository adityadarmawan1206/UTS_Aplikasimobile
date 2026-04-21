import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_product_page.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  // Fungsi Hapus
  void _deleteProduct(String id) {
    FirebaseFirestore.instance.collection('products').doc(id).delete();
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
        title: const Text("KELOLA STOK BARANG", style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductPage()),
            ),
            icon: const Icon(Icons.add_box, color: Colors.orangeAccent),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var p = data[index];
              bool isSold = p['isSoldOut'] ?? false;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      p['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    p['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    p['price'],
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isSold
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.green,
                        ),
                        onPressed: () => _toggleSold(p.id, isSold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteProduct(p.id),
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
