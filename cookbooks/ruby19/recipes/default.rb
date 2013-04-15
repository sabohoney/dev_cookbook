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

