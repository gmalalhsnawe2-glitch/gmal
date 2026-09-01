import 'dart:convert';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.skipcash.app/v1';

  // محاكاة جلب بيانات المستخدم من السيرفر
  Future<UserModel> fetchUserProfile(String userId) async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير الشبكة
    return UserModel(
      id: userId,
      name: 'جمال الحسناوي',
      email: 'user@skipcash.app',
      points: 1250,
      balance: 12.50,
    );
  }

  // محاكاة إرسال طلب إضافة نقاط التخطي
  Future<bool> addPoints(String userId, int pointsToAdd) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // تم إضافة النقاط بنجاح
  }
}
