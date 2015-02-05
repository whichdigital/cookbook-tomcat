require 'spec_helper'

def test_version(v)
  v = '' if v == 7

  %w(webapps conf logs work bin lib work).each do |folder|
    %w(razuna pentaho).each do |app|
      describe file("/ca/web/#{app}/#{folder}") do
        it { should be_directory }
        it { should be_owned_by 'tomcat' }
      end
    end
  end

  if `rpm -q tomcat`.chomp =~ /tomcat-7.0.33-3|4.el6.noarch/
    describe file('/usr/sbin/tomcat') do
      it { should contain(/^:$/).from(/^if \[ -r \"\$TOMCAT_CFG\" \]; then/).to(/end/) }
      it { should contain(/^:$/).from(/^if \[ -z \"\${TOMCAT_CFG}\" \]; then/).to(/end/) }
    end
  end

  describe service("tomcat#{v}-razuna") do
    it { should be_enabled }
    it { should be_running }
  end

  describe service("tomcat#{v}-pentaho") do
    it { should be_enabled }
    it { should be_running }
  end

  %w{8081 8083}.each do |port|
    describe command("curl http://localhost:#{port}/sample/") do
      its(:stdout) { should match /Sample \"Hello, World\" Application/ }
    end
  end

end
