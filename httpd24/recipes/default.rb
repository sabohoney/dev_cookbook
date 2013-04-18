#
# Cookbook Name:: httpd24
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{
	httpd24
	httpd24-devel
}.each do |pkgname|
	package "#{pkgname}" do
		action :install
	end
end

