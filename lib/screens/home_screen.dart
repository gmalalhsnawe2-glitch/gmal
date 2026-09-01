import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'wallet_screen.dart';
import 'settings_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboard(),
    const WalletScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SkipCash | سكيب كاش', style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: AppColors.cardBg,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_display_rounded, size: 100, color: AppColors.primaryRed),
              const SizedBox(height: 20),
              const Text(
                'خدمة التخطي الآلي مفعلة',
                style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'قم بتشغيل الفيديو لتكسب النقاط تلقائياً',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.power_settings_new, color: AppColors.textWhite),
                label: const Text('بدء التشغيل', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
