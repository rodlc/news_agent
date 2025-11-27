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
    @daily = Daily.new(
      title: "Résumé du #{Time.zone.now.strftime('%d/%m/%Y')}",
      summary: "",
      user: current_user
    )

    if @daily.save
      # Créer un chat vide pour commencer à itérer
      chat = Chat.create!(
        name: "Discussion #{Time.zone.now.strftime('%H:%M')}",
        daily: @daily,
        user: current_user
      )

      redirect_to chat_path(chat), notice: "Nouveau résumé créé ! Commencez à discuter pour générer votre résumé."
    else
      redirect_to root_path, alert: "Erreur lors de la création du résumé"
    end
  end

  def edit
  end

  def update
    if @daily.update(daily_params)
      # Créer un nouveau chat avec le résumé comme premier message
      chat = Chat.create!(
        name: "Discussion #{Time.zone.now.strftime('%H:%M')}",
        daily: @daily,
        user: current_user
      )

      # Ajouter le résumé comme premier message de l'assistant
      Message.create!(
        chat: chat,
        content: @daily.summary.presence || "Aucun résumé pour l'instant.",
        direction: "assistant"
      )

      redirect_to chat_path(chat), notice: "Chat créé avec le résumé !"
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
end
