class APIKeys < Settingslogic
  source "#{Rails.root}/config/api_keys.yml"
  namespace Rails.env
end