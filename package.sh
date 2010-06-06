#!/bin/sh
VERSION=0.1.0

rm *.gem *.tar.bz2
rm -rf doc
rdoc  -m README.rdoc README.rdoc --title 'activerecord-cassandra-adapter is a Cassandra adapter for ActiveRecord.'
tar jcvf activerecord-cassandra-adapter-${VERSION}.tar.bz2 --exclude=.svn lib README *.gemspec doc
gem build activerecord-cassandra-adapter.gemspec
