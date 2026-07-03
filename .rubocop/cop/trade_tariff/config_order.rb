module RuboCop
  module Cop
    module TradeTariff
      # Enforces the grouping used by TradeTariffFrontend::Config:
      # boolean config methods, value config methods, boolean flags, then value flags.
      class ConfigOrder < Base
        extend RuboCop::Cop::AutoCorrector

        CONFIG_FILE = 'lib/trade_tariff_frontend/config.rb'.freeze
        BOOLEAN_FLAG_METHODS = %i[flagsmith_flag].freeze
        VALUE_FLAG_METHODS = %i[flagsmith_value flagsmith_config].freeze

        def on_module(node)
          return unless config_module?(node)

          entries = config_entries(node)
          return if entries.empty? || ordered?(entries)

          add_offense(node.identifier.loc.expression, message: 'Config methods and flags must be grouped and sorted.') do |corrector|
            corrector.replace(
              replacement_range(entries),
              ordered_source(entries),
            )
          end
        end

        private

        def config_module?(node)
          processed_source.file_path.end_with?(CONFIG_FILE) &&
            node.identifier.const_name == 'Config' &&
            node.each_ancestor(:module).any? { |ancestor| ancestor.identifier.const_name == 'TradeTariffFrontend' }
        end

        def config_entries(node)
          body_nodes(node).filter_map do |child|
            ConfigEntry.build(child)
          end
        end

        def body_nodes(node)
          body = node.body
          return [] unless body
          return body.children if body.begin_type?

          [body]
        end

        def ordered?(entries)
          entries.map(&:key) == entries.sort_by(&:key).map(&:key)
        end

        def replacement_range(entries)
          first_entry = entries.min_by { |entry| entry.source_range.begin_pos }
          last_entry = entries.max_by { |entry| entry.source_range.end_pos }

          first_entry.source_range.join(last_entry.source_range)
        end

        def ordered_source(entries)
          sorted_entries = entries.sort_by(&:key)

          sorted_entries.each_with_index.map { |entry, index|
            next entry.source if index.zero?

            "#{separator_for(sorted_entries[index - 1], entry)}#{entry.source}"
          }.join
        end

        def separator_for(previous_entry, entry)
          previous_entry.flag? && entry.flag? && previous_entry.group == entry.group ? "\n" : "\n\n"
        end

        class ConfigEntry
          attr_reader :node, :group, :name

          def self.build(node)
            case node.type
            when :def
              new(node, node.method_name.end_with?('?') ? 0 : 1, node.method_name.to_s)
            when :send
              flag_entry(node)
            end
          end

          def self.flag_entry(node)
            return unless BOOLEAN_FLAG_METHODS.include?(node.method_name) || VALUE_FLAG_METHODS.include?(node.method_name)

            name = node.first_argument&.value.to_s
            group = BOOLEAN_FLAG_METHODS.include?(node.method_name) ? 2 : 3

            new(node, group, name)
          end

          def initialize(node, group, name)
            @node = node
            @group = group
            @name = name
          end

          def key
            [group, name]
          end

          def flag?
            group >= 2
          end

          # Keep this explicit so the cop does not depend on Active Support.
          # rubocop:disable Rails/Delegate
          def source
            source_range.source
          end
          # rubocop:enable Rails/Delegate

          def source_range
            Parser::Source::Range.new(
              node.source_range.source_buffer,
              node.source_range.begin_pos - node.loc.column,
              node.source_range.end_pos,
            )
          end
        end
      end
    end
  end
end
