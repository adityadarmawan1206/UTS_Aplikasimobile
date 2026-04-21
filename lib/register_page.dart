import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // State untuk role (Default: Pembeli)
  bool _isSeller = false;

  // Fungsi Register Firebase + Simpan Role ke Firestore
  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar("Semua kolom harus diisi!", Colors.redAccent);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Password tidak cocok!", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buat User di Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Simpan Data Role ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'role': _isSeller
                ? 'penjual'
                : 'pembeli', // Simpan role berdasarkan pilihan
            'createdAt': Timestamp.now(),
          });

      // 3. Kirim Email Verifikasi
      await userCredential.user?.sendEmailVerification();

      if (mounted) {
        _showSnackBar(
          "Pendaftaran ${_isSeller ? 'Penjual' : 'Pembeli'} sukses! Cek email.",
          Colors.green,
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Terjadi kesalahan.";
      if (e.code == 'weak-password') {
        errorMessage = "Password terlalu lemah.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email sudah terdaftar.";
      }
      _showSnackBar(errorMessage, Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image & Overlay (Sama seperti sebelumnya)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://i.ibb.co.com/W4qkjmMp/images.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    // Logo
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black,
                      backgroundImage: NetworkImage(
                        "https://i.ibb.co.com/s9R975Sz/images.jpg",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Judul Dinamis
                    Text(
                      _isSeller ? "BECOME A SELLER" : "JOIN THE TEAM",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Box Input
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hint: "Email Address",
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hint: "Confirm Password",
                            icon: Icons.lock_reset_outlined,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // NOTICE: DAFTAR SEBAGAI PENJUAL (KLIK DISINI)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSeller = !_isSeller; // Toggle role
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: _isSeller
                              ? Colors.orangeAccent.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isSeller
                                ? Colors.orangeAccent
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSeller
                                  ? Icons.check_circle
                                  : Icons.storefront_outlined,
                              color: _isSeller
                                  ? Colors.orangeAccent
                                  : Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isSeller
                                  ? "Terdaftar sebagai Penjual"
                                  : "Ingin berjualan? Daftar sebagai penjual, klik disini",
                              style: TextStyle(
                                color: _isSeller
                                    ? Colors.orangeAccent
                                    : Colors.white70,
                                fontWeight: _isSeller
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Tombol Register
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSeller
                              ? Colors.redAccent
                              : Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                _isSeller
                                    ? "REGISTER AS SELLER"
                                    : "FULL THROTTLE / REGISTER",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Sudah punya akun? Login di sini",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.orangeAccent, size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
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
}
