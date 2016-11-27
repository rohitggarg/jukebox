class DownloadSong
  @queue = Jukebox::Application.config.master_server_config['download_queue']
  FORMAT = Jukebox::Application.config.master_server_config['song_format']
  def self.perform(song_id)
    song_request = get_song_detail song_id
    %x{mkdir -p songs && youtube-dl --audio-format #{FORMAT} -o songs/#{song_request.file_id}.%\\(ext\\)s -x #{song_request.song_url}} unless File.exist? "songs/#{song_request.file_id}.#{FORMAT}"
    if File.exist? "songs/#{song_request.file_id}.#{FORMAT}"
      song_request.status = SongRequest::STATUS[:downloaded]
      if ENV['autopilot'] == 'true'
        song_request.enqueue!
      end
    else
      song_request.status = SongRequest::STATUS[:error]
    end
    song_request.save!
  end

  def self.get_song_detail song_id
    song_request = SongRequest.find(song_id)
    description_text = %x{youtube-dl --get-title --get-description #{song_request.song_url}}
    if description_text.length > 255
      song_request.description = description_text[0..240] + "..."
    else
      song_request.description = description_text
    end
    song_request
  end
end