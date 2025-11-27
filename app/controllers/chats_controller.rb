class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_daily, only: [:create]
  before_action :set_chat, only: [:show]

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
