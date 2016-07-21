class MoviesController < ApplicationController

  before do
    if !logged_in?
      redirect "/login"
    end
  end


  get '/movies' do

    @title = "Movie List - JMDB"  
    @movies = Movie.all
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'movies/index'
   
  end


  get '/movies/new' do

    @title = "Add a new movie - JMDB"   
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'movies/new'
    
  end

  post '/movies' do
    @movie = Movie.new(title: params[:title],year: params[:year], user_id: current_user.id)
    ##Handle actors
    if params[:actor1] != ""
    a = Actor.new(name: params[:actor1], user_id: current_user.id)
    @movie.actors << a
    end
    if params[:actor2] != ""
    b = Actor.new(name: params[:actor2], user_id: current_user.id)
    @movie.actors << b
    end
    if params[:actors]
      params[:actors].each do |actor|
      c = Actor.find(actor)
      @movie.actors << c
      end
    end
    ##Handle genres
    if params[:genre1] != ""
    d = Genre.new(name: params[:genre1], user_id: current_user.id)
    @movie.genres << d
    end
    if params[:genre2] != ""
    e = Genre.new(name: params[:genre2], user_id: current_user.id)
    @movie.genres << e
    end
    if params[:genres]
      params[:genres].each do |genre|
      f = Genre.find(genre)
      @movie.genres << f
      end
    end

    if @movie.save
    session[:notice] = "Movie successfully saved!"
    redirect '/movies/' + @movie.slug
    else
    session[:error] = "Movie not saved! Please fill * required fields."
    redirect '/movies/new'
    end

  end



  get '/movies/:slug' do

    @movie = Movie.find_by_slug(params[:slug])
    if @movie == nil
      session[:error] = "Movie does not exist"
      redirect "/movies"
      end
    @title = @movie.title.to_s + " " + @movie.year.to_s + " - JMDB"
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'movies/show'
    
  end

  get '/movies/:slug/edit' do

    @error = session[:error]
    session[:error] = nil
    @movie = Movie.find_by_slug(params[:slug])
    if @movie == nil
      session[:error] = "Movie does not exist"
      redirect "/movies"
      else
      @title = "Edit " + @movie.title.to_s + " " + @movie.year.to_s + " - JMDB"  
      if current_user.movies.include?(@movie)
          erb :'movies/edit'
        else
        session[:error] = "You are not authorized to edit this movie."
        redirect '/movies/' + @movie.slug
      end
      
    end
  end

  patch '/movies/:slug' do
    @movie = Movie.find_by_slug(params[:slug])
    if params[:title] == "" || params[:year] == ""
      session[:error] = "Please enter both Title and Year!"
      redirect '/movies/' + @movie.slug + '/edit'
    else
    @movie.title = params[:title]
    @movie.year = params[:year]
    @movie.actors.delete_all
    if params[:actors]
      params[:actors].each do |actor|
      c = Actor.find(actor)
      @movie.actors << c
      end
    end
    @movie.genres.delete_all
    if params[:genres]
      params[:genres].each do |genre|
      f = Genre.find(genre)
      @movie.genres << f
      end
    end
    if params[:actor1] != ""
      a = Actor.create(name: params[:actor1], user_id: current_user.id)
      @movie.actors << a
    end
    if params[:actor2] != ""
      b = Actor.create(name: params[:actor2], user_id: current_user.id)
      @movie.actors << b
    end
    if params[:genre1] != ""
      d = Genre.create(name: params[:genre1], user_id: current_user.id)
      @movie.genres << d
    end
    if params[:genre2] != ""
      e = Genre.create(name: params[:genre2], user_id: current_user.id)
      @movie.genres << e
    end
    if @movie.save
    session[:notice] = "Movie successfully edited!"
    redirect '/movies/' + @movie.slug
    else
    session[:error] = "Movie not edited! Please fill * required fields."
    redirect '/movies/' + @movie.slug + '/edit'
    end
    end
  end

  delete '/movies/:slug/delete' do
    if current_user.movies.include?(Movie.find_by_slug(params[:slug]))
    Movie.find_by_slug(params[:slug]).destroy
    session[:notice] = "Movie deleted!"
    redirect '/movies'
    else
    session[:error] = "You are not authorized to delete that movie!"
    redirect '/movies'
    end
  end


end