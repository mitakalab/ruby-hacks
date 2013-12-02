require 'grooveshark'
require 'io/console'
require 'dotenv'
Dotenv.load

class GroovesharkDownloader
  def initialize
    @client = Grooveshark::Client.new
  end
  
  def message
    puts "[1] Search"
    puts "[2] Favorites"
    puts "[3] Playlists"
    puts ""
    print "Select number : "
    number = gets.to_i

    case number
    when 1
      self.search_songs
    when 2
      self.get_favorites
    when 3
      self.get_playlists
    else
      puts "Oops! Wrong number"
    end
  end

  def login
    if ENV['USERNAME'] && ENV['PASSWORD']
      @user = @client.login(ENV['USERNAME'], ENV['PASSWORD'])
    else
      print "username : "
      username = gets.chomp
      print "password : "	
      password = STDIN.noecho(&:gets).chomp
      @user = @client.login(username, password)
    end
  end	

  def get_songs(songs)
    songs.each do |song|
      url = @client.get_song_url(song)
      if Dir["**/*#{song.id}.mp3"].empty?
        puts "OK! Now #{song} download"
        File.open('info.txt', 'a') do |file|
          file.puts "#{song}"
        end
        system("curl -L -o #{song.id}.mp3 #{url}") 
      else
        puts "Oops! #{song} already downloaded"
      end
    end
    self.message
  end

  def get_favorites
    if @user.nil?
      self.login
    end
    songs = @user.favorites
    self.get_songs(songs)
  end

  def search_songs
    print "keyword : "
    query = gets.to_s.encode('UTF-8')
    songs = @client.search_songs(query)
    songs[0, 50].each_with_index do |song, index|
      puts "[#{index}] #{song.name} - #{song.artist}"
    end
    puts ""
    puts "Select the number (e.g. 3, 4, 6, 8)"
    print "number : "
    select = gets.chomp.split(",").map { |number| number.to_i }

    songs = songs.map.with_index{|song, index| song if select.include?(index) }.compact
    self.get_songs(songs)
  end

  def get_playlists
    if @user.nil?
      self.login
    end
    playlists = @user.playlists
    playlists.each_with_index do |playlist, index|
      puts "[#{index}] #{playlist.name}"
    end
    puts ""
    puts "Select the number (e.g. 2)"
    print "number : "
    select = gets.chomp.to_i
    playlist = @user.get_playlist(playlists[select].id)
    playlist.load_songs
    songs = playlist.songs
    self.get_songs(songs)
  end

end

puts "Welcome to Grooveshark Downloader !"
grooveshark = GroovesharkDownloader.new
grooveshark.message












