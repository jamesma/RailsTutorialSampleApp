class EmailConfirmationsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase)
    user.send_email_confirm if user
    flash[:success] = "Email sent with confirmation instructions"
    redirect_to root_url
  end

  def edit
    @user = User.find_by_email_confirm_token!(params[:id])
    if @user.toggle!(:user_state)
      flash[:success] = "Email verification successful"
      sign_in(@user)
    else
      flash[:error] = "Email verification unsuccessful"
    end
    redirect_to root_url
  end
end
