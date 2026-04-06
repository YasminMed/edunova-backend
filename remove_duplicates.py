import re
from collections import OrderedDict

file_path = 'lib/l10n/app_localizations.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()

def dedup_lang(content, lang, new_ones_override=True):
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
        block = content[start_idx:end_idx+1]
        # We can extract all key-value entries. Since parsing Dart maps perfectly in python is hard,
        # we will extract keys and their values if it's a simple top level.
        # However, a simpler approach is: we know which keys we just injected from new_en.
        # We can scan the OLD section (before our injection comment `// v2 keys`)
        # and remove duplicates from there.
        v2_comment = "      // v2 keys"
        v2_idx = block.find(v2_comment)
        if v2_idx != -1:
            old_block = block[:v2_idx]
            new_block = block[v2_idx:]
            
            # Extract explicitly added keys from new_block
            new_keys = re.findall(r"^\s*'([A-Za-z0-9_]+)':", new_block, re.MULTILINE)
            
            # Now remove those from old_block
            for k in set(new_keys):
                # Pattern to remove 'key': 'string value', or 'key': '{...}' string.
                # Actually, some old keys had interpolations. 
                # Let's just comment out the entire line of the duplicate in the old block.
                # Since interpolations can span multiple lines, commenting the line might break syntax.
                # Let's find exactly the key-value pair and remove it.
                
                # We can replace the whole key-value sequence with empty. 
                # Or just print what to do. Since it's simpler, I'll use regex.
                # A key definition `  'hello': ... ,`
                # Be careful of multi-line values.
                # Python `re.sub` for `r"\s*'key':\s*(?:'[^']*'|\"[^\"]*\")[,]?"` won't handle nested {} strings well.
                pass
                
    return content

# Simpler dedup: since we know we ONLY appended, we can read the file, and when we see duplicates, we remove the FIRST occurrence.
def manual_dedup():
    import json
    # Because of interpolations, let's just use dart to print duplicates if it was just finding them.
    # We found duplicates from dart analyze!
    pass

# We will just write a script that comments out duplicated keys from the ORIGINAL section.
import sys

def remove_dup_lines():
    try:
        with open('duplicates.txt', 'r', encoding='utf-16le') as f:
            dups = f.read()
    except Exception:
        dups = ""
    print(repr(dups))

remove_dup_lines()

