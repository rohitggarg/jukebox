class SongRequest < ActiveRecord::Base
  STATUS = {
    new: 'N',
    enqueued: 'A',
    error: 'E',
    will_be_played: 'W',
    downloaded: 'D',
    playing: 'P',
    played: 'F'
  }
  validates_presence_of :dedicated_to, :song_url, :message, :requestor
  validates_format_of :song_url, :with => /(http|https):\/\/www[.]youtube[.]com\/watch[?]v=.*/ix

  before_create :set_fields
  after_create :download_file
  default_scope { order ('id DESC') }
  
  def set_fields
    self.file_id = self.song_url.gsub(/http(s)?:\/\/www[.]youtube[.]com\//,"").gsub("/","_").gsub("watch?v=","").split("&").first
    self.status = STATUS[:new]
  end

  def download_file
    self.status = STATUS[:enqueued]
    self.save!
    Resque.enqueue(DownloadSong, self.id)
  end

  def enqueue!
    self.status = STATUS[:will_be_played]
    self.save!
    Jukebox::Application.config.master_server_config['players'].each do | player_name |
      Resque.enqueue_to(player_name, PlaySong, self.id)
    end if Jukebox::Application.config.master_server_config['players'].present?
  end

  def status_display
    STATUS.key(self.status).to_s.capitalize
  end
end
