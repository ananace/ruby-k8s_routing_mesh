# frozen_string_literal: true

require_relative 'lib/k8s_routing_mesh/version'

Gem::Specification.new do |spec|
  spec.name = 'k8s_routing_mesh'
  spec.version = K8sRoutingMesh::VERSION
  spec.authors = ['Alexander Olofsson']
  spec.email = ['alexander.olofsson@liu.se']

  spec.summary = 'A routing mesh dameon for Kubernetes'
  spec.description = 'Builds and updates a mesh of static routes for Kubernetes nodes'
  spec.homepage = 'https://github.com/ananace/ruby-k8s_routing_mesh'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = ''

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir['{bin,lib}/**/*'] + %w[Gemfile]
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }

  spec.add_dependency 'kubeclient'
end
