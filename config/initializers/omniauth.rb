require 'omniauth-facebook'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK_CONFIG['app_id'], FACEBOOK_CONFIG['secret'], {:scope => 'email,user_friends,user_actions.fitness'}

  OmniAuth.config.on_failure = UsersController.action(:oauth_failure)




end
