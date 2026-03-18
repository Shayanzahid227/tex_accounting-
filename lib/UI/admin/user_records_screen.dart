import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/admin/admin_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/UI/client/my_invoices_screen.dart';
import 'package:provider/provider.dart';

class UserRecordsScreen extends StatefulWidget {
  const UserRecordsScreen({super.key});

  @override
  State<UserRecordsScreen> createState() => _UserRecordsScreenState();
}

class _UserRecordsScreenState extends State<UserRecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminViewModel>(context, listen: false).fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteColor,
      appBar: AppBar(
        title: Text('User Directory', style: style20B),
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, model, child) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: TextField(
                  onChanged: (value) => model.updateSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              Expanded(
                child:
                    model.state == ViewState.busy && model.clients.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : model.clients.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 60.sp,
                                color: greyBorderColor,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No clients found',
                                style: style16N.copyWith(
                                  color: greyBorderColor,
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: model.fetchClients,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            itemCount: model.clients.length,
                            itemBuilder: (context, index) {
                              final user = model.clients[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: blackColor.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 6.h,
                                  ),
                                  leading: Container(
                                    width: 50.sp,
                                    height: 50.sp,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          secondaryColor,
                                          secondaryColor.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.name[0].toUpperCase(),
                                        style: style20B.copyWith(
                                          color: whiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(user.name, style: style16B),
                                  subtitle: Text(
                                    'ID: ${user.uniqueNumber}',
                                    style: style14.copyWith(
                                      color: greyBorderColor,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14.sp,
                                        color: greyBorderColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: redColor,
                                          size: 22.sp,
                                        ),
                                        onPressed:
                                            () => _showDeleteDialog(
                                              context,
                                              model,
                                              user.id,
                                              user.name,
                                            ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MyInvoicesScreen(
                                              userId: user.id,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AdminViewModel model,
    String userId,
    String name,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text('Delete Client', style: style18B),
            content: Text(
              'Are you sure you want to delete account for $name? All invoices will be permanently removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Keep Account',
                  style: style14B.copyWith(color: greyBorderColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  model.deleteClient(userId);
                  Navigator.pop(context);
                },
                child: Text(
                  'Yes, Delete',
                  style: style14B.copyWith(color: redColor),
                ),
              ),
            ],
          ),
    );
  }
}
