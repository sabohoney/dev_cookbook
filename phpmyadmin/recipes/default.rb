#
# Cookbook Name:: mycookbook
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
%w{
	php54
	php54-mysql
	php54-pdo
	php54-mbstring
	php54-mcrypt	
}.each do |pkgname|
	package "#{pkgname}" do
		action :install
	end
end

cookbook_file "/tmp/phpMyAdmin-3.5.8-all-languages.tar.gz" do
    mode 00644
#    checksum "dabb704a9307cb2a2b8abaf1c2d0d19e"
end

bash "create" do
	not_if { File.exists?('/var/www/phpMyAdmin/')}
	code <<-EOC
	   tar -xzf /tmp/phpMyAdmin-3.5.8-all-languages.tar.gz -C /var/www
	   mv /var/www/phpMyAdmin-3.5.8-all-languages /var/www/phpMyAdmin
	   rm -f /tmp/phpMyAdmin-3.5.8-all-languages.tar.gz
	EOC
end

template "/var/www/phpMyAdmin/config.inc.php" do
    owner "root"
    group "root"
    mode 0644
end

template "/etc/httpd/conf.d/phpmyadmin.conf" do
    owner "root"
    group "root"
    mode 0644
end

service "httpd" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :reload ]
end

