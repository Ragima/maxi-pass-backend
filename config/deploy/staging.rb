# frozen_string_literal: true

role :app, %w[jesse@52.88.89.38]
set :branch, 'staging'

server '52.88.89.38', user: 'jesse', roles: %w[app db web]
