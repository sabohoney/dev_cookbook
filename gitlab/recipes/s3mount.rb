#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Json
#{
#	"gitlab" : {
#		"backup" : {
#			"accesskey" : "",
#			"secretkey" : "",
#			"bucket" : "",
#		}
#	},
#	"run_list" : [
#		"gitlab::s3mount"
#	]
#}



# s3fs install

%w{
	make
	gcc
	gcc-c++
	make
	libstdc++-devel
	libxml2-devel
	curl-devel
	fuse
	fuse-devel
	
}.each do |pkgname|
	package "#{pkgname}" do
		action :install
	end
end

cookbook_file "/tmp/s3fs-1.62.tar.gz" do
    mode 00644
#    checksum "dabb704a9307cb2a2b8abaf1c2d0d19e"
end

bash "s3fs install" do
	not_if { File.exists?('/usr/local/src/s3fs-1.62/')}
	code <<-EOC
	   tar -xzf /tmp/s3fs-1.62.tar.gz -C /usr/local/src/
	   cd /usr/local/src/s3fs-1.62/
	   ./configure --prefix=/usr
	   make
	   make install
	   rm -f /tmp/s3fs-1.62.tar.gz
	EOC
end

template "/etc/passwd-s3fs" do
#    source "passwd-s3fs"
    variables(
        :accesskey => "#{node['gitlab']['backup']['accesskey']}",
        :secretkey => "#{node['gitlab']['backup']['secretkey']}",
    )
    mode 0640
end

Directory "/mnt/s3" do
	group "apache"
	user "apache"
end

Directory "/mnt/s3/gitlab" do
	group "git"
	user "git"
end

bash "s3 mount" do
	not_if { File.exists?('/mnt/s3/gitlab/repositories')}
	code <<-EOC
	   s3fs #{node['gitlab']['backup']['bucket']} /mnt/s3/gitlab -o allow_other
	EOC
end

bash "backup file" do
	not_if { File.exists?('/mnt/s3/gitlab/repositories')}
	code <<-EOC
	   mv /var/lib/git/repositories /mnt/s3/gitlab/
	EOC
end

link "/var/lib/git/repositories" do
    to "/mnt/s3/gitlab/repositories"
    link_type :symbolic
end
