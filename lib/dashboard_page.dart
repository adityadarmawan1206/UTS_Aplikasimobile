import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'product_management_page.dart';
import 'profile_tab.dart';
import 'transaction_page.dart'; // <-- Tambahkan import ini

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String userRole = 'pembeli';

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            userRole = doc.data()?['role'] ?? 'pembeli';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // List halaman dasar (Home dan Profile)
    List<Widget> pages = [HomeTab(userRole: userRole), const ProfileTab()];

    // Jika user adalah Penjual, tambahkan halaman Kelola Stok dan Transaksi di tengah
    if (userRole == 'penjual') {
      pages.insert(1, const ProductManagementPage());
      pages.insert(
        2,
        const TransactionPage(),
      ); // <-- Halaman Transaksi ditambahkan
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          if (userRole == 'penjual') ...[
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Kelola Stok',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), // <-- Icon untuk tab Transaksi
              label: 'Transaksi',
            ),
          ],
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
