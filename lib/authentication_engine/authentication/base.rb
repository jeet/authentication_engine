module AuthenticationEngine
  module Authentication
    module Base
      module ClassMethods

      end

      module InstanceMethods
        protected

        def current_user_session
          @current_user_session ||= UserSession.find
        end

        def current_user
          @current_user ||= current_user_session && current_user_session.record
        end

        def store_location
          session[:return_to] = request.request_uri
        end

        def redirect_back_or_default(default)
          redirect_to(session[:return_to] || default)
          session[:return_to] = nil
        end

        # Helper method to determine whether the current user is an administrator
        def admin?
          current_user && current_user.admin?
        end

        def limited_signup
          redirect_to root_url unless REGISTRATION[:limited]
        end

        def public_signup
          redirect_to root_url unless REGISTRATION[:public]
        end
      end

      # Inclusion hook to make #current_user and #current_user_session
      # available as ActionView helper methods.
      def self.included(receiver)
        receiver.extend ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          helper_method :current_user_session, :current_user, :admin?
          filter_parameter_logging :password, :password_confirmation
        end
      end
    end
  end
end