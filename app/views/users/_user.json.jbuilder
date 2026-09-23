json.extract! user, :id, :name, :username, :picturelink, :theme, :created_at, :updated_at
json.url user_url(user, format: :json)
