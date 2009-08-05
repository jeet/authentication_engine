class UsersController < ApplicationController
  include AuthenticationEngine::Authorization::User
  before_filter :find_user, :only => [:show, :edit, :update]

  # GET /account
  def show
  end

  # GET /accept/:invitation_token
  # GET /signup
  def new
    if find_invitation
      @user = User.new(
        :name => @invitation.recipient_name,
        :email => @invitation.recipient_email,
        :invitation_id => @invitation.id
      )
    elsif REGISTRATION[:public]
      @user = User.new
    else
      redirect_to root_url
    end
  end

  # GET /account/edit
  def edit
  end

  # POST /account
  def create
    redirect_to root_url and return unless find_invitation or REGISTRATION[:public]

    @user = User.new

    @user.signup!(params[:user], SIGNUP[:prompt]) do |result|
      if result
        if @user.invitation
          @user.deliver_activation_confirmation!
          #TODO: fix failing mailer template
          # @user.deliver_invitation_activation_notice!
          flash[:success] = t('activations.flashs.success.create')
          redirect_to account_url
        else
          @user.deliver_activation_instructions!
          flash[:success] = t('users.flashs.success.create')
          redirect_to root_url
        end
      else
        render :action => :new
      end
    end
  end

  # PUT /account
  def update
    @user.attributes = params[:user]

    @user.save do |result|
      if result
        flash[:success] = t('users.flashs.success.update')
        redirect_to account_url
      else
        render :action => :edit
      end
    end
  end

  protected

  def find_user
    @user = @current_user
    redirect_to root_url if @user.blank?
  end

  def find_invitation
    return false unless params[:invitation_token]
    @invitation = Invitation.find_by_token(params[:invitation_token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url
  end
end
