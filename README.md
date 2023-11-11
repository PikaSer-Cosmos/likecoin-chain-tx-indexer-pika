# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

## Ruby version
Mostly recent enough ruby version which is `>= 3.2.2`  
(see `Gemfile` & look for code like `ruby ">= 3.2.2"` if this is outdated)  


## How to run locally

### Preparation
- Checkout repo
- Install a ruby version which satisfies the version constraint above
  (many choices, [RVM](https://rvm.io, [asdf](https://asdf-vm.com) with [ruby plugin](https://github.com/asdf-vm/asdf-ruby)...)
- `gem update --system` (Update Rubygems)
- `bundle install` (Install required gems)

### Start app (several tabs)
- `bundle exec puma`
- `bundle exec good_job`

### Start app (one tab)
- Install [Overmind](https://github.com/DarthSim/overmind)
- `overmind s`

### Configuration
- Copy `.env.example` to `.env`
- Edit `.env` to suit you (some values would be used for deployment, and shared with app on production)


## How to run remotely (deploy)

### Preparation

#### Local
- Install [Kamal](https://kamal-deploy.org) (probably just `gem install kamal`)
- Prepare container registry like [Docker Hub](https://www.docker.com/products/docker-hub/), [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) or host your own
- Copy `deploy.example.yml` to `deploy.yml`
- Update `deploy.yml` to suit yourself (For host IP you need your remote host setup first)
- Review `.env` again (which might affects deploy settings and/or app on production)

#### Remote
- Get a logical host you can SSH into (no one care if it's physical or VM)
- Install [Docker](https://docs.docker.com/engine/install/) & `curl`
- Run `kamal env push` (push your secrets to remote host)
- Run `kamal accessory boot all` (start all non "app" stuff like database)
- Run `kamal deploy` (start all non "app" stuff like database)


## Data Initialization
DB is empty initially (except when jobs enqueued on production for those in `clock.rb`)  
So the following sections are for different types of data in which the code is to be run in "rails console"  

Start "rails console" locally: `rails c`  
Start "rails console" remotely: `kamal app exec -i 'bin/rails c'`  

### NFT Class Data
Probably not needed in remote (run every 5 min)

```ruby
NftClasses::SyncAllRemoteClassesWithClassCreatedAt::Job.perform_now

```

### NFT ISCN Data
This requires BG worker (`good_job`) to be run, since the actual data fetching are all BG jobs

```ruby
Iscn::GetRemoteIscn::GetIscnForAllNftClasses::Job.perform_now

```

### NFT Data (for "filter by NFT collector")
This requires BG worker (`good_job`) to be run, since the actual data fetching are all BG jobs  
This does NOT fetch owner data (blame `Cosmos SDK` for not returning owner with NFT data)  
You can only fetch NFT data for some NFT classes only, see `clock.rb` for example code  

```ruby
Nfts::GetRemoteNfts::GetNftsForAllNftClasses::Job.perform_now

```

### NFT Owner Data (for "filter by NFT collector")
This requires BG worker (`good_job`) to be run, since the actual data fetching are all BG jobs  
Also this must be run after some NFT data is fetched (it enqueues job based on stored NFT data)  
You can only fetch NFT owner data for some NFT entries only, see `clock.rb` for example code  

```ruby
Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts::Job.perform_later(
  only_nfts_without_owner: true,
)

```

