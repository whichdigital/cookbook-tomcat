include_recipe 'tomcat'

%w(razuna pentaho).each do |webapp|

  remote_file "/ca/web/#{webapp}/webapps/sample.war" do
    source 'https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war'
    owner 'tomcat'
    group 'tomcat'
    action :create_if_missing
    notifies :restart, "service[tomcat#{node['tomcat']['suffix']}-#{webapp}]"
  end

  service "tomcat#{node['tomcat']['suffix']}-#{webapp}" do
    action :start
    supports ({ :restart => true, :reload => true, :status => true })
  end

end
