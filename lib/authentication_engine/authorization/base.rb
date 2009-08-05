module AuthenticationEngine
  module Authorization
    # use ActionController::Filters to work with authorization
    # http://api.rubyonrails.org/classes/ActionController/Filters/ClassMethods.html
    module Base
      module ClassMethods
        
      end

      module InstanceMethods
        protected

        def require_user
          return if current_user
          store_location
          flash[:notice] = t('users.flashs.notices.login_required')
          redirect_to login_url
          return false
        end

        def require_no_user
          return unless current_user
          store_location
          flash[:notice] = t('users.flashs.notices.logout_required')
          redirect_to account_url
          return false
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          
        end
      end
    end
  end
end