def rubyize_json(request)
  response = request.run
  puts response.response_body
end
