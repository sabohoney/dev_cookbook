#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "redis" do
	action :install
end

service "redis" do
	# start|stop|status|restart|condrestart|try-restart
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end
