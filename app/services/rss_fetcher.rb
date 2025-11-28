class RssFetcher
  BASE_URL = "https://news.google.com/rss/search"

  def self.search(query, date = nil)
    # Construction de la requête
    q_param = query

    # Filtrage temporel (Google News supporte after/before)
    if date
      begin
        target = Date.parse(date)
        # On cherche sur une fenêtre de 24h
        q_param += " after:#{target.strftime('%Y-%m-%d')} before:#{(target + 1.day).strftime('%Y-%m-%d')}"
      rescue Date::Error
        # Si la date est invalide, on cherche juste le mot clé sans planter
      end
    end

    # Appel Google News RSS (hl=fr pour forcer le français)
    url = "#{BASE_URL}?q=#{URI.encode_www_form_component(q_param)}&hl=fr&gl=FR&ceid=FR:fr"

    response = HTTParty.get(url)
    return "Aucun résultat trouvé ou erreur de connexion." unless response.success?

    feed = Feedjira.parse(response.body)

    # Extraction frugale des 5 premiers résultats
    return "Aucune actualité trouvée pour cette recherche." if feed.entries.empty?

    feed.entries.first(5).map do |entry|
      "- Titre: #{entry.title}\n  Lien: #{entry.url}\n  Publié: #{entry.published}"
    end.join("\n\n")

  rescue => e
    "Erreur système lors de la récupération RSS : #{e.message}"
  end
end
