#!/usr/bin/env ruby

$LOAD_PATH << '.'
require_relative 'JIRA'

#j = JIRA.new('username', 'password')
a = j.get_issue_details("key="+ARGV[0])
if a.empty?
else
  printf("%-10s %-11s %-13s %-11s %-11s %s\n", ARGV[0].sub("key=",""), a[0], a[1], a[2][0,10], a[3][0,10], a[4])
end
