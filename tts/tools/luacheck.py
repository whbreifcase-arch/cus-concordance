import sys, re

KW_OPEN  = {"function", "if", "for", "while", "do"}
KW_CLOSE = {"end", "until"}

def tokenize(src):
    """Yield (line, token) for Lua words outside strings/comments."""
    i, line, n = 0, 1, len(src)
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1; i += 1; continue
        # long bracket [[ ... ]] / [=[ ... ]=]
        m = re.match(r"\[(=*)\[", src[i:])
        if m:
            close = "]" + m.group(1) + "]"
            j = src.find(close, i + len(m.group(0)))
            if j < 0:
                yield (line, "!!UNTERMINATED-LONGSTRING")
                return
            line += src.count("\n", i, j); i = j + len(close); continue
        # comments
        if src.startswith("--", i):
            m = re.match(r"--\[(=*)\[", src[i:])
            if m:
                close = "]" + m.group(1) + "]"
                j = src.find(close, i + len(m.group(0)))
                if j < 0:
                    yield (line, "!!UNTERMINATED-LONGCOMMENT"); return
                line += src.count("\n", i, j); i = j + len(close); continue
            j = src.find("\n", i); i = n if j < 0 else j; continue
        # quoted strings
        if c in "\"'":
            q, j = c, i + 1
            while j < n:
                if src[j] == "\\": j += 2; continue
                if src[j] == "\n":
                    yield (line, "!!NEWLINE-IN-STRING"); return
                if src[j] == q: break
                j += 1
            if j >= n:
                yield (line, "!!UNTERMINATED-STRING"); return
            i = j + 1; continue
        m = re.match(r"[A-Za-z_][A-Za-z_0-9]*", src[i:])
        if m:
            yield (line, m.group(0)); i += len(m.group(0)); continue
        i += 1

def check(path):
    src = open(path, encoding="utf-8", errors="replace").read()
    # `for ... do` and `while ... do` open ONE block, not two. The `do` can be
    # many tokens after its keyword, so carry a flag until it shows up.
    stack, pending_do, repeats = [], 0, 0
    for line, tok in tokenize(src):
        if tok.startswith("!!"):
            print(f"  ERROR line {line}: {tok[2:]}")
            return 1
        if tok in ("for", "while"):
            stack.append((tok, line)); pending_do += 1
        elif tok == "do":
            if pending_do > 0:
                pending_do -= 1        # belongs to the for/while already counted
            else:
                stack.append(("do", line))
        elif tok == "function" or tok == "if":
            stack.append((tok, line))
        elif tok == "repeat":
            repeats += 1
        elif tok == "until":
            if repeats > 0: repeats -= 1
        elif tok == "end":
            if not stack:
                print(f"  ERROR line {line}: unmatched 'end'")
                return 1
            stack.pop()
    if stack:
        print(f"  ERROR: {len(stack)} unclosed block(s). Innermost first:")
        for tok, line in reversed(stack[-8:]):
            print(f"    '{tok}' opened at line {line}")
        return 1
    print(f"  OK  {path.split(chr(92))[-1]}  ({src.count(chr(10))+1} lines, syntax structurally valid)")
    return 0

sys.exit(max(check(p) for p in sys.argv[1:]))
