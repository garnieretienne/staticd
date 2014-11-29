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

Before deploying on heroku, be sure you have:
* A dedicated wildcard domain (or subdomain) name available
* An S3 URL (`s3://AWS_ACCESS_KEY_ID:AWS_SECRET_ACCESS_KEY@S3_BUCKET`)
  You can look a this script to generate s3 URL using the configured `aws`
  command.
  **Your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` must not contain any
  `/` character as the URI module will faild to parse them. Fixing this issue
  is in my TODO list.**

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Once deployed, you need to:

* Configure your wildcard domain to resolve on your heroku app url.
  (`CNAME to your_heroku_app.herokuapp.com.`)
* Add your wildcard domain into your heroku app domain.
  (`Heroku Panel > App > Settings > Domains`)

You will also need the `STATICD_ACCESS_ID` and `STATICD_SECRET_KEY`
environment variables values
(`Heroku Panel > App > Settings > Reveal Config Vars`).

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

## Configuring the Staticd CLI client

You need to configure the `access_id` and `secret_key` for the Staticd API
endpoint you intend to use.

```
$> staticdctl --host http://wildcard_domain.tld/api config:set access_id your_access_id
The access_id config key has been set to your_access_id
$> staticdctl --host http://wildcard_domain.tld/api config:set secret_key your_secret_key
The secret_key config key has been set to your_secret_key
```

You can test if the authentication is done correctly listing all the sites
hosted on this Staticd app:
`staticdctl --host http://wildcard_domain.tld/api sites`.

## Creating a site

```
# Inside your project folder:
$:website> staticdctl --host http://wildcard_domain.tld/api sites:create`
The website site has been created.
http://beslfu.wildcard_domain.tld
```

## Deploying a site

```
# Inside your project folder, assuming source files are in the 'built' folder:
$:website> staticdctl --host http://wildcard_domain.tld/api push build/
Counting resources... done. (6 resources)
Asking host to identify new resources... done. (6 new resources to upload)
Building the archive... done. (30KB)
Uploading the archive... done. (1.44s / 21.18kbps)
The yuweb release (v1) has been created.
```

## Adding custom domain names

```
$:website> staticdctl --host http://wildcard_domain.tld/api domains:attach www.domain.tld
The www.domain.tld domain has been attached to the website site
```

_Note: If you use heroku to host the app, do not forget to also add your custom
domain to the heroku app._
