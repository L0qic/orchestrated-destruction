require 'typhoeus'
require 'json'
# require 'forgery'
require '../config/config.rb'
require '../rubyize_json'

class QuizQuestionCreator
  QUESTION_TYPES = [
      "calculated_question",
       "essay_question",
       "file_upload_question",
        "fill_in_multiple_blanks_question",
        "matching_question",
        "multiple_answers_question",
        "multiple_choice_question",
        "multiple_dropdowns_question",
        "numerical_question",
        "short_answer_question",
        "text_only_question",
        "true_false_question"
    ].freeze

   attr_reader :base_url, :token, :course_id, :quiz_id

    def initialize(base_url, token, course_id, quiz_id)
       @base_url = base_url
       @token = token
       @course_id = course_id
       @quiz_id = quiz_id
     end

     def rubyize_json(request)
       response = request.run
       puts response.code
     end

     def questions(question_type = [])
         q_name = "name"
         q_text = "testing"
         points = rand(1..20)
         puts base_url
         puts course_id
         puts quiz_id
           question_type.each do | q_type |
                 question = Typhoeus::Request.new(
                       base_url + "/api/v1/courses/#{course_id}/quizzes/#{quiz_id}/questions",
                       method: :post,
                       params: {
                           :question=>{
                               :question_name => 'Question 1',
                               :question_text => 'automated essay question',
                               :question_type => q_type,
                               :points_possible => points,
                               :answers=> question_type_answer(q_type)
                           }
                       },
                       headers: { :authorization => token }
                 )
                 puts question
               rubyize_json(question)
           end
       end
     def question_type_answer(question_type)
            [
                 {text: "A", weight: 0},
                 {text: "B", weight: 0},
                 {text: "C", weight: 100},
                 {text: "D", weight: 0}
             ]
       end
end
