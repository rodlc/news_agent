class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.direction = "user"

    if @message.save
      # Traiter l'API de manière synchrone (simple et direct)
      assistant_message = process_ai_response

      respond_to do |format|
        format.turbo_stream do
          # Ajouter la réponse de l'assistant et reset du form
          # (Le loading est supprimé côté client par Stimulus)
          render turbo_stream: [
            turbo_stream.append("messages", partial: "messages/message", locals: { message: assistant_message }),
            turbo_stream.replace("message_form", partial: "messages/form", locals: { chat: @chat, message: Message.new })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "messages/form",
            locals: { chat: @chat, message: @message }
          )
        end
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def process_ai_response
    ruby_llm_chat = RubyLLM.chat(model: "gpt-4o")
    ruby_llm_chat = ruby_llm_chat.with_instructions(
      "Your name is Newsagent: a helpful assistant explaining news simply, like to a high school student, providing historical context to help understand events better."
    )

    # Construction de l'historique des messages
    @chat.messages.where.not(id: @message.id).order(:created_at).each do |msg|
      if msg.direction == "user"
        ruby_llm_chat.add_message(role: :user, content: msg.content)
      else
        ruby_llm_chat.add_message(role: :assistant, content: msg.content)
      end
    end

    # Appel à l'API
    response = ruby_llm_chat.ask(@message.content)

    # Créer et retourner le message de l'assistant
    @chat.messages.create!(
      content: response.content,
      direction: "assistant"
    )
  rescue => e
    # En cas d'erreur, créer un message d'erreur
    @chat.messages.create!(
      content: "Désolé, une erreur s'est produite : #{e.message}",
      direction: "assistant"
    )
  end
end
