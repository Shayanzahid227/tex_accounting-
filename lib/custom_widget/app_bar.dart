import 'package:flutter/material.dart';
import 'package:girl_clan/core/constants/app_assets.dart';
import 'package:girl_clan/core/constants/text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showEdit;
  final VoidCallback? onEditTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showEdit = false,
    this.onEditTap,
  }) : assert(
         showEdit == false || onEditTap != null,
         'If showEdit is true, onEditTap must not be null',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_outlined),
          ),
        ),
      ),
      centerTitle: false,
      title: Text(title, style: style25B.copyWith(fontSize: 22)),
      actions:
          showEdit
              ? [
                IconButton(
                  icon: Image.asset(
                    AppAssets().editIcon,
                    scale: 4,
                    color: Colors.blue, // Replace with primaryColor
                  ),
                  onPressed: onEditTap,
                ),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
