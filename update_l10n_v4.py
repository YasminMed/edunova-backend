import re

file_path = 'lib/l10n/app_localizations.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()

new_en = '''
      // Settings
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
'''

new_ar = '''
      // Settings
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
'''

new_ckb = '''
      // Settings
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

print('Updated app_localizations.dart successfully with settings keys')
