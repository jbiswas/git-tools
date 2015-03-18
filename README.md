git-tools
=========

Command line tools for git

Running Gictator
================
To run Gictator from crontab use a script like the one shown below
```
#!/bin/bash
. ${HOME}/.bashrc
cd ${HOME}/Private
if [ -d "git-tools" ]; then
  cd git-tools
  flock -n handle_pull_request.pid -c ./handle-pull-request.rb
fi
```

Requirements
============
* curl
