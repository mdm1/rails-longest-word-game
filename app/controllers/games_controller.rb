class GamesController < ApplicationController

  def new
    @letters = 10.times.map { ('a'..'z').to_a.sample }
  end

  def score
    @attempt = params[:attempt]
    @letters = params[:letters].split()
    @start_time = params[:start_time].to_time
    @end_time = Time.now
    session[:score] = 0 if session[:score].nil?
    session[:count] = 1 if session[:count].nil?

    base_url = "https://wagon-dictionary.herokuapp.com"
    endpoint = "/#{@attempt}"
    url = base_url + endpoint
    dictionary = open(url).read
    word_hash = JSON.parse(dictionary).transform_keys(&:to_sym)

    time_taken = (@end_time - @start_time).round(2)
    @final_hash = {}
    condition1 = @attempt.chars.all? { |letter| @attempt.chars.count(letter) <= @letters.count(letter)}
    condition2 = word_hash[:found]

    if condition1 && condition2
      @final_hash[:score] = ((word_hash[:length] * 100) / time_taken).round(2)
      @final_hash[:message] = "Well Done"
      @final_hash[:time] = time_taken
    elsif condition1 == true && condition2 == false
      @final_hash[:score] = 0
      @final_hash[:message] = "not an english word"
      @final_hash[:time] = time_taken
    else
      @final_hash[:score] = 0
      @final_hash[:message] = "not in the grid"
      @final_hash[:time] = time_taken
    end

    session[:score] = session[:score] + @final_hash[:score]
    session[:count] = session[:count] + 1
    @session_score = session[:score]
    @session_average = @session_score / session[:count]
  end
end
