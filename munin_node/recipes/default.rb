#
# Cookbook Name:: munin_node
# Recipe:: default
#
# Copyright 2012, Hiroaki Nakamura
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

version = node[:munin][:version]

group 'munin' do
  gid node[:munin][:gid]
end

user 'munin' do
  uid node[:munin][:uid]
  gid 'munin'
  shell '/sbin/nologin'
  comment 'Munin networked resource monitoring tool'
end

%w{ make gcc }.each do |pkg|
  package pkg
end

bash 'munin_install_perl_modules' do
  code <<-EOH
    cpanm Net::Server Net::Server::Fork Time::HiRes Net::SNMP \
      Crypt::DES Digest::SHA1 Digest::HMAC Net::SSLeay
  EOH
end

remote_file "/usr/local/src/munin-#{version}.tar.gz" do
  source "http://downloads.sourceforge.net/project/munin/stable/#{version}/munin-#{version}.tar.gz"
  case version
  when "2.0.2"
    checksum "e8a5266a85cde8b89a97fb7463a56a7ac9c038035b952e36047b7d599bb9181b"
  end
end

bash 'install_munin_node' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf munin-#{version}.tar.gz &&
    cd munin-#{version} &&
    make &&
    make install-common-prime install-node-prime install-plugins-prime &&
    chmod 777 /opt/munin/log/munin
  EOH
  not_if { FileTest.exists?("/opt/munin/sbin/munin-node") }
end

#cookbook_file "/etc/cron.d/munin" do
#  source "munin.cron"
#  owner 'root'
#  group 'root'
#  mode 0644
#  not_if { FileTest.exists?("/etc/cron.d/munin") }
#end
#
#service 'crond' do
#  action [:enable, :start]
#end