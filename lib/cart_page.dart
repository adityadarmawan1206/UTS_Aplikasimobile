import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;

  // Menyimpan ID dokumen keranjang yang diceklis
  List<String> _selectedCartIds = [];

  // Data sementara untuk menghitung total harga
  Map<String, int> _cartPrices = {};

  // Mengubah String "Rp 50.000" menjadi angka int 50000
  int _parsePrice(String priceStr) {
    String cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  // Fungsi Hapus Barang
  Future<void> _deleteCartItem(String cartId) async {
    await FirebaseFirestore.instance.collection('carts').doc(cartId).delete();
    setState(() {
      _selectedCartIds.remove(cartId);
      _cartPrices.remove(cartId);
    });
  }

  // Fungsi Checkout Barang yang diceklis
  Future<void> _checkoutSelectedItems() async {
    if (_selectedCartIds.isEmpty) return;

    try {
      String buyerName = user?.email?.split('@')[0] ?? 'Pembeli';

      // Loop semua barang yang diceklis
      for (String cartId in _selectedCartIds) {
        DocumentSnapshot cartDoc = await FirebaseFirestore.instance
            .collection('carts')
            .doc(cartId)
            .get();
        if (cartDoc.exists) {
          var data = cartDoc.data() as Map<String, dynamic>;
          int qty = data['quantity'] ?? 1;
          int priceInt = _parsePrice(data['price'] ?? '0');
          int total = priceInt * qty;

          // 1. Pindahkan ke koleksi transactions (Menunggu konfirmasi penjual)
          await FirebaseFirestore.instance.collection('transactions').add({
            'buyerId': user?.uid,
            'buyerName': buyerName,
            'productId': data['productId'],
            'productName': data['productName'],
            'quantity': qty,
            'totalPrice': 'Rp $total',
            'status': 'Menunggu', // Sesuai dengan transaction_page.dart penjual
            'createdAt': Timestamp.now(),
          });

          // 2. Hapus dari keranjang
          await _deleteCartItem(cartId);
        }
      }

      setState(() {
        _selectedCartIds.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Checkout Berhasil! Menunggu Konfirmasi Penjual."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Checkout Gagal: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung total harga dari item yang diceklis
    int grandTotal = 0;
    for (String id in _selectedCartIds) {
      grandTotal += _cartPrices[id] ?? 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "KERANJANG SAYA",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: Text(
                "Silakan login terlebih dahulu",
                style: TextStyle(color: Colors.white),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .where('userId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                    ),
                  );

                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Keranjangmu masih kosong!",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ), // Spasi untuk bottomSheet
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var cart = docs[index];
                    var data = cart.data() as Map<String, dynamic>;
                    String cartId = cart.id;

                    int qty = data['quantity'] ?? 1;
                    int price = _parsePrice(data['price'] ?? '0');

                    // Simpan data harga untuk kalkulasi grand total
                    _cartPrices[cartId] = price * qty;
                    bool isChecked = _selectedCartIds.contains(cartId);

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: Colors.orangeAccent,
                            checkColor: Colors.black,
                            side: const BorderSide(color: Colors.orangeAccent),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCartIds.add(cartId);
                                } else {
                                  _selectedCartIds.remove(cartId);
                                }
                              });
                            },
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(data['imageUrl'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['productName'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  data['price'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                Text(
                                  "Qty: $qty",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteCartItem(cartId),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: const Color(0xFF1E1E1E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Bayar:",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  "Rp $grandTotal",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCartIds.isEmpty
                    ? Colors.grey
                    : Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _selectedCartIds.isEmpty
                  ? null
                  : _checkoutSelectedItems,
              child: Text(
                "CHECKOUT (${_selectedCartIds.length})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
