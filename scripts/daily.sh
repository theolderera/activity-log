#!/usr/bin/env bash
# Daily activity: 50-200 commits per day, at random times between 12:00 and 23:00 Dushanbe time.
# Runs twice a day (main + backup); if today is already done, it does nothing.
set -euo pipefail
export TZ="Asia/Dushanbe"
TODAY=$(date +%F)
LOG="days/$TODAY.log"
mkdir -p days
if [ -f "$LOG" ]; then echo "Already done for $TODAY"; exit 0; fi

git config user.name  "theolderera"
git config user.email "226323070+theolderera@users.noreply.github.com"

COUNT=$(( RANDOM % 151 + 50 ))          # 50..200
START=$(date -d "$TODAY 12:00" +%s)
END=$(date -d "$TODAY 23:00" +%s)
NOW=$(date +%s); [ "$END" -gt "$NOW" ] && END=$NOW

# random sorted timestamps for the day
mapfile -t TIMES < <(for i in $(seq "$COUNT"); do echo $(( START + (RANDOM * 32768 + RANDOM) % (END - START + 1) )); done | awk -v e="$END" '{ if ($1>e) $1=e; print }' | sort -n)

echo "# $TODAY — $COUNT commits" > "$LOG"
for i in "${!TIMES[@]}"; do
  TS="${TIMES[$i]}"
  D=$(date -d "@$TS" "+%Y-%m-%dT%H:%M:%S%z")
  echo "$(date -d "@$TS" +%T) update $((i+1))/$COUNT" >> "$LOG"
  git add "$LOG"
  GIT_AUTHOR_DATE="$D" GIT_COMMITTER_DATE="$D" git commit -q -m "Update log $TODAY ($((i+1))/$COUNT)"
done
git push -q origin HEAD
echo "Done: $COUNT commits for $TODAY"
