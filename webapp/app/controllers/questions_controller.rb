class QuestionsController < ApplicationController
  def index
  end

  def create
    @question = question
    res = Rails.configuration.weaviate.ask(question: Prompt.last_chosen.first.prompt.gsub('%question', @question))
    
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @answer = markdown.render(res.raw_response['choices'].first['message']['content'])
  end

  private
  def question
    params[:question][:question]
  end

end
