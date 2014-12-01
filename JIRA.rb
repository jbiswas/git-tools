require 'net/http'
require 'json'

class JIRA
  def initialize(username, password)
    @user = username
    @pass = password
  end

  def get_issue_summary(issue_key)
    url = URI("https://bugs.neurobat.net/rest/api/2/search?jql=key=#{issue_key}")

    req = Net::HTTP::Get.new(url.to_s)
    req.basic_auth(@user, @pass)
    req["content-type"] = "application/json"

    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      response = http.request(req)
    end

    if res.code == "200"
      result = JSON.parse(res.body)
      summary = result["issues"][0]["fields"]["summary"]
    else
      summary = ""
    end
    return summary
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

