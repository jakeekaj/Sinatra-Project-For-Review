class ShowsController < ApplicationController

  before do
    if !logged_in?
      redirect "/login"
    end
  end

  get '/shows' do

    @title = "Show List - JMDB"  
    @shows = Show.all
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'shows/index'
   
  end


  get '/shows/new' do

    @title = "Add a new show - JMDB"   
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'shows/new'
    
  end

  post '/shows' do
    @show = Show.new(title: params[:title],year: params[:year], user_id: current_user.id)
    ##Handle actors
    if params[:actor1] != ""
    a = Actor.new(name: params[:actor1], user_id: current_user.id)
    @show.actors << a
    end
    if params[:actor2] != ""
    b = Actor.new(name: params[:actor2], user_id: current_user.id)
    @show.actors << b
    end
    if params[:actors]
      params[:actors].each do |actor|
      c = Actor.find(actor)
      @show.actors << c
      end
    end
    ##Handle genres
    if params[:genre1] != ""
    d = Genre.new(name: params[:genre1], user_id: current_user.id)
    @show.genres << d
    end
    if params[:genre2] != ""
    e = Genre.new(name: params[:genre2], user_id: current_user.id)
    @show.genres << e
    end
    if params[:genres]
      params[:genres].each do |genre|
      f = Genre.find(genre)
      @show.genres << f
      end
    end

    if @show.save
    session[:notice] = "Show successfully saved!"
    redirect '/shows/' + @show.slug
    else
    session[:error] = "Show not saved! Please fill * required fields."
    redirect '/shows/new'
    end

  end



  get '/shows/:slug' do

    @show = Show.find_by_slug(params[:slug])
    if @show == nil
      session[:error] = "Show does not exist"
      redirect "/shows"
      end
    @title = @show.title.to_s + " " + @show.year.to_s + " - JMDB"
    @notice = session[:notice]
    session[:notice] = nil
    @error = session[:error]
    session[:error] = nil
    erb :'shows/show'
    
  end

  get '/shows/:slug/edit' do

    @error = session[:error]
    session[:error] = nil
    @show = Show.find_by_slug(params[:slug])
    if @show == nil
      session[:error] = "Show does not exist"
      redirect "/shows"
      else
      @title = "Edit " + @show.title.to_s + " " + @show.year.to_s + " - JMDB"  
      if current_user.shows.include?(@show)
          erb :'shows/edit'
        else
        session[:error] = "You are not authorized to edit this show."
        redirect '/shows/' + @show.slug
      end
      
    end
  end

  patch '/shows/:slug' do
    @show = Show.find_by_slug(params[:slug])
    if params[:title] == "" || params[:year] == ""
      session[:error] = "Please enter both Title and Year!"
      redirect '/shows/' + @show.slug + '/edit'
    else
    @show.title = params[:title]
    @show.year = params[:year]
    @show.actors.delete_all
    if params[:actors]
      params[:actors].each do |actor|
      c = Actor.find(actor)
      @show.actors << c
      end
    end
    @show.genres.delete_all
    if params[:genres]
      params[:genres].each do |genre|
      f = Genre.find(genre)
      @show.genres << f
      end
    end
    if params[:actor1] != ""
      a = Actor.create(name: params[:actor1], user_id: current_user.id)
      @show.actors << a
    end
    if params[:actor2] != ""
      b = Actor.create(name: params[:actor2], user_id: current_user.id)
      @show.actors << b
    end
    if params[:genre1] != ""
      d = Genre.create(name: params[:genre1], user_id: current_user.id)
      @show.genres << d
    end
    if params[:genre2] != ""
      e = Genre.create(name: params[:genre2], user_id: current_user.id)
      @show.genres << e
    end
    if @show.save
    session[:notice] = "Show successfully edited!"
    redirect '/shows/' + @show.slug
    else
    session[:error] = "Show not edited! Please fill * required fields."
    redirect '/shows/' + @show.slug + '/edit'
    end
    end
  end

  delete '/shows/:slug/delete' do
    if current_user.shows.include?(Show.find_by_slug(params[:slug]))
    Show.find_by_slug(params[:slug]).destroy
    session[:notice] = "Show deleted!"
    redirect '/shows'
    else
    session[:error] = "You are not authorized to delete that show!"
    redirect '/shows'
    end
  end


end