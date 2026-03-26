import 'package:flutter/material.dart';
import 'package:girl_clan/UI/admin/admin_view_model.dart';
import 'package:girl_clan/UI/admin/create_account_screen.dart';
import 'package:girl_clan/UI/admin/user_records_screen.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:provider/provider.dart';

class AdminRootScreen extends StatefulWidget {
  const AdminRootScreen({super.key});

  @override
  State<AdminRootScreen> createState() => _AdminRootScreenState();
}

class _AdminRootScreenState extends State<AdminRootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CreateAccountScreen(),
    const UserRecordsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => AdminViewModel(
            databaseServices: Provider.of<DatabaseServices>(
              context,
              listen: false,
            ),
          ),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
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
              icon: Icon(Icons.person_add),
              label: 'Create Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: 'User Records',
            ),
          ],
        ),
      ),
    );
  }
}
