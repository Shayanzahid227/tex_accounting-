import 'package:flutter/material.dart';
import 'package:girl_clan/UI/upload_invoice/upload_invoice_screen.dart';
import 'package:girl_clan/UI/client/my_invoices_screen.dart';
import 'package:girl_clan/core/constants/colors.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UploadInvoiceScreen(),
    const MyInvoicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'My Invoices',
          ),
        ],
      ),
    );
  }
}
