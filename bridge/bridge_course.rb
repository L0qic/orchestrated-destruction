require 'typhoeus'
require 'forgery'
require '../config/config.rb'
require '../rubyize_json'

@base_url = '<bride_base_url>'
@token = auth(1,'bridge')

def courses(course_count)
  if course_count >= 1
    course_temp = []
    course_count.times do
      course_title = Forgery::LoremIpsum.words(rand(1..3), random:true)
      course_description = Forgery::LoremIpsum.paragraphs(2, random: true)
      course_temp << {
          title: course_title,
          description: course_description,
          is_published: true,
          has_unpublished_changes: false,
          default_days_until_due: 10,
          course_type: 'bridge'
      }
    end
    create_courses(course_temp)
  else
    puts "Course count must be at least 1"
  end
end

def create_courses(course_temp)
  hydra = Typhoeus::Hydra.new(max_concurrency: 10)
  course_batch = course_temp.each_slice(10).to_a
  course_batch.each do |batch|
    course_resp = Typhoeus::Request.new(
        @base_url + '/api/author/course_templates',
        method: :post,
        params: {
          course_templates: batch
        },
        headers: { authorization: @token }
    )
    course_resp.on_complete do |response|
       res = response.code == 201 ? "Course Batch successfully created" : "Course Batch failed with following #{response.code}"
       puts res
    end
    hydra.queue(course_resp)
  end
  hydra.run
end

puts "How many courses would you like to create in Bridge for #{@base_url}?"

courses = gets.chomp

courses(courses.to_i)
