class Build
  def initialize(repository, base_user, base_branch, head_user, head_branch)
    @repository = repository
    @base_user = base_user
    @base_branch = base_branch
    @head_user = head_user
    @head_branch = head_branch
  end

  def cleanup()
    system("git reset --hard")
    system("git checkout #{@base_branch}")
    system("git reset --hard origin/#{@base_branch}")
    system("git branch -D #{@head_user}-#{@head_branch}")
  end

  def run_test_suite()
    result = "Not sure"
    puts "Checking #{@head_user}/#{@head_branch} on #{@repository}/#{@base_branch}"
    FileUtils.rm_rf(@repository)
    value = system("git clone git@github.com:#{@base_user}/#{@repository}.git")
    Dir.chdir(@repository) do
      system("git checkout origin/#{@base_branch}")
      system("git pull")
      system("git checkout -b #{@head_user}-#{@head_branch} origin/#{@base_branch}")
      system("git submodule init")
      system("git submodule update")
      pull_ok = system("git pull -q --no-edit git@github.com:#{@head_user}/#{@repository}.git #{@head_branch}")
      if pull_ok
        system("git submodule foreach 'git remote add #{@head_user} `git config --get remote.origin.url | sed 's/#{@base_user}/#{@head_user}/'`; git fetch --all -p'")
        system("git submodule update")
        build_ok = system("make -s")
        puts "Build ok flag = #{build_ok}"
        if build_ok
          system("git checkout #{@base_branch}")
          system("git merge --no-edit #{@head_user}-#{@head_branch}")
          result = ":ok: :cool: :cool: :+1:"
        else
          system("echo $PATH")
          result = "Build failed after merge :-1:. Please make sure that make runs properly in the root folder"
        end
      else
        result = "Merge failed :-1:. Please rebase onto #{@repository}/#{@base_branch}"
      end
      cleanup()
    end
    return result
  end
end

