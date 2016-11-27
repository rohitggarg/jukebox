class SongRequestsController < ApplicationController
  before_action :set_song_request, only: [:retry, :enqueue, :show, :update]
  before_action :check_secret, only: [:retry, :enqueue, :update]
  skip_before_action :verify_authenticity_token, only: [:update]

  def index
    @song_requests = SongRequest.all
  end

  def new
    @song_request = SongRequest.new
  end

  def show
  end

  def retry
    @song_request.download_file
    redirect_to action: :index
  end

  def create
    @song_request = SongRequest.new(song_request_params)

    respond_to do |format|
      if @song_request.save
        format.html { redirect_to action: :index }
        format.json { render :show, status: :created, location: @song_request }
      else
        format.html { render :new }
        format.json { render json: @song_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def enqueue
    @song_request.enqueue!
    render json: {status: @song_request.status, id: @song_request.id}
  end

  def update
    @song_request.update!(song_request_update_params)
    render json: {status: @song_request.status, description: @song_request.description, id: @song_request.id}
  end

  private
    def check_secret
      render json: {error: "wrong secret"}, status: 403 and return if params[:admin_secret] != Jukebox::Application.config.admin_secret
    end
    def set_song_request
      @song_request = SongRequest.find(params[:id])
    end

    def song_request_params
      params.require(:song_request).permit(:dedicated_to, :song_url, :message, :requestor)
    end

    def song_request_update_params
      params.require(:song_request).permit(:status, :description)
    end
end
