class ActorsController < ApplicationController

  before do
    if !logged_in?
      redirect "/login"
    end
  end

  #show all actors
  get '/actors' do
    @title = "Actor List - JMDB"  
    @actors = Actor.all
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'actors/index'
  end

  #enter new actor
  get '/actors/new' do
    @title = "Add a new actor - JMDB"   
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'actors/new'
  end

  post '/actors' do
    @actor = Actor.new(name: params[:name], user_id: current_user.id)
    ##Handle movies
    if params[:movie][:title] != "" && params[:movie][:year] == "" 
      session[:error] = "Actor was not saved. Movie cannot be added - Year is missing"
      redirect '/actors/new'
    end
    if params[:movie][:title] == "" && params[:movie][:year] != "" 
      session[:error] = "Actor was not saved. Movie cannot be added - Title is missing"
      redirect '/actors/new'
    end
    if params[:movie][:title] != "" && params[:movie][:year] != ""
    m = Movie.new(title: params[:movie][:title],year: params[:movie][:year], user_id: current_user.id)
    @actor.movies << m
    end
    if params[:movies]
      params[:movies].each do |movie|
      c = Movie.find(movie)
      @actor.movies << c
      end
    end
    ##Handle tv shows
    if params[:show][:title] != "" && params[:show][:year] == "" 
      session[:error] = "Actor was not saved. Show cannot be added - Year is missing"
      redirect '/actors/new'
    end
    if params[:show][:title] == "" && params[:show][:year] != "" 
      session[:error] = "Actor was not saved. Show cannot be added - Title is missing"
      redirect '/actors/new'
    end
    if params[:show][:title] != "" && params[:show][:year] != ""
    x = Show.new(title: params[:show][:title],year: params[:show][:year], user_id: current_user.id)
    @actor.shows << x
    end
    if params[:shows]
      params[:shows].each do |show|
      y = Show.find(show)
      @actor.shows << y
      end
    end

    ##Handle genres
    if params[:genre] != ""
    d = Genre.new(name: params[:genre], user_id: current_user.id)
    @actor.genres << d
    end
    if params[:genres]
      params[:genres].each do |genre|
      f = Genre.find(genre)
      @actor.genres << f
      end
    end

    if @actor.save
    session[:notice] = "Actor successfully saved!"
    redirect '/actors/' + @actor.slug
    else
    session[:error] = "Actor not saved! Please fill * required fields."
    redirect '/actors/new'
    end

  end


  #show page for individual actor
  get '/actors/:slug' do
    @actor = Actor.find_by_slug(params[:slug])
    if @actor == nil
      session[:error] = "Actor does not exist"
      redirect "/actors"
      end
    @title = @actor.name.to_s + " - JMDB"
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'actors/show'
  end

  #edit page for individual actor
  get '/actors/:slug/edit' do
    @error = session[:error]
    session[:error] = nil
    @actor = Actor.find_by_slug(params[:slug])
    if @actor == nil
      session[:error] = "Actor does not exist"
      redirect "/actors"
      else
      @title = "Edit " + @actor.name.to_s + " - JMDB"  
      if current_user.actors.include?(@actor)
          erb :'actors/edit'
        else
        session[:error] = "You are not authorized to edit this actor."
        redirect '/actors/' + @actor.slug
      end
    end
  end

  patch '/actors/:slug' do
    @actor = Actor.find_by_slug(params[:slug])
    if params[:name] == "" 
      session[:error] = "Please enter name!"
      redirect '/actors/' + @actor.slug + '/edit'
    else
    @actor.name = params[:name]
    @actor.movies.delete_all
    if params[:movies]
      params[:movies].each do |movie|
      c = Movie.find(movie)
      @actor.movies << c
      end
    end
    @actor.shows.delete_all
    if params[:shows]
      params[:shows].each do |show|
      f = Show.find(show)
      @actor.shows << f
      end
    end
    @actor.genres.delete_all
    if params[:genres]
      params[:genres].each do |genre|
      f = Genre.find(genre)
      @actor.genres << f
      end
    end
    ##Handle new movie addition
    if params[:movie][:title] != "" && params[:movie][:year] == ""
      session[:error] = "Please enter year of movie!"
      redirect '/actors/' + @actor.slug + '/edit'
    elsif params[:movie][:title] == "" && params[:movie][:year] != ""
      session[:error] = "Please enter title of movie!"
      redirect '/actors/' + @actor.slug + '/edit'
    elsif params[:movie][:title] != "" && params[:movie][:year] != ""
      a = Movie.create(title: params[:movie][:title],year: params[:movie][:year], user_id: current_user.id)
      @actor.movies << a
    end
    ##Handle new show addition
    if params[:show][:title] != "" && params[:show][:year] == ""
      session[:error] = "Please enter year of show!"
      redirect '/actors/' + @actor.slug + '/edit'
    elsif params[:show][:title] == "" && params[:show][:year] != ""
      session[:error] = "Please enter title of show!"
      redirect '/actors/' + @actor.slug + '/edit'
    elsif params[:show][:title] != "" && params[:show][:year] != ""
      d = Show.create(title: params[:show][:title],year: params[:show][:year], user_id: current_user.id)
      @actor.shows << d
    end
    ##Handle new genre addition
    if params[:genre] != ""
      e = Genre.create(name: params[:genre], user_id: current_user.id)
      @actor.genres << e
    end
    if @actor.save
    session[:notice] = "Actor successfully edited!"
    redirect '/actors/' + @actor.slug
    else
    session[:error] = "Actor not edited! Please fill * required fields."
    redirect '/actors/' + @actor.slug + '/edit'
    end
    end
  end
  #delete actor
  delete '/actors/:slug/delete' do
    if current_user.actors.include?(Actor.find_by_slug(params[:slug]))
    Actor.find_by_slug(params[:slug]).destroy
    session[:notice] = "Actor deleted!"
    redirect '/actors'
    else
    session[:error] = "You are not authorized to delete that actor!"
    redirect '/actors'
    end
  end


end