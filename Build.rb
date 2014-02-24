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
      system("git checkout #{@base_branch}")
      system("git pull")
      system("git checkout -b #{@head_user}-#{@head_branch} #{@base_branch}")
      ok = system("git pull -q --no-edit git@github.com:#{@head_user}/#{@repository}.git #{@head_branch}")
      if ok
        build_failed = system("make -s")
        if build_failed
          result = "Build failed after merge :-1:. Please make sure that make runs properly in the root folder"
        else
          system("git checkout #{@base_branch}")
          system("git merge --no-edit #{@head_user}-#{@head_branch}")
          result = "All good :+1:"
        end
      else
        result = "Merge failed :-1:. Please rebase onto #{@repository}/#{@base_branch}"
      end
      cleanup()
    end
    return result
  end
end

