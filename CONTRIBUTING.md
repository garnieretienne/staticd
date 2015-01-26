# Contributing

The project use this [Ruby Style Guide][ruby-style-guide].

[ruby-style-guide]: https://github.com/bbatsov/ruby-style-guide#the-ruby-style-guide "Ruby Style Guide"

## Vagrant

A [Vagrant file](Vagrantfile) is available and will install and configure the
following components: a ruby stack, the sqlite tool, the staticdctl
configuration and all staticd dependencies.

To correctly run the development VM, you will need:

* At least 2 CPUs and 1024MB of RAM available
* Virtualbox and Vagrant installed on your development host
* `nfsd` running (see [here](https://github.com/mitchellh/vagrant/issues/4987)
  for people on Ubuntu with home partition encrypted)

To start the creation of the Vagrant development environment, just run
`vagrant up` inside the project root folder (it takes ~15 min on my `Intel
Core i5 M560 @2.67GHz` laptop).

To start the Staticd API and HTTP services: `bundle exec foreman start` inside
the `/vagrant` folder.
Configuration for the `staticd` utility is provided by environment variables in
a `.env` [file](.env).

To list available Rake tasks: `bundle exec foreman run rake -T` inside the
`/vagrant` folder.
Configuration for the `rake` command is provided by environment variables in
a `.env` [file](.env).

To use the `staticdctl` utility: `bundle exec staticdctl --help` inside the
`/vagrant` folder.
Configuration for the `staticdctl` command is provided by the
`~/.staticdctl.yml` config file and the `STATICDCTL_ENDPOINT` environment
variable, both built at the VM creation.

## Releases

The `staticd` and `staticdctl` gems use
[Sementic Versionning](http://semver.org/).

> Bug fixes not affecting the API increment the patch version, backwards
> compatible API additions/changes increment the minor version, and backwards
> incompatible API changes increment the major version.

## Process

1. Update release version in source code.
   Edit [`lib/staticd/version.rb`](lib/staticd/version.rb),
   [`lib/staticdctl/version.rb`](lib/staticdctl/version.rb), and if needed
   [`lib/staticd/api.rb` (`VERSION=vX`)].
2. Build and publish the gems.
   Run `gem build staticd.gemspec` and `gem build staticdctl.gemspec` to build
   the gem files and `gem push staticd-*.gem` and `gem push staticdctl-*.gem`
   to publish them.
3. Create a release on Github
   Prefix the version name with the letter v (ex: `v1.0.0`), set the release
   title and description and create the release.
