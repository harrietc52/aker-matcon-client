require 'matcon_client/version'
require 'active_model'
require 'active_support/all'
require 'faraday'

module MatconClient
  autoload :Connection,              'matcon_client/connection'
  autoload :Query,                   'matcon_client/query'
  autoload :Requestor,               'matcon_client/requestor'
  autoload :Errors,                  'matcon_client/errors'
  autoload :Middleware,              'matcon_client/middleware'
  autoload :ResponseHandlerFactory,  'matcon_client/response_handler_factory'
  autoload :ResultSet,               'matcon_client/result_set'
  autoload :Model,                   'matcon_client/models/model'
  autoload :Slot,					           'matcon_client/models/slot'
  autoload :Container,               'matcon_client/models/container'
  autoload :Material,                'matcon_client/models/material'
end