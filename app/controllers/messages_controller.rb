class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.direction = "user"

    if @message.save
      # Appel synchrone (bloquant le temps du calcul)
      assistant_message = process_ai_response

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("messages", partial: "messages/message", locals: { message: assistant_message }),
            turbo_stream.replace("message_form", partial: "messages/form", locals: { chat: @chat, message: Message.new })
          ]
        end
      end
    else
      # Gestion d'erreur standard
      render turbo_stream: turbo_stream.replace("message_form", partial: "messages/form", locals: { chat: @chat, message: @message })
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def process_ai_response
    # 1. Configuration du LLM
    ruby_llm_chat = RubyLLM.chat(provider: :openai, model: ENV['GITHUB_MODEL'])

    system_prompt = <<~PROMPT
          Tu es Newsagent. Ton but est de synthétiser l'actualité pour un lycéen.

          REGLES DE COMPORTEMENT:
          1. Si l'utilisateur ne donne pas de SUJET et de DATE, demande-les lui poliment.
          2. Si tu as le sujet et la date, tu DOIS répondre UNIQUEMENT un objet JSON au format suivant pour lancer la recherche :
             { "action": "search", "query": "mots clés du sujet", "date": "YYYY-MM-DD" }
          3. Si tu reçois du contenu RSS (commençant par "RESULTATS_RSS:"), synthétise-le.
             Format de réponse attendu
             ## ⚡ [Résumé exécutif]
             [1- Thème 1]
             [2- Thème 2]
             [3- Thème 3]

             ## 📰 [Titre de l'article]
             **Contexte** : [Injection de contexte sur les parties prenantes]
             **Faits** : [Résumé de l'article]
             **Source** : [Journal source]
        PROMPT

    ruby_llm_chat.with_instructions(system_prompt)
    
    #1. Detect URL in message and scrape content
    url_regex = URI::DEFAULT_PARSER.make_regexp(%w[http https])
    if @message.content.match?(url_regex)
      url = @message.content.match(url_regex)[0]

      # Fetch content using Daily model
      result = Daily.summarize_url(url)
      if result && result["results"] && result["results"].any?
        content = result["results"][0]["content"]
        title = result["results"][0]["title"]

        # Add scraped content to conversation before user's message
        ruby_llm_chat.add_message(
          role: :user,
          content: "Here's the content from #{url}:\n\nTitle: #{title}\n\nContent: #{content}\n\nPlease summarize this simply."
        )
      end
    end
    ## test jen end
    
    # 2. Reconstitution de l'historique
    @chat.messages.where.not(id: @message.id).order(:created_at).each do |msg|
      role = msg.direction == "user" ? :user : :assistant
      ruby_llm_chat.add_message(role: role, content: msg.content)
    end

    # 3. Premier "Round" de réflexion
    response = ruby_llm_chat.ask(@message.content)
    content = response.content

    # 4. Interception du JSON (Function Calling manuel)
    if content.strip.start_with?('{') && content.include?('"search"')
      begin
        data = JSON.parse(content)

        # Broadcast statut: Récupération de l'actualité
        broadcast_status_update("Récupération de l'actualité")

        # C'EST ICI QUE LA MAGIE OPÈRE (Appel corrigé)
        rss_results = RssFetcher.search(data["query"], data["date"])

        # Broadcast statut: Synthèse en cours
        broadcast_status_update("Synthèse en cours")

        # On injecte les résultats dans le contexte du LLM
        system_injection = "RÉSULTATS RSS OBTENUS :\n#{rss_results}\n\nInstruction : Synthétise ces infos maintenant."
        ruby_llm_chat.add_message(role: :user, content: system_injection)

        # 5. Second "Round" (Synthèse finale)
        final_response = ruby_llm_chat.ask("Synthétise.")
        content = final_response.content
      rescue JSON::ParserError
        content = "J'ai voulu chercher des news, mais j'ai fait une erreur technique interne (JSON invalide)."
      end
    end

    # 6. Création du message final en base
    @chat.messages.create!(
      content: content,
      direction: "assistant"
    )
  rescue => e
    @chat.messages.create!(
      content: "Désolé, une erreur critique est survenue : #{e.message}",
      direction: "assistant"
    )
  end

  def broadcast_status_update(status)
    Turbo::StreamsChannel.broadcast_update_to(
      "chat_#{@chat.id}",
      target: "loading-message-text",
      partial: "messages/loading_status",
      locals: { status: status }
    )
  end
end
