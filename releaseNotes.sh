#!/bin/bash
git lol $1 | sed 's/[|*()\/]//g' | grep "\[" | awk 'FS="]" {print $1}' | awk 'FS="[" {print "key="$2}' | sort -uV | xargs -l ~/neurobat/git-tools/get_issue.rb | sort -k3
