with open(r'c:\src\flutter-apps\edunova_application\edunova-backend\main.py', encoding='utf-8') as f:
    lines = f.readlines()
with open(r'c:\src\flutter-apps\edunova_application\extract_output.txt', 'w', encoding='utf-8') as out:
    for i, line in enumerate(lines):
        if 'def get_student_fees' in line or '/fees/pay' in line:
            start = max(0, i-2)
            end = min(len(lines), i+40)
            out.write(f'--- Match at line {i} ---\n')
            out.write(''.join(lines[start:end]))
