class Invitation < ActiveRecord::Base
  include AuthenticationEngine::Invitation

  named_scope :invited, lambda {|mail| {:conditions => ['recipient_email = ? AND sent_at IS NOT NULL', mail]} }

  # Authorization plugin
  # acts_as_authorizable
end
