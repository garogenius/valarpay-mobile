import os, glob, re

search_paths = ['lib/**/*.dart']
files = []
for path in search_paths:
    files.extend(glob.glob(path, recursive=True))

for filepath in files:
    if not os.path.isfile(filepath): continue
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = content
    new_content = re.sub(r'final isBvnVerified = user\?\.isBvnVerified \?\? false;', 'final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false);', new_content)
    new_content = re.sub(r'final isVerified = user\?\.isBvnVerified \?\? false;', 'final isVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false);', new_content)
    new_content = re.sub(r'final isBvnVerified = user\.isBvnVerified;', 'final isBvnVerified = user.isBvnVerified || user.isNinVerified;', new_content)
    new_content = re.sub(r'final isBvnVerified = currentUser\.isBvnVerified;', 'final isBvnVerified = currentUser.isBvnVerified || currentUser.isNinVerified;', new_content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f'Fixed {filepath}')
