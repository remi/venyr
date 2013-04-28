# Venyr

## Installation

```shell
$ git clone git@github.com:remiprev/venyr.git
```

## Usage

Create an environment file

```shell
$ cp .env.default .env
$ vim .env # And add a value for RDIO_CLIENT_ID and CANONICAL_HOST
```

Install the dependencies and start the app

```shell
$ bundle install
$ foreman start
13:48:04 web.1  | >> Using rack adapter
13:48:04 web.1  | >> Thin web server (v1.5.0 codename Knife)
13:48:04 web.1  | >> Maximum connections set to 1024
13:48:04 web.1  | >> Listening on 0.0.0.0:5200, CTRL+C to stop
```

Open the app in a browser

```shell
$ open http://0.0.0.0:5200
```
