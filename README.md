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

# Deployment

## Prerequisites

In order to run the REST API and HTTP service, you will need:
* A domain name (or sub-domain) supporting wildcard DNS record.
* A database used to store your sites data.  
  Currently supported databases interfaces are: SQLite, MySQL and PostgreSQL.
* A datastore used to store your sites resources.  
  Currently supported datastores interfaces are: Local and S3.

## Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Once deployed, visit the `http://yourapp.herokuapp.com/api/welcome` page to finish the setup.

# The journey of a site ressource

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

