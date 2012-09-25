class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:destroy]

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted!"
    redirect_to root_url
  end

  private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end

    # current_user.microposts.find() raises an exception when the micropost
    # doesn't exist instead of returning nil
    # we can write correct_user method like this:
    # def correct_user
    #   @micropost = current_user.microposts.find(params[:id])
    # rescue
    #   redirect_to root_url
    # end
end