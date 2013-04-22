#
# Cookbook Name:: mycookbook
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
cookbook_file "/tmp/phpMyAdmin-3.5.8-all-languages.tar.gz" do
    mode 00644
    checksum "dabb704a9307cb2a2b8abaf1c2d0d19e"
end

bash "create" do
	not_if { File.exists?('/var/www/phpMyAdmin/')}
	code <<-EOC
	   tar -xzf /tmp/phpMyAdmin-3.5.8-all-languages.tar.gz -C /var/www
	   rm -f /tmp/phpMyAdmin-3.5.8-all-languages.tar.gz
	EOC
end

template "config.inc.php" do
    path "/var/www/phpMyAdmin/"
    owner "root"
    group "root"
    mode 0644
end

template "phpmyadmin.conf" do
    path "/etc/httpd/conf.d/"
    owner "root"
    group "root"
    mode 0644
end

service "httpd" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :reload ]
end

