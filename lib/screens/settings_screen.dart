import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: AppColors.cardBg,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'التنبيهات الإشعارات',
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primaryRed),
          ),
          const SizedBox(height: 10),
          _buildSettingTile(
            icon: Icons.language,
            title: 'لغة التطبيق',
            subtitle: 'العربية',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingTile(
            icon: Icons.security,
            title: 'سياسة الخصوصية والأمان',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'عن التطبيق',
            subtitle: 'إصدار SkipCash 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryRed),
        title: Text(title, style: const TextStyle(color: AppColors.textWhite)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textGrey)) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
        onTap: onTap,
      ),
    );
  }
}
