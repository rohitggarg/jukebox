class DownloadSong
  @queue = Jukebox::Application.config.master_server_config['download_queue']
  FORMAT = Jukebox::Application.config.master_server_config['song_format']
  def self.perform(song_id)
    song_request = get_song_detail song_id
    %x{mkdir -p songs && youtube-dl --audio-format #{FORMAT} -o songs/#{song_request.file_id}.%\\(ext\\)s -x #{song_request.song_url}} unless File.exist? "songs/#{song_request.file_id}.#{FORMAT}"
    if File.exist? "songs/#{song_request.file_id}.#{FORMAT}"
      song_request.status = 'Downloaded'
      if ENV['autopilot'] == 'true'
        song_request.enqueue!
      end
    else
      song_request.status = 'Error'
    end
    song_request.save!
  end

  def self.get_song_detail song_id
    SongRequest.find(song_id)
  end
end