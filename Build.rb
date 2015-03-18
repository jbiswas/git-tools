class Build
  def initialize(repository, base_user, base_branch, head_user, head_branch)
    @repository = repository
    @base_user = base_user
    @base_branch = base_branch
    @head_user = head_user
    @head_branch = head_branch
  end

  def cleanup()
    system("/usr/bin/git reset --hard")
    system("/usr/bin/git checkout #{@base_branch}")
    system("/usr/bin/git reset --hard origin/#{@base_branch}")
    system("/usr/bin/git branch -D #{@head_user}-#{@head_branch}")
  end

  def run_test_suite()
    result = "Not sure"
    puts "Checking #{@head_user}/#{@head_branch} on #{@repository}/#{@base_branch}"
    FileUtils::mkdir_p 'build'
    Dir.chdir("build") do
      FileUtils.rm_rf(@repository)
      value = system("/usr/bin/git clone git@github.com:#{@base_user}/#{@repository}.git")
    end
    build_dir = "build/#{@repository}"
    Dir.chdir(build_dir) do
      system("/usr/bin/git checkout origin/#{@base_branch}")
      system("/usr/bin/git pull")
      system("/usr/bin/git checkout -b #{@head_user}-#{@head_branch} origin/#{@base_branch}")
      system("/usr/bin/git submodule update --init --recursive")
      pull_ok = system("/usr/bin/git pull -q --no-edit git@github.com:#{@head_user}/#{@repository}.git #{@head_branch}")
      if pull_ok
        system("/usr/bin/git submodule update --init --recursive")
        system("/usr/bin/git submodule foreach '/usr/bin/git remote add #{@head_user} `/usr/bin/git config --get remote.origin.url | sed 's/#{@base_user}/#{@head_user}/'`; /usr/bin/git fetch --all -p'")
        system("/usr/bin/git submodule update --init --recursive")
        build_ok = system("/usr/bin/make -s")
        puts "Build ok flag = #{build_ok}"
        if build_ok
          system("/usr/bin/git checkout #{@base_branch}")
          system("/usr/bin/git merge --no-edit #{@head_user}-#{@head_branch}")
          result = ":ok: :cool: :cool: :+1:"
        else
          system("echo $PATH")
          result = "Build failed after merge :-1:. Please make sure that make runs properly in the root folder\n"
          result = result + "```\n" + %x(/usr/bin/make 2>&1) + "\n```\n"
        end
      else
        result = "Merge failed :-1:. Please rebase onto #{@repository}/#{@base_branch}"
      end
      cleanup()
    end
    return result
  end
end

