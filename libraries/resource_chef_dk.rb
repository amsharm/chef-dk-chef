# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk
#
# Copyright 2014-2016, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource/lwrp_base'
require_relative 'chef_dk_helpers'
require_relative 'provider_chef_dk'
require_relative 'provider_chef_dk_debian'
require_relative 'provider_chef_dk_mac_os_x'
require_relative 'provider_chef_dk_rhel'
require_relative 'provider_chef_dk_windows'

class Chef
  class Resource
    # A Chef resource for the Chef-DK packages
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDk < LWRPBase
      self.resource_name = :chef_dk
      actions :install, :remove
      default_action :install

      #
      # The version of Chef-DK to install
      #
      # @param [String] arg
      # @return [String]
      #
      def version(arg = nil)
        set_or_return(:version,
                      arg,
                      kind_of: String,
                      default: 'latest',
                      callbacks: {
                        'Can\'t set both a `version` and a `package_url`' =>
                          ->(_) { package_url.nil? },
                        'Invalid version string' =>
                          ->(a) { ::ChefDk::Helpers.valid_version?(a) }
                      })
      end

      #
      # Optionally enable prerelease builds
      #
      # @param [TrueClass, FalseClass] arg
      # @return [TrueClass, FalseClass]
      #
      def prerelease(arg = nil)
        set_or_return(:prerelease,
                      arg,
                      kind_of: [TrueClass, FalseClass],
                      default: false)
      end

      #
      # Optionally enable nightly builds
      #
      # @param [TrueClass, FalseClass] arg
      # @return [TrueClass, FalseClass]
      #
      def nightlies(arg = nil)
        set_or_return(:nightlies,
                      arg,
                      kind_of: [TrueClass, FalseClass],
                      default: false)
      end

      #
      # Optionally override the calculated package URL
      #
      # @param [String] arg
      # @return [String]
      #
      def package_url(arg = nil)
        set_or_return(:package_url,
                      arg,
                      kind_of: [String, NilClass],
                      default: nil,
                      callbacks: {
                        'Can\'t set both a `package_url` and a `version`' =>
                          ->(_) { version == 'latest' }
                      })
      end

      #
      # Optionally set ChefDK's Ruby env as the default for all users
      #
      # @param [TrueClass, FalseClass, NilClass] arg
      # @return [TrueClass, FalseClass]
      #
      def global_shell_init(arg = nil)
        set_or_return(:global_shell_init,
                      arg,
                      kind_of: [TrueClass, FalseClass],
                      default: false)
      end
    end
  end
end
