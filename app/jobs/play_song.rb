class PlaySong
  extend SongRequestHttp

  @queue = Jukebox::Application.config.master_server_config['servername']
  RANDOM_ACCENTS = ['Veena', 'Vicki', 'Alex', 'Ting-Ting']
  FORMAT = Jukebox::Application.config.master_server_config['song_format']

  def self.perform(song_id)
    song = get_song_detail song_id
		%x{#{say_command} 'This dedication has been made by #{song.requestor} towards #{song.dedicated_to}. #{song.message}'}
    actually_play_song song
  end

  def self.actually_play_song song
    song.status = SongRequestHttp::STATUS[:playing]
    update song
    %x{#{player_command} songs/#{song.file_id}.#{FORMAT}}
    song.status = SongRequestHttp::STATUS[:played]
    update song
  end

  def self.player_command
    is_darwin = (/darwin/ =~ RUBY_PLATFORM) != nil
    is_darwin ? "afplay" : "mplayer"
  end

  def self.say_command
    is_darwin = (/darwin/ =~ RUBY_PLATFORM) != nil
    is_darwin ? "say -v #{RANDOM_ACCENTS[rand(0..3)]}" : "espeak"
  end
end
