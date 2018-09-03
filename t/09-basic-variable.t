use v6.c;
use Test;
use Trait::Env;

my %env_copy;

subtest {
    BEGIN {
        %env_copy = %*ENV;
        %*ENV = { "ATTRIBUTE" => "Here" };
    }
    END { %*ENV = %env_copy; }
        
    my $attribute is env;
    my $ATTRIBUTE is env;

    is $attribute, "Here", "We have a test value";
    is $ATTRIBUTE, "Here", "We have a test value (uc WORKS)";

}, "Initial Variable version. Loaded from Package";

done-testing;
