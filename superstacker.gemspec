Gem::Specification.new do |s|
  s.name        =  'superstacker'
  s.version     =  '0.8.2'
  s.executables << 'super-stacker'
  s.summary     =  'Use a DSL to generate your CloudFormation templates.'
  s.authors     =  ['Jordan Hagan']
  s.files       =  Dir['lib/**/*.rb']
  s.add_dependency 'thor', '~> 0.17.0'
  s.add_dependency 'aws-sdk-v1', '~> 1.49.0'
  s.add_dependency 'iniparse', '~> 1.1.6'
  s.add_dependency 'diffy', '~> 3.0.1'
end
