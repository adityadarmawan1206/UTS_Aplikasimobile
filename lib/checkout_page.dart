import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  // Menerima list berisi map data barang
  final List<Map<String, dynamic>> checkoutItems;

  const CheckoutPage({super.key, required this.checkoutItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Transfer Bank';
  final int _shippingCost = 15000; // Contoh Ongkir Flat
  bool _isLoading = false;

  int _parsePrice(String priceStr) {
    String cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  Future<void> _processOrder() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    String buyerName = user?.email?.split('@')[0] ?? 'Pembeli';

    try {
      for (var item in widget.checkoutItems) {
        int qty = item['quantity'] ?? 1;
        int priceInt = _parsePrice(item['price'] ?? '0');
        int total = priceInt * qty;

        // 1. Masukkan ke tabel transactions
        await FirebaseFirestore.instance.collection('transactions').add({
          'buyerId': user?.uid,
          'buyerName': buyerName,
          'productId': item['productId'],
          'productName': item['productName'],
          'quantity': qty,
          'totalPrice': 'Rp $total', // Harga barang
          'status': 'Menunggu',
          'paymentMethod': _selectedPayment,
          'createdAt': Timestamp.now(),
        });

        // 2. Jika asalnya dari keranjang, hapus dari keranjang setelah dicheckout
        if (item.containsKey('cartId')) {
          await FirebaseFirestore.instance
              .collection('carts')
              .doc(item['cartId'])
              .delete();
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan berhasil dibuat! 🚀"),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman paling awal (Dashboard)
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memproses pesanan: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = 0;
    for (var item in widget.checkoutItems) {
      int qty = item['quantity'] ?? 1;
      int price = _parsePrice(item['price'] ?? '0');
      subtotal += (price * qty);
    }
    int grandTotal = subtotal + _shippingCost;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "CHECKOUT",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Alamat Pengiriman (Mockup)
            const Text(
              "Alamat Pengiriman",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orangeAccent),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rumah - Budi",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Jl. Sudirman No. 123, Jakarta Pusat, DKI Jakarta. 10220",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 2. Daftar Barang
            const Text(
              "Pesanan Kamu",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.checkoutItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(item['imageUrl'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item['price'] ?? '',
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "x${item['quantity']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }),
            const Divider(color: Colors.white24, height: 30),

            // 3. Metode Pembayaran
            const Text(
              "Metode Pembayaran",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text(
                      "Transfer Bank",
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.orangeAccent,
                    value: "Transfer Bank",
                    groupValue: _selectedPayment,
                    onChanged: (val) =>
                        setState(() => _selectedPayment = val.toString()),
                  ),
                  RadioListTile(
                    title: const Text(
                      "E-Wallet (OVO/Dana)",
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.orangeAccent,
                    value: "E-Wallet",
                    groupValue: _selectedPayment,
                    onChanged: (val) =>
                        setState(() => _selectedPayment = val.toString()),
                  ),
                  RadioListTile(
                    title: const Text(
                      "Bayar di Tempat (COD)",
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.orangeAccent,
                    value: "COD",
                    groupValue: _selectedPayment,
                    onChanged: (val) =>
                        setState(() => _selectedPayment = val.toString()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 4. Ringkasan Belanja
            const Text(
              "Ringkasan Belanja",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subtotal Barang",
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  "Rp $subtotal",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ongkos Kirim",
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  "Rp $_shippingCost",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Rp $grandTotal",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Spasi bawah
          ],
        ),
      ),

      // Tombol Buat Pesanan
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: const Color(0xFF1E1E1E),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isLoading ? null : _processOrder,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "BUAT PESANAN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
      ),
    );
  }
}
