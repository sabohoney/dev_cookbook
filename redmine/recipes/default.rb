#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

%w{
	make
	gcc
	gcc-c++
	openssl-devel
	zlib-devel
	curl-devel
	mysql55
	mysql55-server
	mysql55-devel
	
}.each do |pkgname|
	package "#{pkgname}" do
		action :install
	end
end

git "/var/lib/redmine/" do
	repository "git://github.com/redmine/redmine.git"
	reference "refs/tags/2.0.1"
	action :checkout
end

if "#{node['redmine']['datasource']['host']}" == 'localhost' then
    bash "create" do
    	not_if { File.exists?('/var/lib/mysql/redmine/')}
    	code <<-EOC
    	mysql -u root -e "create database redmine default character set utf8 collate utf8_general_ci;"
    	mysql -u root -e "grant all on redmine.* to redmine@localhost identified by 'VDKM49CtMEF4eAGE';"
    	mysql -u root -e "flush privileges;"
    	EOC
    end
end

template "/var/lib/redmine/config/database.yml" do
	source "database.yml.2.0.1.erb"
		variables(
			:host => "#{node['redmine']['datasource']['host']}",
			:username => "#{node['redmine']['datasource']['username']}",
			:password => "#{node['redmine']['datasource']['password']}",
			:database_name => "#{node['redmine']['datasource']['name']}",
		)
	mode "0664"
end

template "/var/lib/redmine/config/configuration.yml" do
        source "configuration.yml.2.0.1.erb"
        mode "0664"
end

template "/var/lib/redmine/Gemfile" do
	source "Gemfile.erb"
	mode "0664"
end

template "/var/lib/redmine/lib/tasks/load_default_data_jp.rake" do
	source "load_default_data_jp.rake.erb"
	mode "0664"
end

gem_package "bundler" do
	options("--no-rdoc --no-ri")
	gem_binary("/usr/bin/gem1.9")
end

bash "bundle exe" do
	not_if { File.exists?('/var/lib/redmine/bundle_success')}
	cwd "/var/lib/redmine"
	code <<-EOC
		/usr/local/bin/bundle install --without development test rmagick postgresql sqlite --path /var/lib/redmine/gems
		/usr/local/bin/bundle exec rake generate_secret_token
		/usr/local/bin/bundle exec rake db:migrate RAILS_ENV=production
		/usr/local/bin/bundle exec rake redmine:load_default_data_jp RAILS_ENV=production
	EOC
end

bash "bundle success" do
	not_if { File.exists?('/var/lib/redmine/bundle_success')}
	cwd "/var/lib/redmine"
	code <<-EOC
		touch "bundle_success"
	EOC
end

bash "install passenger" do
	 not_if { File.exists?('/usr/local/share/gems/gems/passenger-3.0.19/') }
	code <<-EOC
	gem1.9 install passenger --no-rdoc --no-ri
	EOC
end


bash "apache bind passenger" do
	not_if { File.exists?('/usr/local/share/gems/gems/passenger-3.0.19/ext/apache2/mod_passenger.so') }
	code <<-EOC
	passenger-install-apache2-module -a
	EOC
end

template "/etc/httpd/conf.d/passenger.conf" do
	source "passenger.conf.erb"
	mode "0664"
end

service "httpd" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end

template "/etc/httpd/conf.d/redmine.conf" do
	source "httpd_vhost.conf.erb"
	mode "0664"
	notifies :reload, 'service[httpd]'
end
