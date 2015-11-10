#!/usr/bin/env ruby
require_relative 'JIRA'

j = JIRA.new()
#puts ARGV[0]

a = j.get_issue_details("key="+ARGV[0])
if a.empty?
else
  printf("%s \t %s \t %s \t  %s \t %s \t %s \t %s \t %s \n", ARGV[0], a[0], a[1], a[2], a[3][0,10], ARGV[1][0,10], a[5], ARGV[2])
end
