#
# Cookbook Name:: mycookbook
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "postfix" do
    action :install
end

service "sendmail" do
	supports :stop => true
	action [ :disable, :stop ]
end

service "postfix" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end

bash "install passenger" do
	code <<-EOC
    	alternatives --set mta /usr/sbin/sendmail.postfix
	EOC
end
