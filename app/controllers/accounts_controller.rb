class AccountsController < ApplicationController
  before_filter :require_user
  layout 'users'
  def show
    @user = @current_user
    render 'users/show'
  end

  def edit
    @user = @current_user
    render 'users/edit'
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
