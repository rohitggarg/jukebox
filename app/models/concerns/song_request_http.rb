module SongRequestHttp
  URL = "http://#{Jukebox::Application.config.master_server_config['servername']}/song_requests/"

  def update song_request
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

  def get_song_detail song_id
    url = "#{URL}#{song_id}.json"
    object = JSON.parse(Net::HTTP.get(URI.parse(url)))
    OpenStruct.new(object)
  end

  def enqueue_song song_id
    url = "#{URL}#{song_id}/enqueue.json?admin_secret=#{Jukebox::Application.config.admin_secret}"
    object = JSON.parse(Net::HTTP.get(URI.parse(url)))
    raise 'Not enqueued!' unless object['status'] == SongRequest::STATUS[:will_be_played]
  end
end