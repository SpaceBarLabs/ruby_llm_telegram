# -*- encoding: utf-8 -*-
# stub: ruby_llm 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby_llm".freeze
  s.version = "1.0.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/crmne/ruby_llm/issues", "changelog_uri" => "https://github.com/crmne/ruby_llm/commits/main", "documentation_uri" => "https://rubyllm.com", "homepage_uri" => "https://rubyllm.com", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/crmne/ruby_llm" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Carmine Paolino".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-03-11"
  s.description = "A delightful Ruby way to work with AI. Chat in text, analyze and generate images, understand audio, and use tools through a unified interface to OpenAI, Anthropic, Google, and DeepSeek. Built for developer happiness with automatic token counting, proper streaming, and Rails integration. No wrapping your head around multiple APIs - just clean Ruby code that works.".freeze
  s.email = ["carmine@paolino.me".freeze]
  s.homepage = "https://rubyllm.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1.0".freeze)
  s.rubygems_version = "3.5.22".freeze
  s.summary = "Beautiful Ruby interface to modern AI".freeze

  s.installed_by_version = "3.5.16".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<event_stream_parser>.freeze, ["~> 1".freeze])
  s.add_runtime_dependency(%q<faraday>.freeze, ["~> 2".freeze])
  s.add_runtime_dependency(%q<faraday-multipart>.freeze, ["~> 1".freeze])
  s.add_runtime_dependency(%q<faraday-retry>.freeze, ["~> 2".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2".freeze])
end
