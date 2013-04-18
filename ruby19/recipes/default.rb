#
# Cookbook Name:: ruby19
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{
	ruby19
	ruby19-devel
}.each do |pkgname|
	package "#{pkgname}" do
		action :install
	end
end

bash "link ruby" do
	only_if { File.exists?('/usr/bin/ruby1.9')}
	only_if { File.exists?('/usr/bin/ruby')}
	code <<-EOC
		rm /usr/bin/ruby
		ln -s /usr/bin/ruby1.9 /usr/bin/ruby
	EOC

end
