class UsersController < ApplicationController
  # ensure user is signed in
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  # ensure correct user is signed in
  before_filter :correct_user, only: [:edit, :update]
  # ensure signed in user doesn't get to sign up page, or create action
  before_filter :signed_in_user_on_new_or_create, only: [:new, :create]
  # ensure users cannot send DELETE requests through command line
  before_filter :admin_user, only: [:destroy]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @user.send_email_confirm if @user
      sign_in @user
      # flash message
      flash[:success] = "Welcome! Please check your email for confirmation email"
      # handle a successful save
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    # before filter 'correct_user' defines @user
  end

  def update
    # before filter 'correct_user' defines @user
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    #def signed_in_user
    #  # friendly forwarding, store request.url under store_location method
    #  unless signed_in?
    #    store_location
    #    # synonymous to flash[:notice] 
    #    redirect_to signin_url, notice: "Please sign in."
    #  end
    #end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end

    def signed_in_user_on_new_or_create
      redirect_to current_user if signed_in?
    end

    def admin_user
      @user = User.find(params[:id])
      redirect_to root_path if !current_user.admin? || current_user?(@user)
    end
end
