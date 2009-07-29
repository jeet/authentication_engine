class User < ActiveRecord::Base
  include AuthenticationEngine::User

  acts_as_authentic

  # # Authorization plugin
  # acts_as_authorized_user
  # acts_as_authorizable
  # authorization plugin may need this too, which breaks the model
  # attr_accesibles need to merged; this resets it
  # attr_accessible :role_ids

  named_scope :inactivated, :conditions => ['updated_at = created_at']

  before_destroy :deny_admin_suicide

  # We need to distinguish general signup or invitee singup
  def signup!(user, prompt, &block)
    return save(true, &block) if openid_complete?
    return signup_as_invitee!(user, prompt, &block) if user and user[:invitation_id]
    signup_without_credentials!(user, &block)
  end

  private

  # one admin at least
  def deny_admin_suicide
    raise 'admin suicided' if User.count(&:admin) <= 1
  end
end
