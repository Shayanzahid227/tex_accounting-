import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/core/constants/colors.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String tag;
  final bool isNetwork;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.tag,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close_rounded, color: whiteColor, size: 24.sp),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child:
                isNetwork
                    ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: whiteColor),
                        );
                      },
                      errorBuilder: (context, error, stack) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: whiteColor,
                            size: 64,
                          ),
                        );
                      },
                    )
                    : Image.file(
                      File(imageUrl),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
          ),
        ),
      ),
    );
  }
}
