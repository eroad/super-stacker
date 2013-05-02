Gem::Specification.new do |s|
  s.name        =  'superstacker'
  s.version     =  '0.4.0'
  s.executables << 'super-stacker'
  s.summary     =  'Use a DSL to generate your CloudFormation templates.'
  s.authors     =  ['Jordan Hagan']
  s.files       =  Dir['lib/**/*.rb']
  s.add_dependency 'thor', '~> 0.17.0'
end
