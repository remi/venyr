# Venyr

Broadcast your current [Rdio](http://rdio.com) playback via WebSockets and let others listen to it.

Relevant files are:

* [application.rb](https://github.com/remiprev/venyr/blob/master/config/application.rb)
* [application.coffee](https://github.com/remiprev/venyr/blob/master/app/assets/javascripts/application.coffee)

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

## Todo

* There’s no login process for the moment. Gotta get invited to the JS API beta program first. I’m currently using [rdio-display](http://rdio-display.herokuapp.com) client ID :smile:
* When starting a broadcast, make sure we test on the server that the `accessToken` matches the provided username.
