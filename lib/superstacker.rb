require 'superstacker/aws'
require 'superstacker/template'
require 'aws-sdk'
require 'iniparse'

module SuperStacker
  module_function

  def configure_aws_sdk
    return unless File.exists? File.expand_path('~/.awscli')

    conf = IniParse.parse(File.read(File.expand_path('~/.awscli')))['default']
    ::AWS.config(access_key_id: conf['aws_access_key_id'],
               secret_access_key: conf['aws_secret_access_key'],
               region: conf['region'])
  end

  def bootstrap!
    configure_aws_sdk
  end
end

SuperStacker.bootstrap!
