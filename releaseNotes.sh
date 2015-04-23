#!/bin/bash
echo " " > foo.tmp
git lol $1 | grep "\[" >> foo.tmp
awk 'FS="]" {print $1}' foo.tmp | awk 'FS="[" {print "key="$2}' | sort -uV | xargs -l ~/neurobat/git-tools/get_issue.rb | sort -k3
rm foo.tmp
