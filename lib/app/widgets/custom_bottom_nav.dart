import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavIndexChanged;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onNavIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: currentIndex == 0
                  ? ThemeConstants.primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              onNavIndexChanged(0);
              Get.toNamed(AppRoutes.HOME);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.category,
              color: currentIndex == 1
                  ? ThemeConstants.primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              onNavIndexChanged(1);
              Get.toNamed(AppRoutes.EXPENSE_LIST);
            },
          ),
          const SizedBox(width: 48), // Пространство для FloatingActionButton
          IconButton(
            icon: Icon(
              Icons.account_balance_wallet,
              color: currentIndex == 2
                  ? ThemeConstants.primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              onNavIndexChanged(2);
              Get.toNamed(AppRoutes.FINANCE);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: currentIndex == 3
                  ? ThemeConstants.primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              onNavIndexChanged(3);
              Get.toNamed(AppRoutes.SETTINGS);
            },
          ),
        ],
      ),
    );
  }
}