#!/usr/bin/env fish

# ---- FASTFETCH HIZ TESTİ ÖNBËLLEĞİ ----
set cache_file "$HOME/.cache/fastfetch-speedtest.txt"
mkdir -p "$HOME/.cache"

set raw (/usr/bin/speedtest --accept-license --accept-gdpr --format=json 2>/dev/null)
if test $status -ne 0 -o -z "$raw"
    exit 0
end

set parsed (printf '%s\n' "$raw" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    dl = d["download"]["bandwidth"] * 8 / 1_000_000
    ul = d["upload"]["bandwidth"] * 8 / 1_000_000
    ping = round(d["ping"]["latency"])
    print(f"↓ {dl:.1f} Mbps / ↑ {ul:.1f} Mbps ({ping} ms)")
except Exception:
    sys.exit(1)
')

if test $status -eq 0 -a -n "$parsed"
    echo "$parsed" > "$cache_file.tmp"
    mv -f "$cache_file.tmp" "$cache_file"
end
