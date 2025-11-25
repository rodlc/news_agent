#is this redudnant?


class DailySynthesizer
  require .... -> ?


def self.all_messages(chat)
  return chat.messages.map { |message| message.content }
end


def self.summarize(chat)
	all_messages(chat) some actions

	prompt = " You are a professional news editor creating a daily digest from chat conversations.

  Below are messages from today's conversation. Your task is to:
  1. Create ONE compelling headline (max 10 words) that captures the main theme
  2. Write a concise summary (150-200 words) that:
     - Highlights the most important topics discussed
     - Captures key decisions, insights, or action items
     - Maintains a professional, informative tone
     - Flows as a coherent narrative, not just bullet points

  Format your response EXACTLY as:
  TITLE: [Your headline here]

  SUMMARY:
  [Your 150-200 word summary here]
  "

	summary ) call_open_ai(prompt)
end

def call_open_ai
 ....
end


#...where to send summary?

> #from messagesController
> DailySynthesizer.summarize(@chat)
