module Helpers
  # :nodoc:
  module ControllerHelpers
    def sign_in(as: nil, token: 'access_token')
      allow(controller).to receive(:logged_in?).and_return(true)

      allow(controller).to receive(:token_expired).and_return(false)

      # Set the access token for the session
      allow(controller).to receive(:token).and_return(token)

      user = as || FactoryGirl.build(:user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end
end
