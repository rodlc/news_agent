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



  ####test test test Jen

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
