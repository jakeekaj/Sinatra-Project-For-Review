class UsersController < ApplicationController
  
  #display all users
  get '/users' do
    if !logged_in?
      redirect "/login"
    else
    @title = "User List - JMDB"  
    @users = User.all
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'users/index'
   end
  end

  #display all user contributions
  get '/users/:slug' do
    if !logged_in?
      redirect "/login"
    else
    @user = User.find_by_slug(params[:slug])
    if @user == nil
      session[:error] = "User does not exist"
      redirect "/users"
      end
    @title = @user.username.to_s + " - JMDB"
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'users/show'
    end
  end

  


end