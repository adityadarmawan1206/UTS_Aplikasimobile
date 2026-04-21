import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  String _selectedCategory = 'Mesin'; // Default kategori
  bool _isLoading = false;

  final List<String> _categories = ['Mesin', 'Oli', 'Ban', 'Lampu', 'Tools'];

  Future<void> _uploadProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data harus diisi!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Menambah data ke Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'price': "Rp ${_priceController.text.trim()}",
        'imageUrl': _imageController.text.trim(),
        'category': _selectedCategory,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk Berhasil Masuk Garasi!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke Dashboard
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "ADD NEW SPAREPART",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icon Header
            const Icon(
              Icons.add_box_outlined,
              size: 80,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildInputLabel("Nama Barang"),
                  _buildTextField(
                    _nameController,
                    "Contoh: Knalpot Racing",
                    Icons.shopping_bag_outlined,
                  ),

                  const SizedBox(height: 20),
                  _buildInputLabel("Harga (Angka Saja)"),
                  _buildTextField(
                    _priceController,
                    "Contoh: 1500000",
                    Icons.payments_outlined,
                    isNumber: true,
                  ),

                  const SizedBox(height: 20),
                  _buildInputLabel("Link Foto Barang"),
                  _buildTextField(
                    _imageController,
                    "https://link-gambar.com/foto.jpg",
                    Icons.image_outlined,
                  ),

                  const SizedBox(height: 20),
                  _buildInputLabel("Kategori"),
                  _buildDropdown(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "INPUT KE DATABASE",
                        style: TextStyle(
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

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orangeAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          dropdownColor: Colors.black,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items: _categories.map((String category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }
}
