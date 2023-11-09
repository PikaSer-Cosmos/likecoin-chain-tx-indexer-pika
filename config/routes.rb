# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  mount PgHero::Engine, at: "pghero"

  mount GoodJob::Engine => "good_job"

  namespace :apps__main_api__nft_classes__index, path: "/apps/main_api/nft_classes" do
    get(
      "",
      controller: "/apps/main_api/nft_classes/index/action",
      action: :call,
      as: "",
    )
  end
end
