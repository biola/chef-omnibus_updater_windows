#
# Cookbook Name:: omnibus_updater_windows
# Libraries:: helpers
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

def omnibus_updater_task_exists?(task_name)
  value = true
  # Windows 2008+
  if node["platform_version"] >= "6"
    output = `schtasks /Query /TN "#{task_name}" 2> NUL | find /c \"#{task_name}\"`
    value = (output.chomp == "0") ? false : true;
  # Windows 2003
  else
    value = (::File.exist?("#{ENV['windir']}/Tasks/#{task_name}.job")) ? true : false;   
  end
  value
end
