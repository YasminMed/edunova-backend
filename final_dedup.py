import re

file_path = 'lib/l10n/app_localizations.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()

def smart_dedup(content, lang):
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
        block = content[start_idx:end_idx]
        
        # Parse all key blocks (naively tracking strings and bracket depths to match entire 'key': 'string' declarations)
        # Much simpler way since we injected new keys at the END!
        # Just find the duplicates and comment out the FIRST occurrence (in the old section).
        keys = re.findall(r"^\s*'([A-Za-z0-9_]+)':", block, re.MULTILINE)
        from collections import Counter
        dups = [item for item, count in Counter(keys).items() if count > 1]
        
        for dup in dups:
            # We want to remove the FIRST occurrence of this key in the block.
            # Using regex to find the first occurrence up to the comma
            # Regex needs to handle inner {} correctly, which is tricky.
            # So a manual character by character parse to delete the first found block of 'dup': ...
            dup_str = f"'{dup}':"
            dup_idx = block.find(dup_str)
            if dup_idx != -1:
                # find start of line
                line_start = block.rfind('\n', 0, dup_idx)
                if line_start == -1: line_start = 0
                
                # find end of the entry (next comma at brace depth = 0 relative to entry)
                # or just look for the next top-level key or end of block.
                # Actually, the duplicate is guaranteed to be in the old section.
                # All old keys usually end with a simple comma or brace.
                import ast
                # Instead of complex parsing, let's just do an empty replace.
                # Find matching comma or next key
                entry_end = -1
                in_inner_str = False
                inner_brace = 0
                str_c = None
                esc = False
                i = dup_idx
                while i < len(block):
                    c = block[i]
                    if not in_inner_str:
                        if c == "'" or c == '"':
                            in_inner_str = True
                            str_c = c
                            esc = False
                        elif c == '{': inner_brace += 1
                        elif c == '}': inner_brace -= 1
                        elif c == ',' and inner_brace <= 0:
                            entry_end = i
                            break
                    else:
                        if esc: esc = False
                        elif c == '\\\\': esc = True
                        elif c == str_c: in_inner_str = False
                    i += 1
                
                if entry_end != -1:
                    # comment it out 
                    block = block[:line_start] + "\n      // Duplicate removed: " + block[line_start+1:entry_end+1].replace('\n', ' ') + block[entry_end+1:]
        
        return content[:start_idx] + block + content[end_idx:]
    return content

content = smart_dedup(content, 'en')
content = smart_dedup(content, 'ar')
content = smart_dedup(content, 'ckb')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Duplicates removed.")
