[![Gem Version](https://badge.fury.io/rb/staticd.svg)](http://badge.fury.io/rb/staticd)
[![Build Status](https://travis-ci.org/garnieretienne/staticd.svg?branch=master)](https://travis-ci.org/garnieretienne/staticd)
-----

![Staticd Logo](http://staticd.eggnet.io/images/staticd_logo.png)

* Official website: [staticd.eggnet.io](http://staticd.eggnet.io/)
* Backup website: [garnieretienne.github.io/staticd](https://garnieretienne.github.io/staticd/)


# Staticd toolbelt

The Staticd toolbelt is an ensemble of utilities (`staticd` and `staticdctl`)
designed to provide an easy way to deploy and serve static content over HTTP.

The `staticd` utility is a ruby app providing a REST API service to manage sites
and a simple HTTP service to serve these sites. A site, in the context of
Staticd, is an ensemble of resources accessible over HTTP using a domain name.
These services can be started independently and scaled using the usual
capabilities of the PaaS or the Hosting provider used to host the app.

The `staticdctl` utility is a ruby command line interface to the Staticd API
service. It provide heroku-like functionalities to manage, configure and deploy
sites ready to be served by the Staticd HTTP service.

## The journey of a site ressource

The journey of a site ressource, deployed and distributed by the Staticd
toolbelt:

* The site ressources are packaged and sent to a Staticd API endpoint.
* A release of the site is created and each resource is stored into a
  datastore with its metadata stored into a database.
* When a request hit a Staticd HTTP endpoint, the last release
  corresponding to the request's host address is retrieved.
* The ressource asked by the request is retrieved, downloaded and proxied to
  the client. The ressources is also cached to increase the speed of futher
  access.

# Getting Started

## Staticd Deployment

### Prerequisites

In order to run the Staticd API and HTTP services, you will need:
* A domain name supporting wildcard DNS records.
* A _database_ to store your sites data
  (currently, the only supported database is PostgreSQL).
* A _datastore_ to store your sites resources
  (currently, the supported datastores are S3 buckets or the host file system).

### Once deployed

Once deployed, visit the `/api/v1/welcome` page to complete the setup and get
instructions to configure the `staticdctl` utility.

### Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Other deployment guides:

* [Manual deployment on Heroku PaaS](https://github.com/garnieretienne/staticd/wiki/Manual-deployment-on-Heroku-PaaS)

## Staticd Usage

### Create a site

Inside your project folder:

```
$:/website> staticdctl sites:create`
The website site has been created.
http://jtbghu.wildcard_domain.tld
```

### Deploying changes to a site

Inside your project folder, assuming resources to upload are in the `built`
folder:

```
$:/website> staticdctl push build/
Counting resources... done (2 resources).
Asking host to identify new resources... done (2 new resources to upload).
Building the archive... done (3KB).
Uploading the archive... done (2.08s / 1.48kbps).

The website release (v1) has been created.
http://jtbghu.wildcard_domain.tld
```

# Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) if you wish to contribute to the
project.

* Pull requests are welcome.
* Documentation is available on the
  [Github Wiki](https://github.com/garnieretienne/staticd/wiki).
* Issues are managed in
  [Github](https://github.com/garnieretienne/staticd/issues).

# License

The MIT License (MIT)

Copyright (c) 2014 Etienne Garnier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
