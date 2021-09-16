Gem::Specification.new do |s|
  s.name        = 'rb-result'
  s.version     = '0.0.0'
  s.summary     = "Hola!"
  s.description = "Provides a wrapper for computations that may fail"
  s.authors     = ["Agustin Cornu"]
  s.email       = 'agustincornu@fastmail.com'
  s.files       = `git ls-files | grep -E '^(lib)'`.split("\n")
  s.license     = 'MIT'
  s.add_development_dependency "rspec"
end
