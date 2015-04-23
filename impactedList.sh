#!/bin/bash
echo " " > foo.tmp
git lol | grep $1 >> foo.tmp
awk 'FS="*" {print $2}' foo.tmp | awk '{print $1}' | xargs -L1 git diff-tree --no-commit-id --name-only -r | sort -uV
rm foo.tmp
