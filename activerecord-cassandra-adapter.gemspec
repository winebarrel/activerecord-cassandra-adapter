Gem::Specification.new do |spec|
  spec.name              = 'activerecord-cassandra-adapter'
  spec.version           = '0.1.0'
  spec.summary           = 'activerecord-cassandra-adapter is a Cassandra adapter for ActiveRecord.'
  spec.files             = Dir.glob('lib/**/*') + Dir.glob('spec/**/*') + %w(README.rdoc)
  spec.author            = 'winebarrel'
  spec.email             = 'sgwr_dts@yahoo.co.jp'
  spec.homepage          = 'http://github.com/winebarrel/activerecord-cassandra-adapter'
  spec.has_rdoc          = true
  spec.rdoc_options      << '--title' << 'activerecord-cassandra-adapter is a Cassandra adapter for ActiveRecord.'
  spec.extra_rdoc_files  = %w(README.rdoc)
  spec.add_dependency    'cassandra'
end
