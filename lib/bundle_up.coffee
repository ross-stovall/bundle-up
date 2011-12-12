AssetsManager = require './assets_manager'
Js = require './js'
Css = require './css'
OnTheFlyCompiler = require './otf_compiler'

class BundleUp
  constructor: (app, assetPath, options = {bundle:false}) ->
    @app = app
    @js = new Js(options)
    @css = new Css(options)

    require(assetPath)(new AssetsManager(@css, @js))

    if options.bundle
      filename = @js.toBundle('global.js')
      @js.files = []
      @js.addFile("#{options.staticRoot}/generated/bundle/#{filename}")

      filename = @css.toBundle('global.css')
      @css.files = []
      @css.addFile("#{options.staticRoot}/generated/bundle/#{filename}")
    else
      # Compile files on-the-fly when not bundled
      @app.use (new OnTheFlyCompiler(@js, @css)).middleware

    @app.use @middleware
    
  middleware: (req, res, next) =>
    res.local('renderStyles', @css.render())
    res.local('renderJs', @js.render())
    next()

module.exports = (app, assetPath, options)->
  new BundleUp(app, assetPath, options)
