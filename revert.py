import os, glob

search_paths = ['lib/**/*.dart']
files = []
for path in search_paths:
    files.extend(glob.glob(path, recursive=True))

for filepath in files:
    if not os.path.isfile(filepath): continue
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = content.replace(
        '((user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false))',
        'isBvnVerified'
    )
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f'Reverted {filepath}')
