require 'typhoeus'
require 'json'
require 'time'
require '../config/config'
require '../rubyize_json'


@base_url = '<canvas_subdomain>'
@token = auth(1,'canvas')

puts 'How many courses would you like to create'
courses = gets.chomp.to_i

puts 'Which account would you like to create these courses in?'
account=gets.chomp

count = 1

courses.times do
  course = Typhoeus::Request.new(
      @base_url + "api/v1/accounts/#{account}/courses",
      method: :post,
      params: {
        course: {
          name: "Course #{count}",
          course_code: "Course #{count}",
          sis_course_id: "coursesis#{count}"
        },
        offer: true,
        enroll_me: true,
      },
      headers: {:authorization => @token}
  )
  response = rubyize_json(course)
  puts response
  count += 1
end
