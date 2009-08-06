if config.respond_to?(:gems)
  config.gem 'authlogic', :lib => 'authlogic', :version => '2.1.1', :source => "http://gems.github.com" unless defined? Authlogic
  config.gem 'authlogic-oid', :lib => 'authlogic_openid', :version => '>=1.0.4', :source => "http://gems.github.com"
  config.gem 'ruby-openid', :lib => 'openid', :version => '>=2.1.7'
  config.gem 'stffn-declarative_authorization', :lib => 'declarative_authorization', :source => 'http://gems.github.com', :version => '>=0.3.0'
else
  begin
    require 'authlogic'
    require 'authlogic_openid'
    require 'ruby-openid'
    require 'declarative_authorization'
  rescue LoadError
    begin
      gem 'authlogic', '2.1.1'
      gem 'authlogic-oid', '1.0.4'
      gem 'ruby-openid', '2.1.7'
      gem 'declarative_authorization', '0.3.0'
    rescue Gem::LoadError
      puts "Install the authlogic, authlogic_oid, ruby-openid, and declarative_authorization gems to enable authentication support"
    end
  end
end

config.to_prepare do
  ApplicationController.helper(LayoutHelper)
end
