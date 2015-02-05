require 'serverspec'

set :backend, :exec

RSpec.configure do |c|
  c.before :all do
    #c.path = '/sbin:/usr/sbin'
  end
end

describe user('tomcat') do
  it { should exist }
end
