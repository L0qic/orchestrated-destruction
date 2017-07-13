require 'typhoeus'
require 'json'
require 'time'
require '../config/config'
require '../rubyize_json'

@base_url = '<canvas_subdomain>'
@token = auth(1,'canvas')

puts 'What course would you like to start searching from'

course_start = gets.chomp.to_i

### courses
source_id = '<int_source_course_id>'
while course_start <= 2450
  course = Typhoeus::Request.new(
      @base_url + "/courses/#{courses_start}/content_migrations",
      headers: {:authorization => token},
  )
 response = rubyize_json(course)

  if response.empty?
    puts "course #{courses} does not have an import"
  elsif response[0]['migration_type'] == 'course_copy_importer'
    source_course = response[0]['settings']['source_course_name']
    source_course_id = response[0]['settings']['source_course_id']
    puts "Fail: Course #{courses} does not have an import from #{source_id}. Import is from #{source_course_id}" unless source_course == '<source_course_name>' && source_course_id == '<int_source_course_id>'
  end
    courses+= 1
end
