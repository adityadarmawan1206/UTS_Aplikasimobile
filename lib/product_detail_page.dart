import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  Widget build(BuildContext context) {
    int stock = productData['stock'] ?? 0;
    String description =
        productData['description'] ?? 'Tidak ada deskripsi untuk produk ini.';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "DETAIL PRODUK",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Produk
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(color: Colors.white),
              child: Image.network(
                productData['imageUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Harga & Nama Barang
                  Text(
                    productData['price'] ?? 'Rp 0',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productData['name'] ?? 'Nama Produk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 3. Info Kategori & Stok
                  Row(
                    children: [
                      Chip(
                        backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                        label: Text(
                          productData['category'] ?? 'Lainnya',
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                        side: BorderSide.none,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Stok: $stock",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "| Terjual: ${productData['soldCount'] ?? 0}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 40),

                  // 4. Profil Penjual (Mockup)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(
                          Icons.storefront,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Toko Sparepart Jaya",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Online • Kota Cilegon",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orangeAccent,
                          side: const BorderSide(color: Colors.orangeAccent),
                        ),
                        child: const Text("Kunjungi"),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 40),

                  // 5. Deskripsi Produk
                  const Text(
                    "Deskripsi Produk",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(
                    height: 80,
                  ), // Spasi kosong bawah biar ngga ketutup tombol
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. Tombol Bawah (Bottom Navigation khusus Checkout)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: const Color(0xFF1E1E1E),
        child: Row(
          children: [
            // Tombol Keranjang
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.orangeAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Dimasukkan ke Keranjang! 🛒"),
                    ),
                  );
                },
                child: const Icon(
                  Icons.add_shopping_cart,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Tombol Checkout
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: stock > 0
                    ? () {
                        // Nanti fungsi arahkan ke halaman Payment di sini
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lanjut ke Pembayaran... 💳"),
                          ),
                        );
                      }
                    : null, // Disable jika stok habis
                child: Text(
                  stock > 0 ? "BELI SEKARANG" : "STOK HABIS",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
