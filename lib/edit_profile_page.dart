import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;

  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(
      text: widget.userData['username'] ?? '',
    );
    _fullNameCtrl = TextEditingController(
      text: widget.userData['fullName'] ?? '',
    );
    _phoneCtrl = TextEditingController(text: widget.userData['phone'] ?? '');
    _dobCtrl = TextEditingController(text: widget.userData['dob'] ?? '');

    // Set gender awal jika sudah ada
    String? currentGender = widget.userData['gender'];
    if (currentGender == 'Laki-laki' || currentGender == 'Perempuan') {
      _selectedGender = currentGender;
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default tahun
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orangeAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format manual YYYY-MM-DD
        _dobCtrl.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Simpan data ke Firestore (SetOptions(merge: true) agar tidak menghapus data lain)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': _usernameCtrl.text.trim(),
          'fullName': _fullNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'dob': _dobCtrl.text.trim(),
          'gender': _selectedGender,
          'email': user.email, // Pastikan email juga tersimpan
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil berhasil diperbarui! 🎉"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Kembali ke ProfileTab
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "UBAH PROFIL",
          style: TextStyle(color: Colors.orangeAccent),
        ),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Username"),
              _buildTextField(
                _usernameCtrl,
                Icons.person_outline,
                "Masukkan username",
                true,
              ),

              _buildLabel("Nama Lengkap"),
              _buildTextField(
                _fullNameCtrl,
                Icons.badge_outlined,
                "Masukkan nama sesuai KTP",
                true,
              ),

              _buildLabel("Jenis Kelamin"),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle(Icons.wc),
                items: ['Laki-laki', 'Perempuan'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedGender = newValue),
                validator: (value) =>
                    value == null ? "Pilih jenis kelamin" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("Tanggal Lahir"),
              TextFormField(
                controller: _dobCtrl,
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle(Icons.calendar_today),
                onTap: () => _selectDate(context),
                validator: (value) =>
                    value!.isEmpty ? "Pilih tanggal lahir" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("No. Telepon / WhatsApp"),
              _buildTextField(
                _phoneCtrl,
                Icons.phone_android,
                "Contoh: 08123456789",
                true,
                isNumber: true,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
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
                          "SIMPAN PROFIL",
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
      ),
    );
  }

  // Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper untuk TextField
  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint,
    bool isRequired, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: _inputStyle(icon).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return "Form ini wajib diisi";
        }
        return null;
      },
    );
  }

  // Helper untuk Input Decoration
  InputDecoration _inputStyle(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.orangeAccent),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
