class App < Sinatra::Base
  # Middleware
  use Rack::CanonicalHost, ENV['CANONICAL_HOST']

  # Plugins
  register Sinatra::Partial

  # Configuration
  configure do
    set :haml, :format => :html5, :attr_wrapper => '"', :ugly => false
    set :root, proc { File.expand_path('./') }
    set :views, proc { File.join(root, 'app/views') }
    set :public_folder, proc { File.join(root, 'public') }
    enable :static
    enable :partial_underscores
  end

  # Helpers
  helpers Sprockets::Helpers
  helpers Sinatra::ContentFor

  # Errors
  error(404) { haml :"404" }

  # Routes
  get("/") { haml :index }
  get("/listen/:username") { haml :listen }
  get("/broadcast") { haml :broadcast }
end
