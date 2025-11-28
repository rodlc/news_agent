# app/models/daily.rb
class Daily < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy


  def self.summarize_url(url_to_scrape)
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

    parsed = JSON.parse(response.read_body)
    # parsed["results"][0]["content"]
    # puts JSON.pretty_generate(parsed).class
  end
end
