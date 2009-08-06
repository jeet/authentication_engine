module AuthenticationEngine
  module Authorization
    # use ActionController::Filters to work with authorization
    # http://api.rubyonrails.org/classes/ActionController/Filters/ClassMethods.html
    module Base
      module ClassMethods
        
      end

      module InstanceMethods
        protected

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