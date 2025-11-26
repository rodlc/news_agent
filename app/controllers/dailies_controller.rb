class DailiesController < ApplicationController
  before_action :set_chat, only: [:new, :create]

  def new
    @last_message = @chat.messages.order(created_at: :desc).first
    
    # On crée une instance vide en mémoire
    @daily = Daily.new(content: @last_message&.content)
  end

  def create
    # 1. On crée le daily avec les données du formulaire
    @daily = Daily.new(daily_params)
    
    if @daily.save
      # 2. Si le daily est sauvé, on l'associe au chat
      @chat.daily = @daily
      @chat.save
      
      redirect_to @daily, notice: "Daily créé avec succès."
    else
      # Si ça échoue, on ré-affiche le formulaire
      @last_message = @chat.messages.order(created_at: :desc).first
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def daily_params
    params.require(:daily).permit(:content, :title)
  end
end
