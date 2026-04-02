import os

file_path = r'c:\src\flutter-apps\edunova_application\lib\l10n\app_localizations.dart'

# We'll try common encodings
encodings = ['utf-8', 'utf-16', 'cp1256', 'iso-8859-1']
content = None

for enc in encodings:
    try:
        with open(file_path, 'r', encoding=enc) as f:
            content = f.read()
            print(f"Successfully read with {enc}")
            break
    except Exception:
        continue

if content is None:
    # Fallback with errors='ignore'
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        print("Read with utf-8 (errors ignored)")

# EN replacement
old_en = "'activity_unknown': 'New activity',"
new_en = """'activity_unknown': 'New activity',
      'hello': 'Hello',
      'rank_label': 'Rank',
      'pts': 'pts',
      'loading': 'Loading...',
      'rank_pending': 'Rank Pending',
      'score_pending': 'Score Pending',
      'no_ranking_data': 'No ranking data yet',
      'years_exp_label': 'Years Experience',
      'contact_button': 'Contact',
      'no_lecturers_found': 'No lecturers found for your stage.',
      'coming_soon': 'Coming soon!',
      'enter_field': 'Please enter {field}',
      'error_email_valid': 'Please enter a valid email',
      'error_password_length': 'Password must be at least 8 characters',
      'error_password_match': 'Passwords do not match',
      'retry': 'Retry',
      'no_recent_activity': 'No recent activity',
      'edit_experience': 'Edit Experience',
      'no_description': 'No description available.',
      'no_courses_yet': 'No courses available yet.',
      'feedback_perfect': 'Perfect! Outstanding performance!',
      'feedback_great': 'Great job! Excellent performance!',
      'feedback_good': 'Good effort! You can improve even more.',
      'feedback_push': 'Keep pushing forward!',"""
content = content.replace(old_en, new_en)

# AR replacement
old_ar = "'activity_unknown': 'نشاط جديد',"
new_ar = """'activity_unknown': 'نشاط جديد',
      'hello': 'مرحباً',
      'rank_label': 'المرتبة',
      'pts': 'نقطة',
      'loading': 'جاري التحميل...',
      'rank_pending': 'المرتبة قيد الانتظار',
      'score_pending': 'الدرجة قيد الانتظار',
      'no_ranking_data': 'لا يوجد بيانات تصنيف بعد',
      'years_exp_label': 'سنوات خبرة',
      'contact_button': 'تواصل',
      'no_lecturers_found': 'لم يتم العثور على محاضرين لمرحلتك.',
      'coming_soon': 'قريباً!',
      'enter_field': 'يرجى إدخال {field}',
      'error_email_valid': 'يرجى إدخال بريد إلكتروني صحيح',
      'error_password_length': 'يجب أن تكون كلمة المرور 8 رموز على الأقل',
      'error_password_match': 'كلمات المرور غير متطابقة',
      'retry': 'إعادة المحاولة',
      'no_recent_activity': 'لا يوجد نشاط حديث',
      'edit_experience': 'تعديل الخبرة',
      'no_description': 'لا يوجد وصف متاح.',
      'no_courses_yet': 'لا توجد دورات متاحة بعد.',
      'feedback_perfect': 'ممتاز! أداء متميز!',
      'feedback_great': 'عمل رائع! أداء ممتاز!',
      'feedback_good': 'جهد جيد! يمكنك التحسن أكثر.',
      'feedback_push': 'استمر في التقدم للأمام!',"""
content = content.replace(old_ar, new_ar)

# CKB replacement
old_ckb_pattern = "'lecturer_ai_response': 'ئەوە ئەوەندە سەرنجڕاکێشە! دەتوانم یارمەتیت بدەم لە ڕێکخستنی ئەو ماددە یان خشتەی کویزەکەی داهاتوو.',"
new_ckb = """'lecturer_ai_response': 'ئەوە ئەوەندە سەرنجڕاکێشە! دەتوانم یارمەتیت بدەم لە ڕێکخستنی ئەو ماددە یان خشتەی کویزەکەی داهاتوو.',
      'hello': 'سڵاو',
      'rank_label': 'ڕیزبەندی',
      'pts': 'خاڵ',
      'loading': 'بارکردن...',
      'rank_pending': 'ڕیزبەندی چاوەڕوانکراوە',
      'score_pending': 'نمرە چاوەڕوانکراوە',
      'no_ranking_data': 'هیچ زانیارییەکی ڕیزبەندی نییە',
      'years_exp_label': 'ساڵ ئەزموون',
      'contact_button': 'پەيوەندی',
      'no_lecturers_found': 'هیچ مامۆستایەک بۆ قۆناغەکەت نەدۆزرایەوە.',
      'coming_soon': 'بەم زووانە!',
      'enter_field': 'تکایە {field} بنووسە',
      'error_email_valid': 'تکایە ئیمەیڵێکی دروست بنووسە',
      'error_password_length': 'وشەی نهێنی دەبێت لانیکەم ٨ پیت بێت',
      'error_password_match': 'وشە نهێنییەکان وەک یەک نین',
      'retry': 'دووبارە هەوڵبدەرەوە',
      'no_recent_activity': 'هیچ چالاکییەکی نوێ نییە',
      'edit_experience': 'دەستکاریکردنی ئەزموون',
      'no_description': 'هیچ وەسفێک بەردەست نییە.',
      'no_courses_yet': 'هیچ کۆرسێک بەردەست نییە.',
      'feedback_perfect': 'ناوازەیە! ئەدایەکی نایاب!',
      'feedback_great': 'کارێکی زۆر باشە! ئەدایەکی نایاب!',
      'feedback_good': 'هەوڵێکی باشە! دەتوانیت زیاتر باشتر بیت.',
      'feedback_push': 'بەردەوام بە لە هەوڵدان!',"""

if old_ckb_pattern in content:
    content = content.replace(old_ckb_pattern, new_ckb)
else:
    # Try with a small variety in the CKB string if it fails to match exactly
    import re
    # Match the line starting with lecturer_ai_response in the CKB section
    # The string has Arabic/Kurdish characters which can have different normalization
    content = re.sub(
        r"('lecturer_ai_response': '.*?ئەو ماددە یان خشتەی کویزەکەی داهاتوو\.',)",
        new_ckb,
        content,
        flags=re.DOTALL
    )

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Finished update_l10n_v2.py execution")
