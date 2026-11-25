# Scan Markdown for likely leaked credentials. Portable awk (gawk, mawk, BSD awk).
#   awk -f scripts/lib/secret-scan.awk file.md [more.md]
# Prints "file:line: text" for each hit; exit status 1 if anything was found.
#
# Deliberately narrow, so prose and code don't trip it:
#  - fenced code blocks (``` or ~~~) and `inline code` are ignored
#  - the keyword must start a word: "ForgotPassword:" / "resetPassword =" don't count
#  - the value must look like a credential, not a word in a sentence: it needs letters
#    plus a digit or symbol (e.g. Secret123, hunter2!, sk-live_ab12). Plain words like
#    "required" or "should" never match
#  - redacted / placeholder values (••••, ****, <demo password>, [redacted]) are fine

BEGIN { hits = 0 }
FNR == 1 { fence = "" }

{
  line = $0
  # fenced code blocks
  if (match(line, /^[ \t]*(```|~~~)/)) {
    marker = substr(line, RSTART + RLENGTH - 3, 3)
    if (fence == "") fence = marker
    else if (fence == marker) fence = ""
    next
  }
  if (fence != "") next

  gsub(/`[^`]*`/, "", line)            # inline code spans
  low = tolower(line)
  offset = 0
  while (match(low, /(password|passwd|passcode|pwd|secret|api[_-]?key|access[_-]?token|auth[_-]?token|token)[ \t]*[:=][ \t]*/)) {
    start = RSTART; len = RLENGTH
    abs = offset + start
    prev = (abs > 1) ? substr(tolower(line), abs - 1, 1) : ""
    rest = substr(line, abs + len)
    if (prev !~ /[a-z0-9_]/ && looks_like_credential(rest)) {
      printf "%s:%d: %s\n", FILENAME, FNR, $0
      hits++
      break
    }
    offset += start + len - 1
    low = substr(low, start + len)
  }
}

function looks_like_credential(s,    tok, first) {
  if (!match(s, /^[^ \t|,;)]+/)) return 0
  tok = substr(s, RSTART, RLENGTH)
  sub(/[.,;:!?)]+$/, "", tok)                 # trailing sentence punctuation
  if (length(tok) < 4) return 0
  first = substr(tok, 1, 1)
  if (first == "<" || first == "*" || first == "[" || first == "{" || first == "(") return 0
  if (tok ~ /^•/) return 0                             # ••••
  if (tok !~ /[A-Za-z]/) return 0
  if (tok ~ /[0-9]/) return 1                          # letters + digits
  if (tok ~ /[!@#$%^&*+=~?\/\\_-]/) return 1           # letters + symbols
  return 0
}

END { exit (hits > 0) ? 1 : 0 }
