#
# Cookbook Name:: topbeat
# Recipe:: install
#
# Copyright 2015, Virender Khatri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['topbeat']['packages'].each do |p|
  package p
end

version_string = node['platform_family'] == 'rhel' ? node['topbeat']['version'] + '-1' : node['topbeat']['version']

case node['platform_family']
when 'debian'
  # apt repository configuration
  apt_repository 'beats' do
    uri node['topbeat']['apt']['uri']
    components node['topbeat']['apt']['components']
    key node['topbeat']['apt']['key']
    action node['topbeat']['apt']['action']
    distribution ''
  end

  apt_preference 'topbeat' do
    pin          "version #{node['topbeat']['version']}"
    pin_priority '700'
  end

when 'rhel'
  # yum repository configuration
  yum_repository 'beats' do
    description node['topbeat']['yum']['description']
    baseurl node['topbeat']['yum']['baseurl']
    gpgcheck node['topbeat']['yum']['gpgcheck']
    gpgkey node['topbeat']['yum']['gpgkey']
    enabled node['topbeat']['yum']['enabled']
    action node['topbeat']['yum']['action']
  end

  package 'yum-versionlock'
  execute 'yum versionlock clear topbeat'
  execute "yum versionlock topbeat-#{version_string}"
end

package 'topbeat' do
  version version_string
  options node['platform_family'] == 'rhel' ? '' : '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
end
