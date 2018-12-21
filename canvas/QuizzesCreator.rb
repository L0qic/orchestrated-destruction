require 'httparty'
require 'time'
require 'active_support/all'
require 'json'
require 'typhoeus'
require 'pry'
require_relative "quiz_question_creator"



@access_token = "Bearer "
@base_url = ""
#build course_id out to be an array of course ids that can be looped through
@course_ids = ""
@number_of_quizzes = 1
@randomize_types = false
@quiz_settings = {}
# @qz_random_assign_groups = false
# @qz_time_limit = nil
# @qz_shuffle_answers = false
# @qz_hide_results = ""
# @qz_show_correct_answers = true
# @qz_show_correct_answers_last_attempt = false
# @qz_show_correct_answers_at = nil
# @qz_hide_correct_answers_at = nil
# @qz_allowed_attempts = 1
# @qz_scoring_policy = "keep_highest"
# @qz_one_question_at_a_time = false
# @qz_cant_go_back = false
# @qz_access_code = nil
# @qz_ip_filter = nil
# @qz_due_at = nil
# @qz_lock_at = nil
# @qz_unlock_at = nil
# @qz_published = true
# @qz_one_time_results = false
# @qz_only_visible_to_overrides = false

QUIZ_TYPES = ['assignment', 'practice_quiz', 'graded_survey', 'survey'].freeze

def truthy?(value)
  value == "true"
end

def get_info_from_user
  puts "What is the base URL for your environment? (ex: http://localhost:3000): "
  base_url_reply = gets.chomp
  @base_url << base_url_reply

  puts "What is your API token for this instance?: "
  api_token_reply = gets.chomp
  @access_token << api_token_reply

  puts "Input comma separated list of which Canvas course IDs you would like to create quizzes in? (ex: 1,5,7,23,100) : "
  courses_reply = gets.chomp
  @course_ids = courses_reply.split(",")

  puts "How many quizzes would you like per course?: "
  no_of_quizzes = gets.chomp
  @number_of_quizzes = no_of_quizzes.to_i

  puts "Randomize quiz types? (Y/N): "
  rndm = gets.chomp.upcase
  @randomize_types = true if rndm == "Y"

  puts "Do you want to pass specific quiz settings? (Y/N): "
  apply_quiz_settings = (gets.chomp.upcase == "Y") ? true : false

  if apply_quiz_settings
    # puts "Do you want to randomize the assignment groups the quizzes are placed in or use default? (Random/Default): "
    # @qz_random_assign_groups = true if (gets.chomp.upcase == "RANDOM")
    # if @qz_random_assign_groups
    qz_options = {time_limit: nil, shuffle_answers: nil, hide_results: nil, show_correct_answers: nil, show_correct_answers_last_attempt: nil, show_correct_answers_at: nil, hide_correct_answers_at: nil, allowed_attempts: nil, scoring_policy: nil, one_question_at_a_time: nil, cant_go_back: nil, access_code: nil, ip_filter: nil, due_at: nil, lock_at: nil, unlock_at: nil, published: nil, one_time_results: nil, only_visible_to_overrides: nil}
    puts "Leave blank any settings you don't wish to pass in."
    qz_options.each do |k, v|
      puts "#{k}: "
      case k
      when :time_limit, :allowed_attempts
        qz_options[k] = gets.chomp.to_i
      when :shuffle_answers, :show_correct_answers, :show_correct_answers_last_attempt, :one_question_at_a_time, :cant_go_back, :published, :one_time_results, :only_visible_to_overrides
        qz_options[k] = gets.chomp.downcase
        qz_options[k] = truthy?(qz_options[k])
      when :hide_results, :scoring_policy, :access_code, :ip_filter, :show_correct_answers_at, :hide_correct_answers_at, :due_at, :lock_at, :unlock_at
        qz_options[k] = gets.chomp
      end
    end
    @quiz_settings = qz_options
  end
end

def publish_quiz(course, quiz_id)
  quiz = Typhoeus.put(
    @base_url + "/api/v1/courses/#{course}/quizzes/#{quiz_id}",
    body: {
      quiz: {
        published: true
      }
    },
    headers: {:authorization => @access_token, 'Content-Type'=> "application/x-www-form-urlencoded"}
  )
  puts quiz
end


def create_quiz(course, quiz_num, make_random, options)
  quiz = Typhoeus::Request.new(
    @base_url + "/api/v1/courses/#{course}/quizzes",
    method: :post,
    params: {
      quiz: {
        quiz_type: type = make_random ? QUIZ_TYPES.sample : "assignment",
        title: "Testing Republish Automated #{type} quiz #{quiz_num}",
        description: "Automated #{type} quiz generated for testing purposes",
        assignment_group_id: options[:assignment_group_id],
        time_limit: options[:time_limit],
        shuffle_answers: options[:shuffle_answers],
        hide_results: options[:hide_results],
        show_correct_answers: options[:show_correct_answers],
        show_correct_answers_last_attempt: options[:show_correct_answers_last_attempt],
        show_correct_answers_at: options[:show_correct_answers_at],
        hide_correct_answers_at: options[:hide_correct_answers_at],
        allowed_attempts: options[:allowed_attempts],
        scoring_policy: options[:scoring_policy],
        one_question_at_a_time: options[:one_question_at_a_time],
        cant_go_back: options[:cant_go_back],
        access_code: options[:access_code],
        ip_filter: options[:ip_filter],
        due_at: options[:due_at],
        lock_at: options[:lock_at],
        unlock_at: options[:unlock_at],
        published: options[:published],
        one_time_results: options[:one_time_results],
        only_visible_to_overrides: options[:only_visible_to_overrides]
      }
    },
    headers: {:authorization => @access_token}
  )

  #quiz = HTTParty.post(URI.escape("#{@base_url}/api/v1/courses/#{@course_id}/quizzes?quiz[title]=#{quiz_title}&quiz[quiz_type]=#{quiz_type}&quiz[description]=#{quiz_description}&access_token=#{@access_token}"))
  # response = quiz.run
  # puts response.code

  quiz
end

def amount_of_quizzes(course, num, make_random = false, opts = {})
  hydra = Typhoeus::Hydra.new(max_concurrency: 30)
  num.times do |n|
    response = create_quiz(course, n+1, make_random, opts)
    response.on_complete do |resp|
      q_id = JSON.parse(resp.body)['id']
      builder = QuizQuestionCreator.new(@base_url, @access_token, course, q_id)
      builder.questions(["multiple_choice_question"])
      res = resp.code == 200 ? "Quiz Batch successfully created rate-limit:#{resp.headers['X-Rate-Limit-Remaining']}" : "Quiz Batch failed with following #{resp.code}"
      puts res
      binding.pry
      if opts[:published]
        quiz = publish_quiz(course, q_id)
      end
     end
    hydra.queue(response)
  end
  hydra.run
end

def perform
  get_info_from_user
  @course_ids.each do |crs|
    amount_of_quizzes(crs, @number_of_quizzes, @randomize_types, @quiz_settings)
  end
end

perform
