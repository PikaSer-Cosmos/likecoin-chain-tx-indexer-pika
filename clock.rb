# frozen_string_literal: true

require 'clockwork'
require 'active_support/time' # Allow numeric durations (eg: 1.minutes)

require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  configure do |config|
    config[:tz] = 'UTC'
    config[:thread] = true
  end

  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  every(5.minutes, 'nft_classes:sync_all_from_remote') do
    NftClasses::SyncAllRemoteClassesWithClassCreatedAt::Job.perform_later
  end

  every(1.hour, 'iscn:get_iscn_for_all_nft_classes', skip_first_run: true) do
    Iscn::GetRemoteIscn::GetIscnForAllNftClasses::Job.perform_later
  end

  every(1.week, 'nfts:get_nfts_for_all_nft_classes', at: "Monday 00:00") do
    Nfts::GetRemoteNfts::GetNftsForAllNftClasses::Job.perform_later
  end
  every(12.hours, 'nfts:get_nfts_for_all_nft_classes_created_in_1_day', skip_first_run: true) do
    Nfts::GetRemoteNfts::GetNftsForAllNftClasses::Job.perform_later(created_after: 1.day.ago)
    # In case some classes are missing NFT data (still limit by 1 week to be safe)
    Nfts::GetRemoteNfts::GetNftsForAllNftClasses::Job.perform_later(only_classes_without_nft_data: true, created_after: 1.week.ago)
  end

  every(5.minutes, 'nfts:get_owner_for_nfts_created_in_10_mins') do
    Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
      class_created_after: 10.minutes.ago,
    )
    Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
      class_created_after: 1.hour.ago,
      only_nfts_without_owner: true,
    )
  end
  every(1.hour, 'nfts:refresh_owner_for_nfts_created_in_1_day_to_1_hour') do
    # Keep those created -1h ~ -24h to be updated hourly
    Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
      class_created_before: 1.hour.ago,
      class_created_after:  1.day.ago,
      updated_before: 1.hour.ago,
    )
  end
  every(1.day, 'nfts:refresh_owner_for_nfts_created_in_1_week_to_1_day', at: "00:00") do
    # Keep those created -1d ~ -7d to be updated daily
    Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
      class_created_before: 1.day.ago,
      class_created_after:  1.week.ago,
      updated_before: 1.day.ago,
    )
  end
  every(1.week, 'nfts:get_owner_for_nfts_created_in_1_month', at: "Monday 00:00") do
    # Keep those created -7d ~ -1 month to be updated weekly
    Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
      class_created_before: 1.week.ago,
      class_created_after:  1.month.ago,
      updated_before: 1.week.ago,
    )
  end
  every(1.day, 'nfts:get_owner_for_created_in_1_year', at: "00:00", if: lambda { |t| t.day == 1 }) do
    # Keep those created -1 month ~ -1 year to be updated weekly
    Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
      class_created_before: 1.month.ago,
      class_created_after:  1.year.ago,
      updated_before: 1.month.ago,
    )
  end
  # Older than 1 year? To be handled later maybe
end
