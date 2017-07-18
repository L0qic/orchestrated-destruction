#!/usr/bin/env ruby
require 'csv'
require 'json'
require 'typhoeus'
require '../config/config'
require '../rubyize_json'

puts 'Enter Canvas subdomain'
subdomain = gets.chomp

@base_url = "https://#{subdomain}.instructure.com"
@token = auth(1,'canvas')


puts 'Please enter the account number'

acc_num = gets.chomp

puts 'Enter full file destination or drag and drop csv file'

counter = 0

csv_import = gets.chomp

if csv_import.include? '.csv'

  puts 'Enter column name containing course id\'s'

  col = gets.chomp

  puts '* \'offer\' makes a course visible to students. This action is also called "publish" on the web site.
* \'conclude\' prevents future enrollments and makes a course read-only for all participants. The course still appears
  in prior-enrollment lists.
* \'delete\' completely removes the course from the web site (including course menus and prior-enrollment lists).
  All enrollments are deleted. Course content may be physically deleted at a future date.
* \'undelete\' attempts to recover a course that has been deleted. (Recovery is not guaranteed; please conclude
  rather than delete a course if there is any possibility the course will be used again.) The recovered course
  will be unpublished. Deleted enrollments will not be recovered.'
  puts " "
  options= ['offer', 'conclude', 'delete', 'undelete']
  puts "Enter one of the options: #{options.join(', ')}"
  action = gets.chomp

    if options.include? action
      CSV.foreach(csv_import, headers:true) do |row|
        id=row[col]

        update_course = Typhoeus::Request.new(
            @base_url + "/api/v1/accounts/#{acc_num}/courses",
            method: :put,
            params: {
              event: action,
              'course_ids[]': id
            },
            headers: {
              authorization: @token)
            }
        )
         response = rubyize_json(update_course)
         puts response
      counter += 1
    end
  else
    puts "#{action} is not a valid option"
  end
else
  puts 'This is not a valid file type/destination'
  puts " "
  if counter == 1

    puts "#{counter} course has been updated!"
    puts " "
  else
    puts "#{counter} courses have been updated!"
    puts " "
  end
end
