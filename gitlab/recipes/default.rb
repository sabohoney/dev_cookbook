#
# Cookbook Name:: gitlab
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

doc_root = "#{node['gitlab']['docroot']}#{node['gitlab']['user']}"

# 必要なミドルウェアをインストール
%w[
	libxslt 
	libxslt-devel 
	libicu 
	libicu-devel 
	mysql55 
	mysql55-devel 
	httpd24 
	httpd24-devel 
	patch 
	gcc 
	gcc-c++ 
	curl-devel 
	zlib-devel
].each do |pkgname|
	package "#{pkgname}" do
		action :install
	end
end


# サービス設定
service "httpd" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end

gem_package "bundler" do
	options("--no-rdoc --no-ri")
	gem_binary("/usr/bin/gem1.9")
	action :install
end

gem_package "charlock_holmes" do
	options("--no-rdoc --no-ri")
	version "0.6.9.4"
	gem_binary("/usr/bin/gem1.9")
	action :install
end

# ユーザー作成
user "#{node['gitlab']['user']}" do
	home "#{doc_root}"
	comment "git admin user"
	action :create
end

# 公開鍵置き場準備
directory "#{doc_root}/.ssh" do
	group "#{node['gitlab']['user']}"
	owner "#{node['gitlab']['user']}"
	mode 0700
	action :create
end

# authorized_keys準備
file "#{doc_root}/.ssh/authorized_keys" do
	group "#{node['gitlab']['user']}"
	owner "#{node['gitlab']['user']}"
	mode 0600
	action :create
end

# gitlab-satellitesディレクトリ作成
directory "#{doc_root}/gitlab-satellites" do
	group "#{node['gitlab']['user']}"
	owner "#{node['gitlab']['user']}"
	mode 0755
	action :create
end

# gitlab-shellをclone
git "#{doc_root}/gitlab-shell" do
	repository "git://github.com/gitlabhq/gitlab-shell.git"
	reference "#{node['gitlab']['gitlab-shell']['version']}"
	action :checkout
end

# gitlabをclone
git "#{doc_root}/gitlab" do
	repository "git://github.com/gitlabhq/gitlabhq.git"
	reference "#{node['gitlab']['gitlab-app']['version']}"
	action :checkout
end

# ディレクトリの権限変更
%w[log tmp].each do |directory_name| 
	directory "#{doc_root}/gitlab/#{directory_name}"  do
		group "#{node['gitlab']['user']}"
		owner "#{node['gitlab']['user']}"
		recursive true
	end
	directory "#{doc_root}/gitlab/#{directory_name}" do
			mode 0755
	end
end

# 設定ファイルを配置
node['gitlab']['templates'].each do |template, attr|
	template "#{attr['path']}/#{template}" do
		user "#{node['gitlab']['user']}"
		group "#{node['gitlab']['user']}"
		variables(
			:servername => "#{node['gitlab']['servername']}",
			:docroot => "#{node['gitlab']['docroot']}",
		)
		source "#{template}.erb"
		mode "0755"
		notifies :restart, "service[httpd]"
	end
end

node['gitlab']['gitlab-shell']['templates'].each do |template, attr|
	template "#{doc_root}/gitlab-shell/#{attr['path']}/#{template}" do
		user "#{node['gitlab']['user']}"
		group "#{node['gitlab']['user']}"
		variables(
			:servername => "#{node['gitlab']['servername']}",
			:docroot => "#{doc_root}",
			:user => "#{node['gitlab']['user']}",
		)
		source "#{template}.erb"
		mode "0664"
	end
end

node['gitlab']['gitlab-app']['templates'].each do |template, attr|
	template "#{doc_root}/gitlab/#{attr['path']}/#{template}" do
		user "#{node['gitlab']['user']}"
		group "#{node['gitlab']['user']}"
		variables(
			:servername => "#{node['gitlab']['servername']}",
			:docroot => "#{doc_root}",
			:user => "#{node['gitlab']['user']}",
			:database_name => "#{node['gitlab']['database']['name']}",
			:database_user => "#{node['gitlab']['database']['user']}",
			:database_password => "#{node['gitlab']['database']['password']}",
			:database_host => "#{node['gitlab']['database']['host']}",
		)
		source "#{template}.erb"
		mode "0664"
	end
end

# gem install
#
# git設定
template "#{doc_root}/.gitconfig" do
	group "#{node['gitlab']['user']}"
	user "#{node['gitlab']['user']}"
	source "gitconfig.erb"
end

# gitlab-shellをインストール
bash "install gitlab-shell" do
	user "#{node['gitlab']['user']}"
	group "#{node['gitlab']['user']}"
	cwd "#{doc_root}/gitlab-shell"
	code <<-EOC
		./bin/install
	EOC
end

# gitlabをインストール
bash "install gitlab" do
	user "root"
	group "root"
	cwd "#{doc_root}/gitlab"
	code <<-EOC
		bundle install --deployment --without development test postgres rmagick
	EOC
end


# gitlabをインストール
bash "insert db" do
	user "git"
	group "git"
	cwd "#{doc_root}/gitlab"
	code <<-EOC
		bundle exec rake gitlab:setup RAILS_ENV=production force=yes
	EOC
end


service "gitlab" do
	# start|stop|restart|status
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end
