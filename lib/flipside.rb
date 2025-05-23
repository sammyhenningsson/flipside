# frozen_string_literal: true

require "active_record"
require "flipside/version"
require "flipside/web"
require "flipside/config/settings"
require "flipside/config/entities"
require "flipside/config/roles"
require "models/flipside/feature"

module Flipside
  extend Config::Settings
  extend Config::Entities
  extend Config::Roles

  class Error < StandardError; end

  class NoSuchFeauture < Error
    def initialize(name)
      super("There's no feature named '#{name}'")
    end
  end

  class << self
    def enabled?(name, *objects)
      feature = find_by(name:)
      return false unless feature

      objects = [default_object] if objects.empty?
      objects.any? { |object| feature.enabled? object }
    end

    def disabled?(...)
      !enabled?(...)
    end

    def enable!(name)
      feature = find_by!(name:)
      feature.update(enabled: true)
    end

    def add_entity(entity:, feature: nil, name: nil)
      feature ||= find_by!(name:)
      Entity.find_or_create_by(feature:, flippable: entity)
    end

    def remove_entity(entity_id:, feature: nil, name: nil)
      feature ||= find_by!(name:)
      feature.entities.find_by(id: entity_id)&.destroy
    end

    def add_role(class_name:, method_name:, feature: nil, name: nil)
      feature ||= find_by!(name:)
      Role.find_or_create_by(feature:, class_name:, method: method_name)
    end

    def remove_role(role_id:, feature: nil, name: nil)
      feature ||= find_by!(name:)
      feature.roles.find_by(id: role_id)&.destroy
    end

    def find_by(name:, create_on_missing: create_missing_features)
      feature = Feature.find_by(name:)
      feature ||= create_missing(name) if create_on_missing
      feature
    end

    def find_by!(name:)
      find_by(name:) || raise(NoSuchFeauture.new(name))
    end

    def create(name:, description: nil)
      Feature.create(name: name, description: description)
    end

    def create_missing(name)
      trace = caller.find { |trace| !trace.start_with? __FILE__ }
      source, line, _ = trace.split(":")
      source = [source, line].join(":") if line.match?(/\d+/)
      create(name:, description: "Created from #{source}")
    end
  end
end
