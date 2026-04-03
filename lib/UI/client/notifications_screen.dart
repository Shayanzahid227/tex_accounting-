import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/client/notification_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => NotificationViewModel(
            databaseServices: Provider.of<DatabaseServices>(
                context,
                listen: false),
          )..fetchNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: style20B.copyWith(color: whiteColor),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer<NotificationViewModel>(
          builder: (context, model, child) {
            if (model.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 80.sp,
                      color: greyBorderColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No notifications yet',
                      style: style16B.copyWith(color: greyBorderColor),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check back later for updates from Prime Tax',
                      style: style14.copyWith(color: greyBorderColor.withOpacity(0.8)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => model.fetchNotifications(),
              color: secondaryColor,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: model.notifications.length,
                itemBuilder: (context, index) {
                  final notification = model.notifications[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: whiteColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.sp),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: secondaryColor,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Update from Admin',
                                style: style14B.copyWith(color: secondaryColor),
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, h:mm a').format(notification.timestamp),
                              style: style12.copyWith(color: greyBorderColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          notification.message,
                          style: style16.copyWith(color: whiteColor, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
