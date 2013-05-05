# Venyr

Broadcast your current [Rdio](http://rdio.com) playback via WebSockets and let others listen to it.

## Installation

```shell
$ git clone git@github.com:remiprev/venyr.git && cd venyr
```

## Usage

Install the dependencies:

```bash
$ brew install redis # or `sudo apt-get install redis-server` or whatever
$ bundle install
```

Configure and start the app:

```bash
$ export RDIO_CLIENT_ID=…
$ export CANONICAL_HOST=venyr.local
$ bundle exec thin start --port 5200
13:48:04 web.1  | >> Using rack adapter
13:48:04 web.1  | >> Thin web server (v1.5.1 codename Straight Razor)
13:48:04 web.1  | >> Maximum connections set to 1024
13:48:04 web.1  | >> Listening on 0.0.0.0:5200, CTRL+C to stop
```

Open the app in a browser:

```bash
$ open http://venyr.local:5200
```

## Todo

* Bring back listeners count
