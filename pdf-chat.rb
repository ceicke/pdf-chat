require 'langchain'
require 'weaviate'
require 'openai'
require 'colorize'
require 'highline'
require "dotenv/load"

require 'pry'

# Instantiate the Weaviate client
weaviate = Langchain::Vectorsearch::Weaviate.new(
  url: 'http://127.0.0.1:8080',
  api_key: '',
  index_name: "PDF1",
  llm: Langchain::LLM::OpenAI.new(
    api_key: ENV["OPENAI_API_KEY"],
    default_options: {
      completion_model_name: 'gpt-4-1106-preview',
      chat_completion_model_name: 'gpt-4-1106-preview'
    }
  )
)

# Prepare to ask the user
cli = HighLine.new

# Happy chatting
while true do
  prompt = cli.ask('Was möchtest du wissen? '.yellow)
  res = weaviate.ask(question: prompt)
  puts res.raw_response['choices'].first['message']['content'].green
end
