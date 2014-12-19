#
# Cookbook Name:: omnibus_updater_windows
# Recipe:: installer
#
# Copyright (C) 2014 Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'omnibus_updater_windows'
remote_path = node[:omnibus_updater][:full_url].to_s

# Scheduled task options
task_name = "Upgrade Chef client"
task_command = "msiexec.exe /i \"#{node[:omnibus_updater][:cache_dir]}\\#{File.basename(remote_path)}\" /qn /quiet /norestart ADDLOCAL=\\\"ChefClientFeature,ChefServiceFeature\\\""
t = Time.now + (node[:omnibus_updater][:scheduled_task_delay] * 60)

# Remove any existing scheduled task
execute "delete scheduled task" do
  command "schtasks /Delete /F /TN \"#{task_name}\""
  action :run
  only_if { omnibus_updater_task_exists?(task_name) }
end

execute "omnibus_install[#{File.basename(remote_path)}]" do
  if node["platform_version"] >= "6"
    command "schtasks /Create /TN \"#{task_name}\" /TR \"#{task_command}\" /SC ONCE /ST #{t.strftime("%H:%M")} /RU SYSTEM /RL HIGHEST"
  else
    command "schtasks /Create /TN \"#{task_name}\" /TR \"#{task_command}\" /SC ONCE /ST #{t.strftime("%H:%M")} /RU SYSTEM"
  end
  action :nothing
end

ruby_block 'Omnibus Chef install notifier' do
  block{ true }
  action :nothing
  subscribes :create, resources(:remote_file => "omnibus_remote[#{File.basename(remote_path)}]"), :immediately
  notifies :run, resources(:execute => "omnibus_install[#{File.basename(remote_path)}]"), :delayed
end

include_recipe 'omnibus_updater_windows::old_package_cleaner'
