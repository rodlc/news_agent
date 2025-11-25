# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show]

  def create
    @chat = current_user.chats.build(chat_params)
    
    if @chat.save
      redirect_to chat_path(@chat), notice: "Chat créé avec succès !"
    else
      redirect_to root_path, alert: "Erreur lors de la création du chat"
    end
  end

  def show
    @message = Message.new
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
    
    # Sécurité : Vérifier que le chat appartient à l'utilisateur
    unless @chat.user == current_user
      redirect_to root_path, alert: "Accès refusé"
    end
  end

  def chat_params
    params.require(:chat).permit(:name, :daily_id)
  end
end
