#this file includes the logic for a news scraper - modus 1 (definition in readme_scraper)
#copied from tavily doc: https://docs.tavily.com/documentation/api-reference/endpoint/search

#Import Ruby url handlers, , defined by T.
require 'uri'
require 'net/http'
require 'json'
require 'dotenv/load'  # Load .env file

def summarize_url(url_to_scrape)
  #parses taviliy endpoint (extracting some things needed later), , defined by T.
  url = URI("https://api.tavily.com/search")

  #some things defined by tavily for secure connection, , defined by T.
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  #creates post object, defined by T.
  request = Net::HTTP::Post.new(url)
  request["Content-Type"] = 'application/json'

  # Minimum request body - API key and query only
  request.body = {
    api_key: ENV['TAVILY_API_KEY'],
    query: url_to_scrape
  }.to_json

  #send request to Tavily
  response = http.request(request)

  #converts JSON output from above into a Ruby hash
  JSON.parse(response.read_body)
end

#test1
result = summarize_url("https://www.anthropic.com/news/claude-sonnet-4-5")
puts result
