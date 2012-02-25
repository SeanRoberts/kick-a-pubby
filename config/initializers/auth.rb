require 'omniauth/strategies/steam'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :steam, '3606FB72D46F2509FA118C98B902D541'
end