require 'optparse'
require 'json'

def dyno_types(project)
  dyno_list = JSON.parse(`heroku ps --json -a #{project}`)
  dyno_types = []
  dyno_list.each do |dyno|
    dyno_types << dyno['type']
  end
  dyno_types
end

def scale_down(dyno_types, project)
  if !dyno_types.empty?
    puts "*********************************"
    puts "scalling down following dynos for #{project}: #{dyno_types.join(", ")}"
    dyno_types.each do |type|
    `heroku ps:scale #{type}=0 -a #{project}`

    end
  else
    puts "No dynos to scale down. #{project} is shutdown!"
  end
end

def shutdown_project(projects)
  projects.each do |project|
     puts "*********************************"
     puts "Shutting down #{project}"
     `heroku maintenance:on -a #{project}`
     scale_down(dyno_types(project), project)
  end
  puts "*********************************"
end

if ARGV.length < 1
  puts "Too few arguments"
  puts "Specify at least one app to shutdown"
  exit
else
  shutdown_project(ARGV)
end
