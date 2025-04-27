import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../logout.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final User? currentUser;
  final bool isLoading;

  const CommonAppBar({
    Key? key,
    required this.title,
    required this.currentUser,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF4796BD),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
          onPressed: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(50, 70, 0, 0),
              items: [
                PopupMenuItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading ? 'Pengguna' : currentUser?.username ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                  onTap: () => showLogoutDialog(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
