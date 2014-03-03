class GitHub
  def initialize(org, auth_token)
    @org = org
    @auth_token = auth_token
  end

  def get_pull_requests_for(repository)
    url = URI("https://api.github.com/repos/#{@org}/#{repository}/pulls")

    req = Net::HTTP::Get.new(url.to_s)
    req.basic_auth("token", @auth_token)
    req["content-type"] = "application/json"

    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      response = http.request(req)
    end

    if res.code == "200"
      result = JSON.parse(res.body)
    else
      result = []
    end
    return result
  end

  def post_comment(link, comment)
    url = URI(link)
    req = Net::HTTP::Post.new(url.to_s)
    req.basic_auth("token", @auth_token)
    req["content-type"] = "application/json"
    finalComment = ":moyai: Gictatr[almost reliable] says: #{comment}\n\n"
    finalComment += "If you think there is a bug in Gictatr's judgement please "
    finalComment += "create an issue here "
    finalComment += "https://github.com/jbiswas/git-tools/issues/new"
    req.body={:body => finalComment}.to_json
    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      p response = http.request(req)
    end
 end
end

