class GamesController < ApplicationController

  def index
  end

  def start_game
    new_game = Game.create(user_id: current_user.id, points: 15)
    $points = 15
    redirect_to "/level/1"
  end

  def level
    client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_KEY'])
    @current_level = params[:id].to_i

    # Load API query once when game starts at level 1
    if @current_level == 1
      $available_tracks = []
      all_tracks = client.get('/tracks', :limit => 100, :order => 'created_at')
      all_tracks.each do |track|
        if track.genre && track.genre != '' && track.uri != ''
          $available_tracks << track
        end
      end
    end

    # Setting current track's info
    @current_track = $available_tracks[@current_level]
    @current_track_genre = @current_track.genre.capitalize

    # Grab three different genre types as answer choices
    @genre_list = Genre.all.shuffle!.first(3) ###################### Need to find current genre and avoid duplicate

    # Set up embed frame
    embed_info = client.get('/oembed', :url => @current_track.uri)
    @widget = embed_info['html']

    unless embed_info
      @next_level = @current_level + 1
      redirect_to "/level/#{@next_level}"
    end
  end

  def add_points
    $points += 15  # points are entered into db when game is finished
    # sleep(3)
    @current_level = params[:id].to_i
    @stop_at_level = 20
    if @current_level == @stop_at_level
      redirect_to score_path
    else
      @next_level = @current_level + 1
      redirect_to "/level/#{@next_level}"
    end
  end

  def progress
    # sleep(3)
    @current_level = params[:id].to_i
    @stop_at_level = 20
    if @current_level == @stop_at_level
      redirect_to score_path
    else
      @next_level = @current_level + 1
      redirect_to "/level/#{@next_level}"
    end
  end

  def score
    @end_game = Game.find_all_by_user_id(current_user.id).last
    @end_game.update_attributes(points: $points)
  end

  def scoreboard
    @games = Game.all
  end
end
