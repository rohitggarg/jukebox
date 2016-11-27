class DownloadSong
  extend SongRequestHttp
  @queue = Jukebox::Application.config.master_server_config['download_queue']
  FORMAT = Jukebox::Application.config.master_server_config['song_format']
  def self.perform(song_id)
    song_request = get_song_detail song_id
    begin
      populate_description song_request
      %x{mkdir -p songs && youtube-dl --audio-format #{FORMAT} -o songs/#{song_request.file_id}.%\\(ext\\)s -x #{song_request.song_url}} unless File.exist? "songs/#{song_request.file_id}.#{FORMAT}"
      if File.exist? "songs/#{song_request.file_id}.#{FORMAT}"
        song_request.status = SongRequest::STATUS[:downloaded]
        if ENV['autopilot'] == 'true'
          enqueue_song song_id
        end
      else
        song_request.status = SongRequest::STATUS[:error]
      end
      update song_request
    rescue Exception => e
      song_request.status = SongRequest::STATUS[:error]
      update song_request
      raise e
    end
  end

  def self.populate_description song_request
    description_text = %x{youtube-dl --get-title --get-description #{song_request.song_url}}
    if description_text.length > 255
      song_request.description = description_text[0..240] + "..."
    else
      song_request.description = description_text
    end
  end
end