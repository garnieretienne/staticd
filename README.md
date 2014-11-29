# Staticd toolbelt

The Staticd toolbelt is an ensemble of utilities (`staticd` and `staticdctl`)
aimed to provide an easy way to deploy and serve static content from a PaaS
provider like Heroku.

The `staticd` utility is a ruby app providing a REST API service to manage sites
and a simple HTTP service to serve these sites. A site, in the context of
Staticd, is an ensemble of resources accessible over HTTP using a domain name.
These services can be started independently and scaled using the usual
capabilities of the PaaS or hosting provider used to host the app.

The `staticdctl` utility is a command line interface to the Staticd API service.
It provide heroku like functionnalities to manage, configure and deploy sites
ready to be served by the Staticd HTTP service.

## Prerequisites

In order to run the REST API and HTTP service, you will need:
* A database used to store your sites data
* A datastore used to store your sites resources

Currently supported databases interfaces are: SQLite, MySQL and PostgreSQL.

Currently supported datastores interfaces are: Local and S3.

## The journey of a site ressource

The journey of a site ressource, deployed and distributed by the Staticd
toolbelt:

* The site ressources are packaged and sent to a Staticd API endpoint.
* A release of the site is created and each resources is stored into the
  datastore with metadata stored into database.
* When a request hit a Staticd HTTP service endpoint, the last release
  corresponding to the request's domain name is retrieved.
* The ressource asked by the request and provided by the corresponding release
  is downloaded and proxied to the client. The ressources is also cached to
  increase the speed of futher access.

# Deployment

## Deploying on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

# Getting Started

## Installing the Staticd CLI client

_The staticdctl gem is not yet distributed on rubygems. Until then, It must be
build locally._

**You must have a working ruby stack to install and use the staticdctl gem.**

```
$> git clone https://github.com/garnieretienne/staticd.git
$> cd staticd
$> gem build staticdctl.gemspec
$> gem install staticdctl-*.gem
```

## Creating a site

TODO

## Deploying a site

TODO

## Adding custom domain names

TODO
