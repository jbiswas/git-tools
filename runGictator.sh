#!/bin/bash
. ${HOME}/.bashrc
cd ${HOME}/Private
if [ -d "git-tools" ]; then
  cd git-tools
  flock -n handle_pull_request.pid -c ./handle-pull-request.rb
fi
