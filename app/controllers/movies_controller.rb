class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    #
    # Determine what ratings are available
    #
    @all_ratings = Movie.Ratings


    # Get the selected Keys
    if params[:ratings] == nil
      if flash[:selections]
        @selected_ratings = flash[:selections]
      else
        @selected_ratings = Movie.Ratings
      end 
    else
      @selected_ratings = params[:ratings].keys
    end

    #
    # create this rating list automatically
    #  
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

    if (sort_method != nil)
      @movies = Movie.order(sort_method).find(:all,:conditions=>{:rating => @selected_ratings })
    else
#@movies = Movie.all
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

    flash[:selections] = @selected_ratings
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
