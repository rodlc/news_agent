# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    
    # Vérification de sécurité
    unless @chat.user == current_user
      redirect_to root_path, alert: "Accès refusé"
      return
    end
    
    # 1. Créer le message de l'utilisateur
    @message = @chat.messages.build(message_params)
    @message.direction = "user"
    
    if @message.save
      # 2. Appeler HuggingFace pour générer la réponse
      begin
        response_content = HuggingfaceService.new(@chat).generate_response
        
        # 3. Créer le message de l'assistant
        @chat.messages.create!(
          content: response_content,
          direction: "assistant"
        )
        
        redirect_to chat_path(@chat), notice: "Message envoyé !"
      rescue => e
        redirect_to chat_path(@chat), alert: "Erreur API : #{e.message}"
      end
    else
      redirect_to chat_path(@chat), alert: "Le message ne peut pas être vide"
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
