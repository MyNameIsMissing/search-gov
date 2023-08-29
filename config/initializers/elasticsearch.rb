# frozen_string_literal: true

config = {
    transport_options: { ssl: { verify: false } }
  }
  
  if File.exist?('config/elasticsearch_client.yml')
    config.merge!(YAML.load_file('config/elasticsearch_client.yml')[Rails.env].deep_symbolize_keys)
  end
  
  Elasticsearch::Model.client = Elasticsearch::Client.new(config)