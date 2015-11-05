#!/bin/bash
git lol | grep $1  | sed 's/[|*()\/]//g' | awk '{print $1}' | xargs -L1 git diff-tree --no-commit-id --name-only -r | sort -uV
