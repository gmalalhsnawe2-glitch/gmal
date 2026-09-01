import os
import time

# نظام محاكاة مشاهدة الفيديوهات واحتساب النقاط
class RewardSystem:
    def __init__(self):
        self.points = 0
        self.reward_per_video = 10

    def watch_video_ad(self):
        print("🎬 جاري عرض إعلان الفيديو للمستخدم...")
        time.sleep(2) # محاكاة وقت المشاهدة
        self.points += self.reward_per_video
        print(f"✅ تم إكمال المشاهدة بنجاح! تم إضافة {self.reward_per_video} نقاط.")
        print(f"💰 مجموع النقاط الحالي: {self.points} نقطة\n")

if __name__ == "__main__":
    print("=== بدء نظام الأرباح ومشاهدة الإعلانات ===")
    app = RewardSystem()
    
    # محاكاة 3 مشاهدات متتالية
    for i in range(1, 4):
        print(f"--- المشاهدة رقم {i} ---")
        app.watch_video_ad()
        
    print("=== تم حفظ البيانات وتحديث الرصيد بنجاح ===")
