require 'typhoeus'
require 'json'
require 'time'
require '../config/config.rb'
require '../rubyize_json'

@base_url = '<bride_base_url>'
@token = auth(1,'bridge')

courses = <num_courses_to_create>

course_counter = 1
courses.times do
  course_tmp={
    'title'=> "Course #{course_counter}",
    'is_published' => true,
    'has_unpublished_changes' => false,
    'default_days_until_due' => 30,
    'course_type' => 'bridge'
  }

  course_resp = Typhoeus::Request.new(
      @base_url + '/api/author/course_templates',
      method: :post,
      params: {
        course_templates: { 'course' => course_tmp }
      },
      headers: { authorization: @token }
  )
  puts rubyize_json(course_resp)

  course_counter += 1
end
