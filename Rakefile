require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.libs << %w{test lib}
  task.pattern = 'test/**/test_*.rb'
end
module Bundler
  class GemHelper
    def rubygem_push(path)
      gem_server_url = 'http://cin-dwnld:9292'
      sh("gem inabox '#{path}' --host #{gem_server_url}")
      Bundler.ui.confirm "Pushed #{name} #{version} to #{gem_server_url}"
    end
  end
end

