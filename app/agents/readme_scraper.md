Here are some comments on how the scraper works and changes made to enable

Scraper
The scraper work with app.tavily.com,
documentation: https://docs.tavily.com/documentation/api-reference/endpoint/search
For our MVP one of the developer holds the key, which should never be pushed to git!
Key probably needs to be put on Heroku?

We want the scraper to have 3 modes:
Mode 1. Scrape an URL that is injected in the chat message...
Mode 2. Scrape web based on system prompt (personalized)
Mode 3. Scrape some basics defined urls for updates..

We start with Mode 1 for now.

-----

Done list:
- added API to env. / ensured it's in gitignore
