json.extract! prompt, :id, :prompt, :chosen, :created_at, :updated_at
json.url prompt_url(prompt, format: :json)
