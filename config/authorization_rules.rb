authorization do
  role :guest do
    # Don't remove this or you can't signup
    has_permission_on :users, :to => :create
  end

  role :member do
    has_permission_on :users, :to => [:show, :update]
  end

  role :author do
    has_permission_on :users, :to => [:show, :update]
  end

  role :manager do
    has_permission_on :users, :to => [:show, :update]
  end

  role :admin do
    has_permission_on :users, :to => :manage
    has_permission_on :roles, :to => :manage
  end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
