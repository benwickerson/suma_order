class UsersController < ApplicationController
  before_action :admin_user,      only: [:index, :edit, :update, :new, :create, :destroy]
  before_action :correct_user,    only: [:clear_order]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @orders = Order.all
  end

  def new
    @user = User.new
  end

  def create
      @user = User.new(user_params)
      if @user.save
        flash[:success] = "#{@user.name} created!"
        redirect_to new_user_path
      else
        render 'new'
      end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "#{@user.name} updated."
      redirect_to users_path
    else
      render 'edit'
    end
  end

  def index
    @users = User.all
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "They dun gone."
    redirect_to users_url
  end

  def clear_order
    @user = User.find(params[:user_id])
    User.clear_order(@user)
    redirect_to user_orderitems_path(user_id: @user)
    unless @user.orderitems.present?
      flash[:success] = "All items removed from your order."
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
    end

    # Before filters

    def correct_user
      @user = User.find(params[:id] || params[:user_id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
