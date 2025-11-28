# Tool for scraping and summarizing URLs using Tavily API
# This tool is automatically called by the LLM when a user provides a URL
class UrlScraperTool < RubyLLM::Tool
  description "Scrape and summarize content from a URL. Use this when the user provides a link or asks about a webpage."

  param :url, description: "The URL to scrape and analyze"

  def execute(url:)
    # Call the Daily model's summarize_url method
    result = Daily.summarize_url(url)

    # Return the scraped content as a formatted string for the LLM to summarize
    if result && result["results"] && result["results"].any?
      # Extract the first result's content
      content = result["results"][0]["content"]
      title = result["results"][0]["title"]

      "Title: #{title}\n\nContent: #{content}"
    else
      "Could not retrieve content from the URL."
    end
  rescue => e
    "Error scraping URL: #{e.message}"
  end
end
