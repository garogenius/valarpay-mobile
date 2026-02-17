
def check_balance(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    stack = []
    lines = content.split('\n')
    for i, line in enumerate(lines):
        for char in line:
            if char == '(':
                stack.append(('(', i + 1))
            elif char == ')':
                if not stack:
                    print(f"Extra ')' at line {i+1}")
                else:
                    stack.pop()
    
    for char, line_num in stack:
        print(f"Unmatched '{char}' from line {line_num}")

check_balance('/home/mrgenius/Documents/projects/Mobile-Apps/mobile-app/lib/features/auth/views/onboarding/signin/passcode_login.dart')
