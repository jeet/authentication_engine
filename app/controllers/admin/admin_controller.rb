class Admin::AdminController < ApplicationController
  include AuthenticationEngine::Authentication::Admin::Base
  # if you are using authorization_engine
  # permit 'root or admin'

  layout 'admin'
end
