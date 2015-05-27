## no critic qw(ProhibitUselessNoCritic PodSpelling ProhibitExcessMainComplexity

# [[[ PREPROCESSOR ]]]
# <<< PARSE_ERROR: 'ERROR ECVPARP00' >>>
# <<< PARSE_ERROR: 'Unexpected Token:  package' >>>

# [[[ HEADER ]]]
package RPerl::Test::Critic::Class_01_Bad_03;
use strict;
use warnings;
use RPerl;
our $VERSION = 0.001_000;

# [[[ OO INHERITANCE ]]]
use parent qw(RPerl::Test);
use RPerl::Test;

# [[[ CRITICS ]]]
## no critic qw(ProhibitUselessNoCritic ProhibitMagicNumbers RequireCheckedSyscalls)  # USER DEFAULT 1: allow numeric values & print operator

# [[[ OO PROPERTIES ]]]
our hashref $properties
    = { empty_property => my integer $TYPED_empty_property = 2 };

# [[[ OO METHODS & SUBROUTINES ]]]
our void_method $empty_method = sub {
    return 2;
};

1;                  # end of class
