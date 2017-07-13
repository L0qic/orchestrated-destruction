require 'yaml'
#token stuff

def token(token_id,platform)
  file = YAML.load_file('../config/config.yml')
  file["Credentials"]["#{platform}"]["token"][token_id.to_s]
end

def auth(token_id,plat)
  if plat.downcase == "canvas"
    auth_scheme = "Bearer"
  elsif plat.downcase == "bridge"
    auth_scheme = "Basic"
  else
    raise "Invalid platform"
  end
  "#{auth_scheme} #{token(token_id,plat)}"
end
