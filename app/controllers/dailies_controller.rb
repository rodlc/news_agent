class DailiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_daily, only: [:edit, :update, :destroy]

  def index
    @dailies = current_user.dailies.order(created_at: :desc)
  end

  def new
    # Pas besoin de formulaire, on redirige directement vers create
    redirect_to dailies_path, method: :post
  end

  def create
    # Créer un chat sans Daily pour commencer à itérer
    chat = Chat.create!(
      name: "Discussion #{Time.zone.now.strftime('%H:%M')}",
      daily: nil,
      user: current_user
    )

    redirect_to chat_path(chat), notice: "Nouveau chat créé ! Commencez à discuter pour générer votre résumé."
  end

  def edit
    # Pré-remplir automatiquement si le Daily est vide
    if @daily.title.blank? && @daily.summary.blank?
      chat = @daily.chats.last

      if chat.present? && chat.messages.any?
        result = generate_summary_with_llm(chat)
        @daily.title = result[:title]
        @daily.summary = result[:summary]
      end
    end
  end

  def update
    if @daily.update(daily_params)
      redirect_to dailies_path, notice: "Résumé sauvegardé avec succès !"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @daily.destroy
    redirect_to dailies_path, notice: "Résumé supprimé"
  end

  private

  def set_daily
    @daily = Daily.find(params[:id])
    redirect_to root_path, alert: "Accès refusé" unless @daily.user == current_user
  end

  def daily_params
    params.require(:daily).permit(:summary, :title)
  end

  def generate_summary_with_llm(chat)
    # 1. Configuration du LLM
    ruby_llm_chat = RubyLLM.chat(provider: :openai, model: ENV['GITHUB_MODEL'])

    system_prompt = <<~PROMPT
      Tu es un assistant expert en synthèse d'actualité.

      CONTEXTE:
      L'utilisateur a eu une conversation avec toi sur un sujet d'actualité.
      Tu dois maintenant générer un résumé structuré de cette actualité.

      INSTRUCTIONS:
      1. Analyse l'historique de la conversation fournie
      2. Identifie le sujet principal et la date de l'actualité
      3. Génère un TITRE court et percutant (max 80 caractères)
      4. Génère un RÉSUMÉ structuré au format Markdown suivant:

         ## ⚡ Résumé exécutif
         [3 points clés maximum]

         ## 📰 Détails
         **Contexte** : [Contexte et parties prenantes]
         **Faits** : [Résumé des faits principaux]
         **Sources** : [Sources mentionnées]

      IMPORTANT:
      - Réponds UNIQUEMENT avec un JSON au format suivant:
        {
          "title": "Le titre ici",
          "summary": "Le résumé markdown ici"
        }
      - Ne rajoute AUCUN texte avant ou après le JSON
    PROMPT

    ruby_llm_chat.with_instructions(system_prompt)

    # 2. Reconstitution de l'historique complet du chat
    chat.messages.order(:created_at).each do |msg|
      role = msg.direction == "user" ? :user : :assistant
      ruby_llm_chat.add_message(role: role, content: msg.content)
    end

    # 3. Demande de génération
    response = ruby_llm_chat.ask("Génère maintenant le titre et le résumé au format JSON.")
    content = response.content.strip

    # 4. Parsing du JSON
    parsed = JSON.parse(content)

    {
      title: parsed["title"] || "Résumé du #{Time.zone.now.strftime('%d/%m/%Y')}",
      summary: parsed["summary"] || ""
    }
  rescue JSON::ParserError => e
    # Fallback si le LLM ne respecte pas le format JSON
    {
      title: "Résumé du #{Time.zone.now.strftime('%d/%m/%Y')}",
      summary: "Erreur de génération : Le LLM n'a pas renvoyé un JSON valide.\n\nRéponse brute :\n#{content}"
    }
  end
end
