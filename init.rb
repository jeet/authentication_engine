if config.respond_to?(:gems)
  config.gem 'authlogic', :lib => 'authlogic', :version => '2.1.1', :source => "http://gems.github.com" unless defined? Authlogic
  config.gem 'authlogic-oid', :lib => 'authlogic_openid', :version => '>=1.0.4', :source => "http://gems.github.com"
  config.gem 'ruby-openid', :lib => 'openid', :version => '>=2.1.7'
  config.gem 'state_machine', :version => '>=0.7.6'
else
  begin
    require 'authlogic'
    require 'authlogic_openid'
    require 'ruby-openid'
    require 'state_machine'
  rescue LoadError
    begin
      gem 'authlogic', '2.1.1'
      gem 'authlogic-oid', '1.0.4'
      gem 'ruby-openid', '2.1.7'
      gem 'state_machine', '0.7.6'
    rescue Gem::LoadError
      puts "Install the authlogic, authlogic_oid, and ruby-openid gems to enable authentication support"
    end
  end
end

require File.dirname(__FILE__) + '/lib/authentication_engine'

