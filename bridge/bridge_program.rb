require 'typhoeus'
require 'json'
require '../rubyize_json'
require '../config/config'

@base_url = '<bride_base_url>'
@token = auth(1,'bridge')

def program(program_num)
  program_tmp={
    "title"=>"Program #{program_num}",
    "description"=>"Automated Program Creation",
    "is_published" => true
  }
  course_resp = Typhoeus::Request.new(
      @base_url + "/api/author/course_templates",
      method: :post,
      params: {:course_templates => {"course"=>program_tmp}},
      headers: {:authorization => @token}
  )
  puts rubyize_json(course_resp)
end

puts 'how many programs would you like to create?'
program_count = gets.chomp.to_i

counter = 1
program_count.times do
  program(counter)
  counter += 1
end
