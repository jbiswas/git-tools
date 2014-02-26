#!/usr/bin/env ruby

require 'net/http'

require 'fileutils'
require 'rubygems'
require 'json'
require 'pp'

$LOAD_PATH << '.'
require './GitHub'
require './Build'
require './config'

def initialise_pull_request(filename)
  lastPull = 0
  if File.file?(filename)
    lastPull = File.read(filename).to_i
  end
  return lastPull
end

if __FILE__ == $0
  g = GitHub.new($org, $OAUTHTOKEN)
  lastPullSeen = 0
  lastPull = 0
  filename = ""
  $repositories.each do |repository|
    result = g.get_pull_requests_for(repository)
    lastPull = 0
    lastPullSeen = 0
    filename = ""
    result.each do |doc|
      if doc["state"] == "open"
        filename = "#{doc["base"]["repo"]["owner"]["login"]}-#{repository}.last"
        lastPull = initialise_pull_request(filename)

        if lastPullSeen < doc["number"].to_i
          lastPullSeen = doc["number"].to_i
        end
        if lastPull < doc["number"].to_i
          puts "Building pull #{doc["number"]} for #{repository}:"
          b = Build.new(repository,
                      doc["base"]["repo"]["owner"]["login"], doc["base"]["ref"],
                      doc["head"]["repo"]["owner"]["login"], doc["head"]["ref"])
          comment = b.run_test_suite()
          puts "Comment: #{comment}"
          g.post_comment(doc["_links"]["comments"]["href"], comment)
        else
        end
      end
    end
    if lastPullSeen.to_i > lastPull
      lastPull = lastPullSeen
    end
    if !filename.empty?
      if File.file?(filename)
        File.delete(filename)
      end
      lastFile = File.open(filename, "w+")
      lastFile.syswrite("#{lastPull}")
      lastFile.close
    end
  end
end

