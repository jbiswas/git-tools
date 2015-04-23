#!/bin/bash
echo " " > foo.tmp
git lol $1 | grep "\[" >> foo.tmp
git status -b -s | awk 'NR==1'
awk 'FS="]" {print $1}' foo.tmp | awk 'FS="[" {print "key=" $2 "+AND+status+not+in+(closed)"}' | sort -uV | xargs -l ~/neurobat/git-tools/get_issue.rb | sort -k3
rm foo.tmp
