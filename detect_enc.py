import chardet

file_path = r'c:\src\flutter-apps\edunova_application\lib\l10n\app_localizations.dart'
with open(file_path, 'rb') as f:
    rawdata = f.read(10000)
    result = chardet.detect(rawdata)
    print(result)
