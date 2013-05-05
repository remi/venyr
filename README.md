# Venyr [![](http://i.imgur.com/tzHWhED.png)](http://venyr.com)

Broadcast your current [Rdio](http://rdio.com) playback via WebSockets and let others listen to it.

## Installation

```bash
$ git clone git@github.com:remiprev/venyr.git && cd venyr
```

## Usage

Install the dependencies:

```bash
# Install redis (the command might depend on your platform)
$ brew install redis && redis-server /usr/local/etc/redis.conf

# Install gems
$ bundle install
```

Configure and start the app:

```bash
# Your Rdio application Client ID (you need access to the new beta Rdio API)
$ export RDIO_CLIENT_ID=… 

# The host that resolves to 127.0.0.1
$ export CANONICAL_HOST=venyr.local

# Start thin on a specific port
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
