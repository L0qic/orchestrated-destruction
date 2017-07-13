def rubyize_json(request)
  response = request.run
  JSON.load response.response_body
end
