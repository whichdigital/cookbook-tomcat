require 'tomcat'

test_version 7

describe file('/ca/web/razuna/conf/server.xml') do
  it { should contain /custom_template/ }
end
