class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    #
    # Pull data together from session and parms
    #
    need_to_redirect = false
    redirect_hash = Hash.new
    if params[:ratings] == nil and session[:ratings] != nil
      need_to_redirect = true
      redirect_hash[:ratings] = session[:ratings]
    elsif params[:ratings] != nil
      if params[:ratings].keys.count < 1
        params[:ratings] = session[:ratings]
      end
      redirect_hash[:ratings] = params[:ratings]
    end

    if params[:sort] == nil and session[:sort] != nil
      need_to_redirect = true
      redirect_hash[:sort] = session[:sort]
    elsif  params[:sort] != nil
      redirect_hash[:sort] = params[:sort]
    end

    if need_to_redirect
      flash.keep
      redirect_hash.merge!(:action=>'index')
      redirect_to redirect_hash
    end

    #
    # All data should now be in place
    #

    # Get the selected Keys
    if params[:ratings] == nil
      @selected_ratings = Movie.Ratings
    else
      @selected_ratings = params[:ratings].keys
    end

    # Determine what ratings are available
    @all_ratings = Movie.Ratings

    # create this rating list automatically
    @rating_value = Hash.new
    @all_ratings.each do |rating|
      if @selected_ratings.include? rating
        @rating_value.merge!(rating => true)
      else
        @rating_value.merge!(rating => false)
      end
    end

    #
    # Sort thr movies for display if required
    #
    sort_method=params[:sort]

    # make sure sorted is always at least empty by the time we get here
    if (sort_method != nil and sort_method != '' )
      @movies = Movie.order(sort_method).find(:all,:conditions=>{:rating => @selected_ratings })
    else
      @movies = Movie.find(:all,:conditions=>{:rating => @selected_ratings })
    end

    #
    # set highlighting indicating what was sorted by
    #
    if (sort_method == 'title')
      @title_hilite = 'hilite'
    elsif (sort_method == 'release_date')
      @release_hilite = 'hilite'
    end

    #
    # store data into the session
    #
    session[:ratings] = params[:ratings] if params[:ratings] != nil
    session[:sort] = params[:sort] if params[:sort] != nil
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
