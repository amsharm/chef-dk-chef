# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider_chef_dk_mac_os_x
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

require 'chef/provider/lwrp_base'
require_relative 'provider_chef_dk'

class Chef
  class Provider
    class ChefDk < LWRPBase
      # A Chef provider for the Chef-DK Mac OS X packages.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class MacOsX < ChefDk
        provides :chef_dk, platform_family: 'mac_os_x'

        private

        #
        # Use a dmg_package resource to download and install Chef-DK.
        #
        # (see Chef::Provider::ChefDk#install!)
        #
        def install!
          src = package_source
          chk = package_checksum
          dmg_package 'Chef Development Kit' do
            app ::File.basename(src, '.dmg')
            volumes_dir 'Chef Development Kit'
            source "#{'file://' if src.start_with?('/')}#{src}"
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum chk
          end
        end

        #
        # Clean up the package directories and forget the Chef-DK entry in
        # pkgutil.
        #
        # (see Chef::Provider::ChefDk#remove!)
        #
        def remove!
          ['/opt/chefdk', ::File.expand_path('~/.chefdk')].each do |d|
            directory d do
              recursive true
              action :delete
            end
          end
          execute 'pkgutil --forget com.getchef.pkg.chefdk' do
            only_if 'pkgutil --pkg-info com.getchef.pkg.chefdk'
          end
        end
      end
    end
  end
end
