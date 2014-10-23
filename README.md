# Staticd

## Development

### Start engines

`bundle exec rackup --include lib --port 4567`

### Live documentation

`rm --recursive --force .yardoc/ && bundle exec yard server --reload --plugin yard-sinatra`

## TODO

* sites list: list attached domains
* sites list: list number of versions
* proper staticd executable
* clean staticdctl executable
* site creation: create an unique domain name (need to know the wildcard dns)
* add users management and API authentication
* domain deletion
* site deletion (delete all releases, each release cache and exah attached domain)
* release deletion
