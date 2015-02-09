#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2010-2015, Opscode, Inc.
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

# required for the secure_password method from the openssl cookbook
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'java'

if node['tomcat']['base_version'].to_i == 7
  if platform_family?('rhel') and node[:platform_version].to_i < 7
    include_recipe 'yum-epel'
  end
end

node['tomcat']['packages'].each do |pkg|
  package pkg do
    action :install
    notifies :create, 'ruby_block[fix startup script:: https://bugzilla.redhat.com/show_bug.cgi?id=1104704]', :immediately
  end

  ruby_block 'fix startup script:: https://bugzilla.redhat.com/show_bug.cgi?id=1104704' do
    block do
      fe = Chef::Util::FileEdit.new("/usr/sbin/tomcat")
      fe.search_file_replace_line(/TOMCAT_CFG=\"\/etc\/tomcat\/tomcat.conf\"/,":")
      fe.search_file_replace_line(/\.\s+\$TOMCAT_CFG/,":")
      fe.write_file
    end
    action :nothing
    only_if { platform_family?('rhel') && node[:platform_version].to_i < 7 }
    only_if { `rpm -q tomcat`.chomp =~ /tomcat-7.0.33-3|4.el6.noarch/ }
  end

end

node['tomcat']['deploy_manager_packages'].each do |pkg|
  package pkg do
    action :install
  end
   # Even for the base instance, the OS package may not make this directory
  directory node['tomcat']['endorsed_dir'] do
    mode '0755'
    recursive true
  end
end

unless node['tomcat']['deploy_manager_apps']
  directory "#{node['tomcat']['webapp_dir']}/manager" do
    action :delete
    recursive true
  end
  file "#{node['tomcat']['config_dir']}/Catalina/localhost/manager.xml" do
    action :delete
  end
  directory "#{node['tomcat']['webapp_dir']}/host-manager" do
    action :delete
    recursive true
  end
  file "#{node['tomcat']['config_dir']}/Catalina/localhost/host-manager.xml" do
    action :delete
  end
end

node.set_unless['tomcat']['keystore_password'] = secure_password
node.set_unless['tomcat']['truststore_password'] = secure_password

if node['tomcat']['run_base_instance']
  tomcat_instance "base" do
    ajp_port node['tomcat']['ajp_port']
    port node['tomcat']['port']
    proxy_port node['tomcat']['proxy_port']
    shutdown_port node['tomcat']['shutdown_port']
    ssl_port node['tomcat']['ssl_port']
    ssl_proxy_port node['tomcat']['ssl_proxy_port']
    webapp_dir node['tomcat']['webapp_dir']
  end
end

node['tomcat']['instances'].each do |name, attrs|
  tomcat_instance "#{name}" do
    ajp_port attrs['ajp_port']
    authbind attrs['authbind']
    base attrs['base']
    catalina_options attrs['catalina_options']
    certificate_dn attrs['certificate_dn']
    config_dir attrs['config_dir']
    context_dir attrs['context_dir']
    endorsed_dir attrs['endorsed_dir']
    group attrs['group']
    home attrs['home']
    java_options attrs['java_options']
    keystore_file attrs['keystore_file']
    keystore_type attrs['keystore_type']
    lib_dir attrs['lib_dir']
    log_dir attrs['log_dir']
    loglevel attrs['loglevel']
    max_threads attrs['max_threads']
    port attrs['port']
    proxy_port attrs['proxy_port']
    server_xml_cookbook attrs['server_xml_cookbook']
    server_xml_template attrs['server_xml_template']
    server_xml_variables attrs['server_xml_variables']
    shutdown_port attrs['shutdown_port']
    ssl_cert_file attrs['ssl_cert_file']
    ssl_chain_files attrs['ssl_chain_files']
    ssl_key_file attrs['ssl_key_file']
    ssl_max_threads attrs['ssl_max_threads']
    ssl_port attrs['ssl_port']
    ssl_proxy_port attrs['ssl_proxy_port']
    start_service attrs['start_service']
    tmp_dir attrs['tmp_dir']
    tomcat_auth attrs['tomcat_auth']
    truststore_file attrs['truststore_file']
    truststore_type attrs['truststore_type']
    use_security_manager attrs['use_security_manager']
    user attrs['user']
    webapp_dir attrs['webapp_dir']
    work_dir attrs['work_dir']
  end
end
