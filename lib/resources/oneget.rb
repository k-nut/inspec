# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

# This resource talks with OneGet (https://github.com/OneGet/oneget)
# Its part of Windows Management Framework 5.0 and part of Windows 10
#
# Usage:
# describe oneget('zoomit') do
#   it { should be_installed }
# end
class OneGetPackage < Inspec.resource(1)
  name 'oneget'

  def initialize(package_name)
    @package_name = package_name

    # verify that this resource is only supported on Windows
    return skip_resource 'The `oneget` resource is not supported on your OS.' if inspec.os[:family] != 'windows'
  end

  def info
    return @info if defined?(@info)

    @info = {}
    @info[:type] = 'oneget'
    @info[:installed] = false

    cmd = inspec.command("Get-Package -Name '#{@package_name}' | ConvertTo-Json")
    # cannot rely on exit code for now, successful command returns exit code 1
    # return nil if cmd.exit_status != 0
    # try to parse json

    begin
      pkgs = JSON.parse(cmd.stdout)
      @info[:installed] = true

      # sometimes we get multiple values
      if pkgs.is_a?(Array)
        # select the first entry
        pkgs = pkgs.first
      end
    rescue JSON::ParserError => _e
      return @info
    end

    @info[:name] = pkgs['Name'] if pkgs.key?('Name')
    @info[:version] = pkgs['Version'] if pkgs.key?('Version')
    @info
  end

  def installed?
    info[:installed] == true
  end

  def version
    info[:version]
  end

  def to_s
    "OneGet Package #{@package_name}"
  end
end
