# [[[ PREPROCESSOR ]]]
# <<< PARSE_ERROR: 'ERROR ECVPAPC02' >>>
# <<< PARSE_ERROR: 'RequireEndWithOne' >>>

# [[[ HEADER ]]]
use RPerl;
package RPerl::Test::Module::Package_00_Bad_Terminator_00;
use strict;
use warnings;
our $VERSION = 0.001_000;

# [[[ SUBROUTINES ]]]
our void $empty_sub = sub {
    return 2;
};

0;                  # end of package
