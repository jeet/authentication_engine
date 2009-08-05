module AuthenticationEngine
  module Authorization
    module User
      module ClassMethods
        
      end

      module InstanceMethods
        protected

        def no_user_signup
          redirect_to root_url unless REGISTRATION[:private] or REGISTRATION[:requested] or REGISTRATION[:public]
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          before_filter :no_user_signup, :only => [:new, :create]
          before_filter :require_no_user, :only => [:new, :create]
          before_filter :require_user, :only => [:show, :edit, :update]
        end
      end
    end
  end
end