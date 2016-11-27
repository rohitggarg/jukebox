class DownloadSong
  URL = "http://#{Jukebox::Application.config.master_server_config['servername']}/song_requests/"

  @queue = Jukebox::Application.config.master_server_config['download_queue']
  FORMAT = Jukebox::Application.config.master_server_config['song_format']
  def self.perform(song_id)
    begin
      song_request = get_song_detail song_id
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

  def self.get_song_detail song_id
    url = "#{URL}#{song_id}.json"
    object = JSON.parse(Net::HTTP.get(URI.parse(url)))
    song_request = OpenStruct.new(object)

    description_text = %x{youtube-dl --get-title --get-description #{song_request.song_url}}
    if description_text.length > 255
      song_request.description = description_text[0..240] + "..."
    else
      song_request.description = description_text
    end
    song_request
  end

  def self.enqueue_song song_id
    url = "#{URL}#{song_id}/enqueue.json?admin_secret=#{Jukebox::Application.config.admin_secret}"
    object = JSON.parse(Net::HTTP.get(URI.parse(url)))
    raise 'Not enqueued!' unless object.status == SongRequest::STATUS[:will_be_played]
  end

  def self.update song_request
    uri = URI.parse("#{URL}#{song_request.id}")
    req = Net::HTTP::Put.new(uri)
    req.set_form_data({'song_request[description]' => song_request.description, 'song_request[status]' => song_request.status, admin_secret: Jukebox::Application.config.admin_secret})

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    object = JSON.parse(res.body)
    puts object
    raise 'Problem in update' unless object['status'] == song_request.status
  end
end