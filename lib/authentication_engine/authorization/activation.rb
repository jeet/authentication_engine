module AuthenticationEngine
  module Authorization
    module Activation
      module ClassMethods
        
      end

      module InstanceMethods
        protected

        def limited_or_public_signup
          redirect_to root_url unless REGISTRATION[:limited] or REGISTRATION[:public]
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          before_filter :limited_or_public_signup, :only => [:new, :create]
          before_filter :require_no_user, :only => [:new, :create]
        end
      end
    end
  end
end