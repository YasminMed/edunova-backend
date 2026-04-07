import re

file_path = 'lib/l10n/app_localizations.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()

new_en = '''
      // Fees
      'fees_page': 'Academic Fees',
      'total_debt': 'Total Debt',
      'installment_timeline': 'Payment Timeline',
      'payment_method': 'How to Pay',
      'paid': 'PAID',
      'due': 'DUE',
      'currency': 'IQD',

      // Medals
      'medals_page': 'My Medals',
      'total_medals': 'Total Medals',
      'assignment_solver': 'Assignment Solver',
      'challenger': 'Challenger',
      'active_student': 'Active Student',

      // Timetable
      'timetable_page': 'Class Timetable',
      'sun': 'Sun',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'hall': 'Hall',

      // Support
      'support': 'Support',
      'general_help': 'General Help',
      'account_privacy': 'Account & Privacy',
      'app_features': 'App Features',

      // Chatbot
      'online': 'Online',
      'chatbot_hint': 'Ask a question...',
      'chatbot_welcome': 'Hi! I am your AI Study Assistant. Ask me anything about your lectures or studies.',
      'listening': 'Listening...',
'''

new_ar = '''
      // Fees
      'fees_page': 'الرسوم الدراسية',
      'total_debt': 'إجمالي الديون',
      'installment_timeline': 'الجدول الزمني الدفع',
      'payment_method': 'طريقة الدفع',
      'paid': 'مدفوع',
      'due': 'مستحق',
      'currency': 'د.ع',

      // Medals
      'medals_page': 'أوسمتي',
      'total_medals': 'إجمالي الأوسمة',
      'assignment_solver': 'حلال الواجبات',
      'challenger': 'المتحدي',
      'active_student': 'طالب نشط',

      // Timetable
      'timetable_page': 'جدول الحصص',
      'sun': 'الأحد',
      'mon': 'الإثنين',
      'tue': 'الثلاثاء',
      'wed': 'الأربعاء',
      'thu': 'الخميس',
      'hall': 'القاعة',

      // Support
      'support': 'الدعم',
      'general_help': 'مساعدة عامة',
      'account_privacy': 'الحساب والخصوصية',
      'app_features': 'ميزات التطبيق',

      // Chatbot
      'online': 'متصل',
      'chatbot_hint': 'اسأل سؤالاً...',
      'chatbot_welcome': 'مرحباً! أنا مساعدك الدراسي الذكي. اسألني أي شيء عن محاضراتك أو دراستك.',
      'listening': 'جاري الاستماع...',
'''

new_ckb = '''
      // Fees
      'fees_page': 'کرێی خوێندن',
      'total_debt': 'کۆی قەرز',
      'installment_timeline': 'کاتی پارەدان',
      'payment_method': 'چۆنیەتی پارەدان',
      'paid': 'دراوە',
      'due': 'ماوە',
      'currency': 'دینار',

      // Medals
      'medals_page': 'مەدالیاکانم',
      'total_medals': 'کۆی مەدالیاکان',
      'assignment_solver': 'شیکارکەری ئەرک',
      'challenger': 'ڕکابەر',
      'active_student': 'قوتابی چالاک',

      // Timetable
      'timetable_page': 'خشتەی وانەکان',
      'sun': 'یەکشەممە',
      'mon': 'دووشەممە',
      'tue': 'سێشەممە',
      'wed': 'چوارشەممە',
      'thu': 'پێنجشەممە',
      'hall': 'هۆڵ',

      // Support
      'support': 'پاڵپشتی',
      'general_help': 'یارمەتی گشتی',
      'account_privacy': 'هەژمار و تایبەتمەندی',
      'app_features': 'تایبەتمەندییەکانی بەرنامە',

      // Chatbot
      'online': 'سەرهێڵ',
      'chatbot_hint': 'پرسیارێک بکە...',
      'chatbot_welcome': 'سڵاو! من یاریدەدەری زیرەکی خوێندنی تۆم. هەر شتێک دەربارەی وانەکانت یان خوێندنەکەت لێم بپرسە.',
      'listening': 'گوێ دەگرێت...',
'''

def inject_keys(text, lang_code, new_keys):
    pattern = re.compile(r"'" + lang_code + r"':\s*\{([^\}]*)\}", re.DOTALL)
    match = pattern.search(text)
    if match:
        existing_keys = match.group(1)
        if not existing_keys.strip().endswith(','):
            existing_keys += ','
        updated_dict_body = existing_keys + "\n" + new_keys
        replacement = "'" + lang_code + "': {" + updated_dict_body + "\n    }"
        return text[:match.start()] + replacement + text[match.end():]
    return text

content = inject_keys(content, 'en', new_en)
content = inject_keys(content, 'ar', new_ar)
content = inject_keys(content, 'ckb', new_ckb)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated app_localizations.dart successfully')
