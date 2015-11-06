#!/bin/bash
git lol $1 | grep "\[" | sed 's/.*\[//' | awk 'FS="]" {print $1}' | sed -e 's/\]//' | sort -uV | xargs -l ~/neurobat/git-tools/get_issue.rb | sort -k6
