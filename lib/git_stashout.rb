require 'grit'
require 'colored'
require 'git_stashout/version'

class GitStashout
  def run(argv)
    branch_name = process_args(argv)

    Grit::Git.with_timeout(0) do
      if on_branch?(branch_name)
        puts "already on #{branch_name}".green
      else
        with_stash do
          checkout(branch_name)
          puts "done".green
        end
      end
    end
  rescue GitError => e
    puts e.message
    exit 1
  end

  def process_args(argv)
    banner = <<BANNER
Git Stashout takes a single argument, the branch.
    $ git_stashout some_branch
    #{"stashing 5 changes".magenta}
    #{"checking out some_branch".yellow}
    #{"unstashing".magenta}
BANNER

    case argv
    when ["-v"], ["--version"]
      $stdout.puts "git_stashout #{GitStashout::VERSION}"
      exit
    when ["-h"], ["--help"]
      $stderr.puts(banner)
      exit
    else
      if argv.length == 1
        return argv[0]
      else
        $stderr.puts(banner)
        exit 1
      end
    end
  end

  def repo
    @repo ||= get_repo
  end

  def get_repo
    repo_dir = `git rev-parse --show-toplevel`.chomp

    if $? == 0
      Dir.chdir repo_dir
      @repo = Grit::Repo.new(repo_dir)
    else
      raise GitError, "We don't seem to be in a git repository."
    end
  end

  def with_stash
    stashed = false

    if change_count > 0
      puts "stashing #{change_count} changes".magenta
      repo.git.stash
      stashed = true
    end

    yield

    if stashed
      puts "unstashing".magenta
      repo.git.stash({}, "pop")
    end
  end

  def checkout(branch_name)
    output = repo.git.checkout({}, branch_name)
    puts "checking out #{branch_name}".yellow

    unless on_branch?(branch_name)
      raise GitError.new("Failed to checkout #{branch_name}", output)
    end
  end

  def on_branch?(branch_name=nil)
    repo.head.respond_to?(:name) and repo.head.name == branch_name
  end

  class GitError < StandardError
    def initialize(message, output=nil)
      @msg = "#{message.red}"

      if output
        @msg << "\n"
        @msg << "Here's what Git said:".red
        @msg << "\n"
        @msg << output
      end
    end

    def message
      @msg
    end
  end

private
  def change_count
    @change_count ||= begin
      repo.git.status(:porcelain => true, :'untracked-files' => 'no').split("\n").count
    end
  end
end
