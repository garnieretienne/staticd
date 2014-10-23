# Staticd

## Development

### Start engines

`bundle exec rackup --include lib --port 4567`

### Live documentation

`rm --recursive --force .yardoc/ && bundle exec yard server --reload --plugin yard-sinatra`

## TODO v1

* DONE sites list: list attached domains
* DONE sites list: list number of versions
* TODO proper staticd executable
* TODO clean staticdctl executable
* TODO site creation: create an unique domain name (need to know the wildcard dns)
* TODO add users management and API authentication
* TODO domain deletion
* TODO site deletion (delete all releases, each release cache and exah attached domain)
* TODO release deletion
