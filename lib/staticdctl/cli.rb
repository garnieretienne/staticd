require 'yaml'
require 'staticdctl'
require 'staticd_utils/gli_object'
require 'staticd_utils/archive'
require 'staticd_utils/sitemap'
require 'staticd_utils/file_size'
require 'digest/sha1'

module Staticdctl
  class CLI

    def initialize(options={})
      @gli = GLIObject.new
      @gli.program_desc 'Staticd CLI client'
      @gli.version Staticdctl::VERSION

      enable_debugging if options[:debugging]
      set_global_options
      build_commands
    end

    def run(*args)
      @gli.run *args
    end

    private

    def enable_debugging
      @gli.on_error{|exception| raise exception}
    end

    def load_global_config(config_file)
      begin
        YAML.load_file(config_file)
      rescue
        {}
      end
    end

    def load_config(config_file, host)
      config = load_global_config config_file
      (config && config.has_key?(host)) ? config[host] : {}
    end

    def staticd_client(options, &block)
      config = load_config(options[:config], options[:host])
      client = Staticdctl::StaticdClient.new(
        options[:host],
        access_id: config["access_id"],
        secret_key: config["secret_key"]
      )
      yield client
    end

    def set_global_options
      set_global_option_config
      set_global_option_host
      set_global_option_site
      set_global_option_debug
    end

    def set_global_option_config
      @gli.desc 'Staticd configuration file'
      @gli.default_value "#{ENV['HOME']}/.staticdctl.yml"
      @gli.arg_name 'Staticd configuration file'
      @gli.flag [:c, :config]
    end

    def set_global_option_host
      @gli.desc 'Staticd API endpoint'
      @gli.default_value "http://localhost:8080/api"
      @gli.arg_name 'Staticd API endpoint'
      @gli.flag [:h, :host]
    end

    def set_global_option_site
      @gli.desc 'Site name'
      @gli.default_value File.basename(Dir.pwd)
      @gli.arg_name 'Site name'
      @gli.flag [:s, :site]
    end

    def set_global_option_debug
      @gli.desc 'Enable debugging (raise exception on error)'
      @gli.default_value false
      @gli.arg_name 'debug'
      @gli.switch [:d, :debug]
    end

    def build_commands
      build_command_config
      build_command_set_config
      build_command_rm_config
      build_command_sites
      build_command_create_site
      build_command_destroy_site
      build_command_domains
      build_command_attach_domain
      build_command_detach_domain
      build_command_releases
      build_command_create_release
    end

    def build_command_config
      @gli.desc 'Display current configuration'
      @gli.command :config do |c|
        c.action do |global_options, options, args|
          config = load_config global_options[:config], global_options[:host]
          puts "Current configuration for #{global_options[:host]}:"
          config.each do |key, value|
            puts " * #{key}: #{value}"
          end
        end
      end
    end

    def build_command_set_config
      @gli.desc 'Set a configuration option'
      @gli.arg_name 'config_key'
      @gli.command :"config:set" do |c|
        c.action do |global_options, options, args|

          global_config = load_global_config global_options[:config]
          global_config[global_options[:host]] ||= {}
          global_config[global_options[:host]][args[0]] = args[1]
          File.open(global_options[:config], 'w+') do |file|
            file.write global_config.to_yaml
            puts "The #{args[0]} config key has been set to #{args[1]}"
          end
        end
      end
    end

    def build_command_rm_config
      @gli.desc 'Remove a configuration option'
      @gli.arg_name 'config_key'
      @gli.command :"config:rm" do |c|
        c.action do |global_options, options, args|

          global_config = load_global_config global_options[:config]
          if (
            global_config.has_key?(global_options[:host]) &&
            global_config[global_options[:host]].has_key?(args.first)
          )
            global_config[global_options[:host]].delete args.first
            File.open(global_options[:config], 'w+') do |file|
              file.write global_config.to_yaml
              puts "The #{args.first} config key has been removed"
            end
          else
            puts "The #{args.first} config key cannot be found"
          end
        end
      end
    end

    def build_command_sites
      @gli.desc 'List all sites'
      @gli.command :sites do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.sites do |sites|
              puts "Sites hosted on #{global_options[:host]}:"
              sites.each do |site|
                last_release = site.releases.last
                last_release_string = last_release ? last_release.tag : "-"
                domains = site.domain_names.map{|domain| domain.name}.join(", ")
                domains_string = domains.empty? ? "no domains" : domains
                puts " * #{site.name} (#{last_release_string}): " +
                  "#{domains_string}"
              end
            end
          end
        end
      end
    end

    def build_command_create_site
      @gli.desc 'Create a new site'
      @gli.command :"sites:create" do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.create_site(name: global_options[:site]) do |site|
              puts "The #{site.name} site has been created."
              if site.domain_names.any?
                puts "http://#{site.domain_names.first.name}"
              end
            end
          end
        end
      end
    end

    def build_command_destroy_site
      @gli.desc 'Destroy a site'
      @gli.command :"sites:destroy" do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.destroy_site(global_options[:site]) do
              puts "The #{global_options[:site]} site has been destroyed."
            end
          end
        end
      end
    end

    def build_command_domains
      @gli.desc 'List all domain attached to the current site'
      @gli.command :domains do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.domains(global_options[:site]) do |domains|
              puts "Domain names attached to #{global_options[:site]}:"
              domains.each do |domain|
                puts " * #{domain.name}"
              end
            end
          end
        end
      end
    end

    def build_command_attach_domain
      @gli.desc 'Attach a domain name to a site'
      @gli.arg_name 'domain_name'
      @gli.command :"domains:attach" do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.attach_domain(global_options[:site],
              name: args.first
            ) do |domain|
              puts "The #{domain.name} domain has been attached to the " +
                "#{domain.site_name} site"
            end
          end
        end
      end
    end

    def build_command_detach_domain
      @gli.desc 'Detach a domain name from a site'
      @gli.arg_name 'domain_name'
      @gli.command :"domains:detach" do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.detach_domain(global_options[:site], args.first) do |domain|
              puts "The #{args.first} domain has been detached from the " +
                "#{global_options[:site]} site"
            end
          end
        end
      end
    end

    def build_command_releases
      @gli.desc 'List all releases of the current site'
      @gli.command :releases do |c|
        c.action do |global_options,options,args|

          staticd_client global_options do |client|

            client.releases(global_options[:site]) do |releases|
              releases_string = releases.map{|release| release.tag}.join(", ")
              puts "Releases of #{global_options[:site]}: #{releases_string}"
            end
          end
        end
      end
    end

    def build_command_create_release
      @gli.desc 'Push a new release for the current app'
      @gli.arg_name '[path]'
      @gli.command :push do |c|
        c.action do |global_options,options,args|
          source_path = args.any? ? args.first : "."

          print "Counting resources... "
          sitemap = StaticdUtils::Sitemap.create(source_path)
          puts "done. (#{sitemap.routes.count} resources)"

          # print "Asking host to identify new resources"
          # diff_sitemap = staticd_client global_options do |client|
          #   client.cached_resources(sitemap.to_h) do |new_map|
          #     StaticdUtils::Sitemap.new new_map
          #   end
          # end
          # puts "done. (#{diff_sitemap.routes.count} new resources)"

          print "Building the archive... "
          archive = StaticdUtils::Archive.create source_path
          file_size = StaticdUtils::FileSize.new(archive.size)
          puts "done. (#{file_size})"

          # TODO: work on it
          require "staticd_utils/archive_file"
          sitemap_file = StaticdUtils::ArchiveFile.new StringIO.new(sitemap.to_yaml)

          staticd_client global_options do |client|

            print "Uploading the archive... "
            timer_start = Time.now
            client.create_release(
              global_options[:site],
              archive.to_archive_file,
              sitemap_file
            ) do |release|
              timer_stop = Time.now
              time_spent = timer_stop - timer_start
              speed = archive.size / time_spent / 1000
              puts "done. (#{'%.2f' % time_spent}s / #{'%.2f' % speed}kbps)"
              puts "The #{release.site_name} release (#{release.tag}) has " +
                  "been created"
            end
          end
        end
      end
    end
  end
end
