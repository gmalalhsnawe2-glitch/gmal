import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('محفظة النقاط والأرباح', style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: AppColors.cardBg,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('رصيد النقاط الحالي', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('1,250 نقطة', style: TextStyle(color: AppColors.accentGold, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('القيمة التقديرية: \$12.50', style: TextStyle(color: AppColors.textWhite.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('طلب سحب الأرباح قيد المعالجة')),
                );
              },
              child: const Text('سحب الأرباح', style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
