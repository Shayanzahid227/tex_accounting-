import 'dart:io';
import 'package:flutter/material.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/core/constants/colors.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: transparentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(invoice.imageUrl), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
