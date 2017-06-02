require 'octokit'
require 'io/console'


class RepogitoryManager

  def initialize(id, password)
    @handler = Octokit::Client.new(login: id, password: password)
    @repositories = self.get_repositories
    @users = self.users_with_joined_repositories(@repositories)
  end

  def get_repositories
    @handler.repos.map do |r|
      r.full_name
    end
  end

  def users_with_joined_repositories(repos)
    users = {}
    repos.each do |r|
      @handler.collaborators(r).each do |c|
        users[c.login] = [] unless users[c.login]
        users[c.login] << r
      end
    end
    return Hash[users.sort]
  end

  def print_users_csv
    # header
    puts (['user'] + @repositories).join(',')

    # body
    @users.each do |u,joined_rps|
      printf "%s", u
      @repositories.each do |r|
        printf ",%d", joined_rps.include?(r) ? 1 : 0
      end
      puts
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  begin
    if ENV['GITHUB_ID'] && ENV['GITHUB_PASSWORD']
      id   = ENV['GITHUB_ID']
      pass = ENV['GITHUB_PASSWORD']
    else
      STDERR.print "id? "
      id = gets.chomp!

      STDERR.print "pass? "
      pass = STDIN.noecho(&:gets).chomp!

      STDERR.puts
    end
    rm = RepogitoryManager.new(id, pass)
    rm.print_users_csv
  rescue => e
    puts "ERROR: #{e}"
  end
end
