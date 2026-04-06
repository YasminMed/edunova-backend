import re

file_path = 'lib/l10n/app_localizations.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()

new_en = """
      // v2 keys
      'activity_quiz_submitted': 'Submitted quiz',
      'activity_assignment_submitted': 'Submitted assignment',
      'activity_comment_added': 'Added a comment',
      'activity_material_viewed': 'Viewed material',
      'activity_unknown': 'New activity',
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
      'coming_soon': 'Feature coming soon!',
      'enter_field': 'Please enter {field}',
      'error_email_valid': 'Please enter a valid email',
      'error_password_length': 'Password must be at least 8 characters',
      'error_password_match': 'Passwords do not match',
      'retry': 'Retry',
      'feedback_perfect': 'Perfect! Outstanding performance!',
      'feedback_great': 'Great job! Excellent performance!',
      'feedback_good': 'Good effort! You can improve even more.',
      'feedback_push': 'Keep pushing forward!',
      'edit_experience': 'Edit Experience',
      'no_recent_activity': 'No recent activities found',
      'no_description': 'No description available.',
      'lecturer_fallback': 'Lecturer',
      'no_courses_available': 'No courses available yet.',
      // v3 & v4 keys
      'fees_page': 'Academic Fees',
      'total_debt': 'Total Debt',
      'installment_timeline': 'Payment Timeline',
      'payment_method': 'How to Pay',
      'paid': 'Paid',
      'due': 'Due',
      'currency': 'IQD',
      'medals_page': 'My Medals',
      'total_medals': 'Total Medals',
      'assignment_solver': 'Assignment Solver',
      'challenger': 'Challenger',
      'active_student': 'Active Student',
      'timetable_page': 'Class Timetable',
      'sun': 'Sun',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'hall': 'Hall',
      'support': 'Support',
      'general_help': 'General Help',
      'account_privacy': 'Account & Privacy',
      'app_features': 'App Features',
      'online': 'Online',
      'chatbot_hint': 'Ask a question...',
      'chatbot_welcome': 'Hi! I am your AI Study Assistant. Ask me anything about your lectures or studies.',
      'listening': 'Listening...',
      'settings_page': 'Settings',
      'general': 'General',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'notifications_muted': 'Notifications Muted',
      'notifications_unmuted': 'Notifications Unmuted',
      'about_app': 'About App',
      'about_app_description': 'EduNova is a comprehensive educational platform designed to streamline the academic experience for both students and lecturers, fostering a collaborative and engaging environment.',
      'contact_us': 'Contact Us',
      'version': 'Version',
"""

new_ar = """
      // v2 keys
      'activity_quiz_submitted': 'سلم اختبارًا',
      'activity_assignment_submitted': 'سلم واجبًا',
      'activity_comment_added': 'أضاف تعليقًا',
      'activity_material_viewed': 'شاهد المادة',
      'activity_unknown': 'نشاط جديد',
      'hello': 'مرحباً',
      'rank_label': 'الرتبة',
      'pts': 'نقاط',
      'loading': 'جاري التحميل...',
      'rank_pending': 'الرتبة قيد الانتظار',
      'score_pending': 'النتيجة قيد الانتظار',
      'no_ranking_data': 'لا توجد بيانات تصنيف بعد',
      'years_exp_label': 'سنوات الخبرة',
      'contact_button': 'تواصل',
      'no_lecturers_found': 'لم يتم العثور على محاضرين لمرحلتك.',
      'coming_soon': 'الميزة ستتوفر قريباً!',
      'enter_field': 'يرجى إدخال {field}',
      'error_email_valid': 'يرجى إدخال بريد إلكتروني صحيح',
      'error_password_length': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',
      'error_password_match': 'كلمات المرور غير متطابقة',
      'retry': 'إعادة المحاولة',
      'feedback_perfect': 'مثالي! أداء متميز!',
      'feedback_great': 'عمل رائع! أداء ممتاز!',
      'feedback_good': 'جهد جيد! يمكنك التحسن أكثر.',
      'feedback_push': 'استمر في التقدم للأمام!',
      'edit_experience': 'تعديل الخبرة',
      'no_recent_activity': 'لم يتم العثور على أنشطة حديثة',
      'no_description': 'لا يوجد وصف متاح.',
      'lecturer_fallback': 'محاضر',
      'no_courses_available': 'لا توجد دورات متاحة بعد.',
      // v3 & v4 keys
      'fees_page': 'الرسوم الدراسية',
      'total_debt': 'إجمالي الديون',
      'installment_timeline': 'الجدول الزمني الدفع',
      'payment_method': 'طريقة الدفع',
      'paid': 'مدفوع',
      'due': 'مستحق',
      'currency': 'د.ع',
      'medals_page': 'أوسمتي',
      'total_medals': 'إجمالي الأوسمة',
      'assignment_solver': 'حلال الواجبات',
      'challenger': 'المتحدي',
      'active_student': 'طالب نشط',
      'timetable_page': 'جدول الحصص',
      'sun': 'الأحد',
      'mon': 'الإثنين',
      'tue': 'الثلاثاء',
      'wed': 'الأربعاء',
      'thu': 'الخميس',
      'hall': 'القاعة',
      'support': 'الدعم',
      'general_help': 'مساعدة عامة',
      'account_privacy': 'الحساب والخصوصية',
      'app_features': 'ميزات التطبيق',
      'online': 'متصل',
      'chatbot_hint': 'اسأل سؤالاً...',
      'chatbot_welcome': 'مرحباً! أنا مساعدك الدراسي الذكي. اسألني أي شيء عن محاضراتك أو دراستك.',
      'listening': 'جاري الاستماع...',
      'settings_page': 'الإعدادات',
      'general': 'عام',
      'dark_mode': 'الوضع الداكن',
      'notifications': 'الإشعارات',
      'notifications_muted': 'تم كتم الإشعارات',
      'notifications_unmuted': 'تم تفعيل الإشعارات',
      'about_app': 'عن التطبيق',
      'about_app_description': 'إديونوفا هي منصة تعليمية شاملة مصممة لتبسيط التجربة الأكاديمية لكل من الطلاب والمحاضرين، مما يعزز بيئة تعاونية وجذابة.',
      'contact_us': 'اتصل بنا',
      'version': 'الإصدار',
"""

new_ckb = """
      // v2 keys
      'activity_quiz_submitted': 'تاقیکردنەوەیەکی پێشکەش کرد',
      'activity_assignment_submitted': 'ئەرکێکی پێشکەش کرد',
      'activity_comment_added': 'کۆمێنتێکی زیادکرد',
      'activity_material_viewed': 'ماددەکەی بینی',
      'activity_unknown': 'چالاکی نوێ',
      'hello': 'سڵاو',
      'rank_label': 'پلە',
      'pts': 'خاڵ',
      'loading': 'خەریکی بارکردنە...',
      'rank_pending': 'پلە چاوەڕوانە',
      'score_pending': 'نمرە چاوەڕوانە',
      'no_ranking_data': 'هێشتا هیچ زانیارییەکی ڕیزبەندی نییە',
      'years_exp_label': 'ساڵ ئەزموون',
      'contact_button': 'پەیوەندی',
      'no_lecturers_found': 'هیچ مامۆستایەک بۆ قۆناغەکەت نەدۆزرایەوە.',
      'coming_soon': 'ئەم تایبەتمەندییە بەمنزیکانە بەردەست دەبێت!',
      'enter_field': 'تکایە {field} بنووسە',
      'error_email_valid': 'تکایە ئیمەیڵێکی دروست بنووسە',
      'error_password_length': 'وشەی نھێنی دەبێت لانیکەم 8 پیت بێت',
      'error_password_match': 'وشە نهێنییەکان هاوتا نین',
      'retry': 'هەوڵدانەوە',
      'feedback_perfect': 'کامڵە! ئاستێکی نایاب!',
      'feedback_great': 'کاریگەریییەکی باشە! ئاستێکی زۆر باش!',
      'feedback_good': 'هەوڵێکی باشە! دەتوانیت زیاتر باشتر بیت.',
      'feedback_push': 'بەردەوام بە لە پێشکەوتن!',
      'edit_experience': 'دەستکاریکردنی ئەزموون',
      'no_recent_activity': 'هیچ چالاکییەکی نوێ نەدۆزرایەوە',
      'no_description': 'هیچ وەسفێک بەردەست نییە.',
      'lecturer_fallback': 'مامۆستا',
      'no_courses_available': 'هیچ کۆرسێک هێشتا بەردەست نییە.',
      // v3 & v4 keys
      'fees_page': 'کرێی خوێندن',
      'total_debt': 'کۆی قەرز',
      'installment_timeline': 'کاتی پارەدان',
      'payment_method': 'چۆنیەتی پارەدان',
      'paid': 'دراوە',
      'due': 'ماوە',
      'currency': 'دینار',
      'medals_page': 'مەدالیاکانم',
      'total_medals': 'کۆی مەدالیاکان',
      'assignment_solver': 'شیکارکەری ئەرک',
      'challenger': 'ڕکابەر',
      'active_student': 'قوتابی چالاک',
      'timetable_page': 'خشتەی وانەکان',
      'sun': 'یەکشەممە',
      'mon': 'دووشەممە',
      'tue': 'سێشەممە',
      'wed': 'چوارشەممە',
      'thu': 'پێنجشەممە',
      'hall': 'هۆڵ',
      'support': 'پاڵپشتی',
      'general_help': 'یارمەتی گشتی',
      'account_privacy': 'هەژمار و تایبەتمەندی',
      'app_features': 'تایبەتمەندییەکانی بەرنامە',
      'online': 'سەرهێڵ',
      'chatbot_hint': 'پرسیارێک بکە...',
      'chatbot_welcome': 'سڵاو! من یاریدەدەری زیرەکی خوێندنی تۆم. هەر شتێک دەربارەی وانەکانت یان خوێندنەکەت لێم بپرسە.',
      'listening': 'گوێ دەگرێت...',
      'settings_page': 'ڕێکخستنەکان',
      'general': 'گشتی',
      'dark_mode': 'دۆخی تاریک',
      'notifications': 'ئاگادارکەرەوەکان',
      'notifications_muted': 'ئاگادارکەرەوەکان بێدەنگ کران',
      'notifications_unmuted': 'ئاگادارکەرەوەکان چالاک کران',
      'about_app': 'دەربارەی بەرنامە',
      'about_app_description': 'ئیدیۆنۆڤا سەکۆیەکی پەروەردەیی گشتگیرە کە دروستکراوە بۆ ئاسانکردنی ئەزموونی ئەکادیمی بۆ هەردوو قوتابیان و مامۆستایان، لەگەڵ ڕەخساندنی ژینگەیەکی یارمەتیدەر.',
      'contact_us': 'پەیوەندیمان پێوە بکە',
      'version': 'وەشان',
"""

def smart_inject(content, lang, new_text):
    lang_header = f"'{lang}': {{"
    start_idx = content.find(lang_header)
    if start_idx == -1: return content
    
    brace_count = 0
    in_str = False
    
    idx = content.find('{', start_idx)
    if idx == -1: return content
    brace_count = 1
    idx += 1
    
    end_idx = -1
    str_char = None
    escaped = False
    
    while idx < len(content):
        c = content[idx]
        if not in_str:
            if c == "'" or c == '"':
                in_str = True
                str_char = c
                escaped = False
            elif c == '{':
                brace_count += 1
            elif c == '}':
                brace_count -= 1
                if brace_count == 0:
                    end_idx = idx
                    break
        else:
            if escaped:
                escaped = False
            elif c == '\\\\':
                escaped = True
            elif c == str_char:
                in_str = False
        idx += 1
        
    if end_idx != -1:
        last_char_idx = end_idx - 1
        while last_char_idx > start_idx and content[last_char_idx].isspace():
            last_char_idx -= 1
            
        insertion = new_text + "\n"
        if content[last_char_idx] != ',':
            insertion = "," + "\n" + new_text + "\n"
            
        return content[:last_char_idx + 1] + insertion + content[end_idx:]
    return content

content = smart_inject(content, 'en', new_en)
content = smart_inject(content, 'ar', new_ar)
content = smart_inject(content, 'ckb', new_ckb)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated successfully")
