# [[[ TEST : 'ERROR ECVPAPL02' ]]]
# [[[ TEST : 'Global symbol "$TYPED_PIE" requires explicit package name' ]]]
# [[[ HEADER ]]]
package RPerl::Test::Constant::Class_00_Bad_12;
use strict;
use warnings;
use RPerl;
our $VERSION = 0.001_000;

# [[[ OO INHERITANCE ]]]
use parent qw(RPerl::Test);
use RPerl::Test;

# [[[ CRITICS ]]]
## no critic qw(ProhibitUselessNoCritic ProhibitMagicNumbers RequireCheckedSyscalls)  # USER DEFAULT 1: allow numeric values and print operator
## no critic qw(ProhibitConstantPragma)  # USER DEFAULT 3: allow constants

# [[[ CONSTANTS ]]]
use constant PI  => my number $TYPED_PI  = 3.141_59;
use constant PIE =>  string $TYPED_PIE = 'pecan';

# [[[ OO PROPERTIES ]]]
our %properties = ( ## no critic qw(ProhibitPackageVars)  # USER DEFAULT 2: allow OO properties
    empty_property => my integer $TYPED_empty_property = 2
);

# [[[ OO METHODS ]]]
our void__method $empty_method = sub { 2; };

1;                  # end of class