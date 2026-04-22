import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  // Fungsi untuk mengonfirmasi pembayaran dan update stok + terjual
  Future<void> _confirmPayment(
    BuildContext context,
    String transactionId,
    String productId,
    int quantity,
  ) async {
    try {
      // 1. Update status transaksi menjadi 'Lunas/Selesai'
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .update({'status': 'Lunas'});

      // 2. Potong stok dan tambah jumlah terjual pada produk menggunakan FieldValue.increment
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
            'stock': FieldValue.increment(
              -quantity,
            ), // Mengurangi stok sesuai jumlah beli
            'soldCount': FieldValue.increment(
              quantity,
            ), // Menambah total terjual
          });

      // Pengecekan ekstra (opsional): Jika setelah dikurangi stok jadi <= 0, ubah isSoldOut jadi true
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productDoc.exists) {
        int currentStock = productDoc.get('stock') ?? 0;
        if (currentStock <= 0) {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({'isSoldOut': true});
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pembayaran Berhasil Dikonfirmasi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "KONFIRMASI PESANAN",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Stream membaca koleksi 'transactions' yang statusnya masih 'Menunggu'
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where(
              'status',
              isEqualTo: 'Menunggu',
            ) // Filter pesanan yang belum lunas
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada pesanan baru",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var t = docs[index];
              Map<String, dynamic> data = t.data() as Map<String, dynamic>;

              String productId = data['productId'] ?? '';
              int qty = data['quantity'] ?? 1;
              String buyerName = data['buyerName'] ?? 'Pembeli';

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    "Pesanan: ${data['productName'] ?? 'Barang'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Pembeli: $buyerName\nJumlah: $qty | Total: ${data['totalPrice'] ?? 'Rp -'}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () =>
                        _confirmPayment(context, t.id, productId, qty),
                    child: const Text(
                      "KONFIRMASI",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
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
