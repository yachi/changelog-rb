require 'yaml'
require 'changelog/helpers/git'

module Changelog
  module Helpers
    module Changes
      def version_header(folder)
        if folder == "unreleased"
          "## [#{version_text(folder)}]\n"
        else
          meta = YAML.load_file(File.join(destination_root, "changelog/#{folder}/tag.yml"))
          date = meta['date'].to_s
          "## [#{version_text(folder)}] - #{date}\n"
        end
      end

      def version_text(folder)
        if folder == 'unreleased'
          'Unreleased'
        else
          folder
        end
      end

      def version_sha(folder)
        if folder == 'unreleased'
          'HEAD'
        else
          Changelog::Helpers::Git.tag(folder) || folder
        end
      end

      def read_changes(folder)
        items = {}
        changelog_files(folder).each do |file|
          yaml = YAML.load_file(file)
          items[yaml['type']] ||= []
          items[yaml['type']] << "#{yaml['title'].strip} (@#{yaml['author']})"
        end

        sections = []
        Changelog.natures.each.with_index do |nature, i|
          if changes = items[nature].presence
            lines = []
            lines << "### #{nature}\n"
            changes.each do |change|
              lines << "- #{change}\n"
            end
            sections << lines.join
          end
        end

        sections.join("\n")
      end

      def changelog_files(folder)
        Dir[File.join(destination_root, "changelog/#{folder}/*.yml")] - [
          File.join(destination_root, "changelog/#{folder}/tag.yml")
        ]
      end
    end
  end
end
