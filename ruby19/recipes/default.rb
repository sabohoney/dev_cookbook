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

bash "make symlik" do
    only_if { File.exists?('/usr/bin/gem1.9')}
    not_if { File.exists?('/usr/bin/gem')}
	code <<-EOC
		rm /usr/bin/ruby
		ln -s /usr/bin/ruby1.9 /usr/bin/ruby
		ln -s /usr/bin/gem1.9 /usr/bin/gem
	EOC
end
