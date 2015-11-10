#!/bin/bash
t=$1
tag=${t#*..*}
git log --grep "^\[" --no-merges --pretty=format:"%s ] %ad" --date=short $1 | sed 's/.*\[//' | awk 'BEGIN {FS="]"; RS="\n"} NF==3{print $1 $3}' | sort -u | awk '{a[$1] = $0} END{for (i in a) print a[i] " '$tag'"}' | xargs -l $(dirname $0)/get_issue.rb | sort -k6

