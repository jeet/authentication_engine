module AuthenticationEngine
  module User
    # require authlogic
    module ClassMethods
      def password_salt_is_changed?
        password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil
      end
    end

    # require authlogic
    module InstanceMethods
      # We need to distinguish general signup or invitee singup
      def signup!(user, prompt, &block)
        return save(true, &block) if respond_to?(:openid_identifier) && openid_complete?
        return signup_as_invitee!(user, prompt, &block) if respond_to?(:signup_as_invitee!) && user && user[:invitation_id]
        return signup_by_openid!(user, &block) if respond_to?(:signup_by_openid!) && user && !user[:openid_identifier].blank?
        signup_without_credentials!(user, &block)
      end
      
      # Since users have to activate themself with credentials,
      # we should signup without session maintenance and save with block.
      def signup_without_credentials!(user, &block)
        unless user.blank?
          self.name = user[:name] unless user[:name].blank?
          self.email = user[:email] unless user[:email].blank?
        end
        # only one user can be admin
        self.admin = true if self.class.count == 0
        save_with_block(true, &block)
      end

      # We need to save with block to prevent double render/redirect error.
      def save_with_block(logged, &block)
        if logged
          result = save_without_session_maintenance
          yield(result) if block_given?
          result
        else
          save(true, &block)
        end
      end

      # we only have name and email for a new created user
      def to_param
        "#{id}-#{name.parameterize}"
      end

      private

      # one admin at least
      def deny_admin_suicide
        raise 'admin suicided' if self.class.count(&:admin) <= 1
      end
    end

    # require authlogic
    module PasswordResetMethods
      # Since password reset doesn't need to change openid_identifier,
      # we save without block as usual.
      def reset_password_with_params!(user)
        self.class.ignore_blank_passwords = false
        self.password = user[:password]
        self.password_confirmation = user[:password_confirmation]
        save
      end

      def deliver_password_reset_instructions!
        reset_perishable_token!
        UserMailer.deliver_password_reset_instructions(self)
      end
    end

    # require authlogic-oid
    module AuthlogicOpenIdMethods
      def self.included(receiver)
        receiver.class_eval do
          # extend/include methods of authlogic-oid in case of no methods found
          extend AuthlogicOpenid::ActsAsAuthentic::Config
          include AuthlogicOpenid::ActsAsAuthentic::Methods
          
          attr_accessible :openid_identifier
          
          merge_validates_length_of_login_field_options :if => :validate_login_with_openid?
          merge_validates_format_of_login_field_options :if => :validate_login_with_openid?
          
          openid_required_fields [:nickname, :email]
          openid_optional_fields [:fullname, :dob, :gender, :postcode, :country, :language, :timezone]
          
          # hack by alias_method_chain for authlogic-oid
          alias_method_chain :attributes_to_save, :reliability
          alias_method_chain :map_openid_registration, :custom_fields
        end
      end

      def signup_by_openid!(user, &block)
        unless user.blank?
          self.name = user[:name] unless user[:name].blank?
          self.email = user[:email] unless user[:email].blank?
          self.openid_identifier = user[:openid_identifier]
        end
        save_with_block(false, &block)
      end

      # check when user's credentials changed
      def validate_login_with_openid?
        validate_password_with_openid?
      end

      private

      # fetch persona from openid.sreg parameters returned by openid server if supported
      # http://openid.net/specs/openid-simple-registration-extension-1_0.html
      def map_openid_registration_with_custom_fields(registration)
        self.nickname ||= registration["nickname"] if respond_to?(:nickname) && !registration["nickname"].blank?
        self.login ||= registration["nickname"] if respond_to?(:login) && !registration["nickname"].blank?
        self.email ||= registration["email"] if respond_to?(:email) && !registration["email"].blank?
        self.name ||= registration["fullname"] if respond_to?(:name) && !registration["fullname"].blank?
        self.first_name ||= registration["fullname"].split(" ").first if respond_to?(:first_name) && !registration["fullname"].blank?
        self.last_name ||= registration["fullname"].split(" ").last if respond_to?(:last_name) && !registration["fullname"].blank?
        self.birthday ||= registration["dob"] if respond_to?(:birthday) && !registration["dob"].blank?
        self.gender ||= registration["gender"] if respond_to?(:gender) && !registration["gender"].blank?
        self.postcode ||= registration["postcode"] if respond_to?(:postcode) && !registration["postcode"].blank?
        self.country ||= registration["country"] if respond_to?(:country) && !registration["country"].blank?
        self.language ||= registration["language"] if respond_to?(:language) && !registration["language"].blank?
        self.timezone ||= registration["timezone"] if respond_to?(:timezone) && !registration["timezone"].blank?
      end

      # reject more protected attributes of model
      def attributes_to_save_with_reliability
        attrs_to_save = attributes_to_save_without_reliability
        attrs_to_save.reject { |k,v| [:admin, :invitation_limit].include?(k.to_sym) }
      end
    end

    # require authlogic-oid
    module ActivationMethods
      # Since openid_identifier= will trigger openid authentication,
      # we save with block.
      def activate!(user, prompt, &block)
        unless user.blank?
          self.login = user[:login]
          self.password = user[:password]
          self.password_confirmation = user[:password_confirmation]
          self.openid_identifier = user[:openid_identifier] if respond_to?(:openid_identifier)
        end
        logged = prompt && validate_password_with_openid?
        save_with_block(logged, &block)
      end

      def deliver_activation_instructions!
        # skip reset perishable token since we don't set roles in signup!
        reset_perishable_token!
        UserMailer.deliver_activation_instructions(self)
      end

      def deliver_activation_confirmation!
        reset_perishable_token!
        UserMailer.deliver_activation_confirmation(self)
      end
    end

    # require authlogic-oid
    module InvitationMethods
      def self.included(receiver)
        receiver.class_eval do
          has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
          belongs_to :invitation
          
          validates_length_of :login, :within => 3..100, :on => :create, :if => :invited_and_require_password?
          validates_format_of :login, :with => /\A\w[\w\.\-_@ ]+\z/, :on => :create, :message => I18n.t('authlogic.error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please."), :if => :invited_and_require_password?
          validates_uniqueness_of :login, :on => :create, :case_sensitive => false, :if => :invited_and_require_password?

          validates_length_of :password, :minimum => 4, :on => :create, :if => :invited_and_require_password?
          validates_confirmation_of :password_confirmation, :on => :create, :if => :invited_and_require_password?
          validates_length_of :password_confirmation, :minimum => 4, :on => :create, :if => :invited_and_require_password?
          
          validates_uniqueness_of :invitation_id, :allow_nil => true
          attr_accessible :invitation_id
          
          before_create :set_invitation_limit
        end
      end

      # Since invitee need to be activated with credentials,
      # we save with block.
      def signup_as_invitee!(user, prompt, &block)
        self.attributes = user if user
        logged = prompt && validate_password_with_openid?
        save_with_block(logged, &block)
      end

      def invitation_token
        invitation.token if invitation
      end

      def invitation_token=(token)
        self.invitation = Invitation.find_by_token(token)
      end

      def invited_and_require_password?
        !invitation_id.blank? && validate_password_with_openid?
      end

      def deliver_invitation_activation_notice!
        # return unless self.invitation
        UserMailer.deliver_invitation_activation_notice(self)
      end

      private

      def set_invitation_limit
        self.invitation_limit = 5
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :include, PasswordResetMethods
      receiver.send :include, AuthlogicOpenIdMethods
      receiver.send :include, ActivationMethods
      receiver.send :include, InvitationMethods
      receiver.class_eval do
        validates_presence_of :name
        
        attr_accessible :name, :email, :login, :password, :password_confirmation
        
        merge_validates_length_of_login_field_options :on => :update
        merge_validates_format_of_login_field_options :on => :update, :message => I18n.t('authlogic.error_messages.login_invalid')
        merge_validates_uniqueness_of_login_field_options :on => :update
        
        merge_validates_length_of_password_field_options :on => :update
        merge_validates_confirmation_of_password_field_options :on => :update, :if => :password_salt_is_changed?
        merge_validates_length_of_password_confirmation_field_options :on => :update
        
        before_destroy :deny_admin_suicide
      end
    end
  end
end