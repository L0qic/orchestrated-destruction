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

def scale_up(dyno_types, project)
  if dyno_types.empty?
    dyno_types =['worker', 'web']
    puts "*********************************"
    puts "Scalling up following dynos for #{project}: #{dyno_types.join(", ")}"
    `heroku ps:scale #{dyno_types[0]}=1 #{dyno_types[1]}=1 -a #{project}`
  else
    puts "#{project} is now running!"
  end
end

def startup_project(projects)
  projects.each do |project|
     puts "*********************************"
     puts "Starting up #{project}"
     `heroku maintenance:off -a #{project}`
     scale_up(dyno_types(project), project)
  end
  puts "*********************************"
end

if ARGV.length < 1
  puts "Too few arguments"
  puts "Specify at least one app to startup"
  exit
else
  startup_project(ARGV)
end
