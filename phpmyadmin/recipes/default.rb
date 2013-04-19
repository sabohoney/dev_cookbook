#
# Cookbook Name:: mycookbook
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
service "httpd" do
	supports :reload => true
end

git "/var/www/" do
    repository "https://github.com/phpmyadmin/phpmyadmin.git"
    reference "MAINT_3_5_8"
    action :checkout
end

template "phpmyadmin.conf" do
    path "/etc/httpd/conf.d/"
    owner "root"
    group "root"
    mode 0644
    notifies :reload 'service[httpd]'
end