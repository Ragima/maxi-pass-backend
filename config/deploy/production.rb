# frozen_string_literal: true

role :app, %w[ubuntu@35.163.99.37]
set :branch, 'master'
set :stage, :production

server '35.163.99.37', user: 'ubuntu', roles: %w[app db web]
