require 'ostruct'

class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])

    unless @chat.user == current_user
      redirect_to root_path, alert: "Accès refusé"
      return
    end

    @message = @chat.messages.build(message_params)
    @message.direction = "user"

    if @message.save
      begin
        @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o")
        @ruby_llm_chat = @ruby_llm_chat.with_instructions "Your name is Newsagent: a helpful assistant explaining news simply, like to a high school student, providing historical context to help understand events better."

        # Construction historique
        @chat.messages.where.not(id: @message.id).order(:created_at).each do |msg|
          role = msg.direction == "user" ? "user" : "assistant"
          @ruby_llm_chat.messages << OpenStruct.new(role: role, content: msg.content)
        end

        response = @ruby_llm_chat.ask(@message.content)

        @chat.messages.create!(
          content: response.content,
          direction: "assistant"
        )

        redirect_to chat_path(@chat), notice: "Message envoyé !"
      rescue => e
        redirect_to chat_path(@chat), alert: "Erreur API : #{e.message}"
      end
    else
      redirect_to chat_path(@chat), alert: "Message vide impossible"
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
