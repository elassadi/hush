# frozen_string_literal: true

module Chatbot
  class << self
    delegate :stories, :fields, :field_types, :nlu, to: :config
    def config
      load_config
    end

    def find_action(story_name, id)
      Chatbot.find_story(story_name).actions[id]
    end

    def find_message(key)
      object = Chatbot.config.messages.detect do |message|
        message.table.keys.first.to_s == key.to_s
      end
      object[key] if object
    end

    def find_action_by_name(story_name, action_name)
      return unless action_name

      actions = Chatbot.find_story(story_name).actions
      actions.detect do |a|
        a.action == action_name.to_s.downcase
      end
    end

    def find_story(name)
      Chatbot.stories.detect do |story|
        story.name == name.to_s.downcase
      end
    end

    def story_exists?(name)
      find_story(name).present?
    end

    def load_config(config_hash = nil)
      json_data = if config_hash
                    config_hash.to_json
                  else
                    YAML.load(stories_data).to_json
                  end

      raw_data = JSON.parse(json_data, object_class: OpenStruct)
      index_actions(raw_data)
    end

    def index_actions(raw_data)
      raw_data.stories.each do |story|
        story.actions.each_with_index do |action, a_id|
          action.id ||= a_id
        end
      end
      raw_data
    end

    def stories_data
      return dev_stories_data if Rails.env.development?

      Rails.cache.fetch(ChatbotConfig::STORIES_CACHE_KEY, expires_in: 20.minutes) do
        stories = ChatbotConfig.stories
        next stories if stories

        story_file = Rails.root.join("config/stories.yaml")
        File.read(story_file)
      end
    end

    def dev_stories_data
      story_file = Rails.root.join("config/stories.yaml")
      File.read(story_file)
    end
  end
end
