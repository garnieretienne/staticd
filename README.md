# Staticd

## Development

### Start engines

`bundle exec rackup --include lib --port 4567`

### Live documentation

`rm --recursive --force .yardoc/ && bundle exec yard server --reload --plugin yard-sinatra`
