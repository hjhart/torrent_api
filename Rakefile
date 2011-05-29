require 'echoe'
Echoe.new('tpb', '0.0.1') do |p|
  p.description = "A API to query TPB"
  p.url = "http://www.github.com/hjhart/tpb"
  p.author = "James Hart"
  p.email = "hjhart@gmail.com"
  p.ignore_pattern = ["tmp/*", "scripts/*", "searches/*"]
  p.development_dependencies = []
end

task :default => :console

task :console do
  sh "irb -rubygems -r ./lib/pirate_bay.rb"
end
