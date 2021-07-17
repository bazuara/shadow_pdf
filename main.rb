#!/usr/bin/env ruby

require 'yaml'
require 'oauth2'
require 'json'


# Load credentials
begin
  config = YAML.load_file("secret.credentials.yml")
  client_id = config["api"]["client_id"]
  client_secret = config["api"]["client_secret"]
rescue StandardError => err
  p "Rescue @Load_api_credentials #{err.inspect}"
  p "Wrong secret.credentials.yml file, are you sure it exist and is formated ok?"
end

ARGV.each_with_index do |value, i|
  p "ARG #{i} #{value}"
end

user = ARGV.first

# Check credentials
begin
  client = OAuth2::Client.new(client_id, client_secret, site: "https://api.intra.42.fr")
  token = client.client_credentials.get_token
  answer = token.get("/v2/users/#{user}")
rescue StandardError => err
  p "Rescue @Check_api_credentials #{err.inspect}"
  p "Wrong secret.credentials.yml content, please check your credentials"
end
if answer.status != 200
  p "Sorry, something went wrong with the API, try it later or report the problem"
  exit
end
user_data = answer.parsed
p answer.status
p user_data['usual_full_name']
