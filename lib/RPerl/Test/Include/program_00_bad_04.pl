#!/usr/bin/perl
# [[[ TEST : 'ERROR ECVPAPL02' ]]]
# [[[ TEST : 'Missing operator before Bar?' ]]]
# [[[ HEADER ]]]
use strict;
use warnings;
use RPerl;
our $VERSION = 0.001_000;

# [[[ INCLUDES ]]]
use RPerl::Test::Foo;
use RPerl::Test:)Bar;

# [[[ OPERATIONS ]]]
my integer $i = 2 + 2;