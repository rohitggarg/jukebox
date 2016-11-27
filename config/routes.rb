Rails.application.routes.draw do

  resources :song_requests, :only => [:index, :create, :new, :show, :update] do
    member do
      put 'retry'
      put 'enqueue'
    end
  end

  get 'search_youtube_videos', controller: 'search_query', action: 'search_youtube_videos'
end
