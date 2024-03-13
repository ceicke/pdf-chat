class Prompt < ApplicationRecord
  validate :prompt_must_contain_question_placeholder

  scope :last_chosen, -> { where(chosen: true).order(created_at: :desc).limit(1) }

  private

  def prompt_must_contain_question_placeholder
    unless prompt.include?('%question')
      errors.add(:prompt, "must include the '%question' placeholder")
    end
  end
end
