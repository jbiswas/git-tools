require 'net/http'
require 'json'
require 'yaml'

CURRENT_PATH = File.expand_path(File.dirname(__FILE__))
CONFIG_FILE = File.join(CURRENT_PATH, 'etc/jira_auth.yaml')

class JIRA
  def initialize()
     jira_auth = YAML::load(File.open(CONFIG_FILE))
     @user = jira_auth['username']
     @pass = jira_auth['password']
  end

  def get_issue_details(jql)
    summary = []
    linkedissues = ""
    url = URI("https://bugs.neurobat.net/rest/api/2/search?jql=#{jql}")
    req = Net::HTTP::Get.new(url.to_s)
    req.basic_auth(@user, @pass)
    req["content-type"] = "application/json"
    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      response = http.request(req)
    end
    if res.code == "200"
      result = JSON.parse(res.body)
      if result["total"] > 0
        linkedissues = get_linked_issues(result["issues"][0]["fields"]["issuelinks"]),
        summary = [result["issues"][0]["fields"]["issuetype"]["name"], 
                   get_linked_issues(result["issues"][0]["fields"]["issuelinks"]),
                   result["issues"][0]["fields"]["status"]["name"], 
                   result["issues"][0]["fields"]["resolutiondate"], 
                   result["issues"][0]["fields"]["summary"]]
        if summary[3].nil?
          summary[3] = "unknown"
        end
      end
    end
    return summary
  end

  def get_linked_issues(issuelinks)
    if issuelinks.empty?
    else
      linklist = ""
      issuelinks.each { |id|
        unless id["outwardIssue"].nil?
          linklist = id["outwardIssue"]["key"] + ", " + linklist.to_s
        end
        unless id["inwardIssue"].nil?
          linklist = id["inwardIssue"]["key"] + ", " + linklist.to_s
        end
      }
      2.times do linklist.chop! end
      return linklist.to_s
    end
  end

  def get_issues_in_sprint()
    url = URI("https://bugs.neurobat.net/rest/api/2/search?jql=Sprint+in+OpenSprints()")
    req = Net::HTTP::Get.new(url.to_s)
    req.basic_auth(@user, @pass)
    req["content-type"] = "application/json"

    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      response = http.request(req)
    end

    result_list = []

    if res.code == "200"
      result = JSON.parse(res.body)
      result["issues"].each do |issue|
        if issue["fields"]["issuetype"]["subtask"] == false
          result_list << issue["key"]
        end
      end
    end
    return result_list
  end

  def get_closed_issues_in_sprint(assignee)
    url = URI("https://bugs.neurobat.net/rest/api/2/search?jql=Sprint+in+OpenSprints()+AND+status+in+(Closed,Resolved,%22Under+test%22)+AND+assignee=#{assignee}")

    req = Net::HTTP::Get.new(url.to_s)
    req.basic_auth(@user, @pass)
    req["content-type"] = "application/json"

    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      response = http.request(req)
    end

    result_list = []

    if res.code == "200"
      result = JSON.parse(res.body)
      result["issues"].each do |issue|
        if issue["fields"]["issuetype"]["subtask"] == false
          result_list << issue["key"]
        end
      end
    end
    return result_list
  end

end

