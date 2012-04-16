#
# Cookbook Name:: windows
# Provider:: feature_servermanagermodule
#
# Copyright 2012, Readsource Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include Chef::Provider::WindowsFeature::Base
include Chef::Mixin::ShellOut
include Windows::Helper

def install_feature(name)
  poshResource = Chef::Resource::Powershell.new("add feature", run_context) do
    code <<-EOH
      Import-Module ServerManager
      Add-WindowsFeature "#{@new_resource.feature_name}"
    EOH
  end
  poshResource.run_action(:run)
end

def remove_feature(name)
  poshResource = Chef::Resource::Powershell.new("remove feature", run_context) do
    code <<-EOH
      Import-Module ServerManager
      Remove-WindowsFeature "#{@new_resource.feature_name}"
    EOH
  end
  poshResource.run_action(:run)
end

def installed?
  poshOutFile = "#{ENV['TEMP']}\\feature_smm_poshoutput.tmp"
  puts("DEBUG: #{poshOutFile}")
  puts("DEBUG: Checking for '#{@new_resource.feature_name}'")
  @installed ||= begin
    poshResource = Chef::Resource::Powershell.new("query feature", run_context) do
      code <<-EOH
        Import-Module ServerManager
        $feature = Get-WindowsFeature "#{@new_resource.feature_name}"
        Set-Content -Path "#{poshOutFile}" -Value $feature.Installed
      EOH
    end
    poshResource.run_action(:run)

	is_installed = false
	if ::File.exist?(poshOutFile) then
		puts "DEBUG: poshOutFile found"
		is_installed = ::File.read(poshOutFile).include?('True')
	else
		puts "DEBUG: poshOutFile not found"
	end
	
    #( ::File.exist?(poshOutFile) && ::File.read(poshOutFile).include?('True') )
	
	puts "DEBUG: is_installed=#{is_installed}"
	
	is_installed
  end
end