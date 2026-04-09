import 'dart:async';

import 'package:flutter/material.dart';
import 'package:girl_clan/UI/upload_invoice/upload_invoice_screen.dart';
import 'package:girl_clan/UI/client/yearly_invoices_screen.dart';
import 'package:girl_clan/UI/client/notifications_screen.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/services/invoice_session_cache.dart';
import 'package:provider/provider.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  StreamSubscription? _invoiceSub;

  final List<Widget> _screens = [
    const UploadInvoiceScreen(),
    const YearlyInvoicesScreen(),
    const NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startClientInvoicePrefetch());
  }

  void _startClientInvoicePrefetch() {
    if (!mounted) return;
    final auth = Provider.of<AuthServices>(context, listen: false);
    final db = Provider.of<DatabaseServices>(context, listen: false);
    final user = auth.currentUser;
    if (user == null || user.role != UserRole.client) return;

    _invoiceSub?.cancel();
    _invoiceSub = db.streamInvoicesByUser(user.id).listen((list) {
      InvoiceSessionCache.instance.set(user.id, list);
    });
  }

  @override
  void dispose() {
    _invoiceSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      InvoiceSessionCache.instance.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        currentIndex: _currentIndex,
        selectedItemColor: ternaryColor,
        unselectedItemColor: whiteColor,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            activeIcon: Icon(Icons.notifications_active_rounded),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
