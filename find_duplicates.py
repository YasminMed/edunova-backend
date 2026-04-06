import re
from collections import Counter

file_path = 'lib/l10n/app_localizations.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()

for lang in ['en', 'ar', 'ckb']:
    start_idx = content.find(f"'{lang}': {{")
    if start_idx == -1: continue
    
    end_idx = content.find("    },", start_idx)
    block = content[start_idx:end_idx] if end_idx != -1 else content[start_idx:]
    
    # Simple regex to find keys like 'hello': ...
    keys = re.findall(r"^\s*'([a-zA-Z0-9_]+)':", block, re.MULTILINE)
    
    duplicates = [item for item, count in Counter(keys).items() if count > 1]
    if duplicates:
        print(f"Duplicates in {lang}:")
        for dup in duplicates:
            print(f"  - {dup}")

print("Done")
