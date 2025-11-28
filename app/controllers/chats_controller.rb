class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_daily, only: [:create]
  before_action :set_chat, only: [:show, :generate_summary]

  def create
    @chat = Chat.new(
      name: "Discussion #{Time.zone.now.strftime('%H:%M')}",
      daily: @daily,
      user: current_user
    )

    if @chat.save
      redirect_to chat_path(@chat), notice: "Chat créé !"
    else
      redirect_to daily_path(@daily), alert: "Erreur : #{@chat.errors.full_messages.join(', ')}"
    end
  end

  def show
    @message = Message.new(chat: @chat)
  end

  def generate_summary
    # Validation : s'assurer qu'il y a des messages
    if @chat.messages.empty?
      redirect_to chat_path(@chat), alert: "Aucun message dans ce chat pour générer un résumé."
      return
    end

    # Créer un Daily à partir du chat si il n'existe pas encore
    if @chat.daily.nil?
      daily = Daily.create!(
        title: "",
        summary: "",
        user: current_user
      )
      @chat.update!(daily: daily)
    end

    redirect_to edit_daily_path(@chat.daily), notice: "Génération du résumé en cours..."
  end

  private

  def set_daily
    @daily = Daily.find(params[:daily_id])
    redirect_to root_path, alert: "Accès refusé" unless @daily.user == current_user
  end

  def set_chat
    @chat = Chat.find(params[:id])
    redirect_to root_path, alert: "Accès refusé" unless @chat.user == current_user
  end
end
