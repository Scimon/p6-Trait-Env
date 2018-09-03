use v6.c;
use Test;
use Trait::Env;

my %env_copy;

subtest {
    BEGIN {
        %env_copy = %*ENV;
        %*ENV = {
	    "ATTRIBUTE" => "Here",
	    "INT" => 1,
	    "STR" => "Text",
	    "BOOL" => "true"
		};
    }
    END { %*ENV = %env_copy; }
        
    my $attribute is env;
    my $ATTRIBUTE is env;
    my Int $int is env;
    my Str $str is env;
    my Bool $bool is env;
    
    is $attribute, "Here", "We have a test value";
    is $ATTRIBUTE, "Here", "We have a test value (uc WORKS)";
    is $int, 1, "Int Coercion is OK";
    is $str, "Text", "Test Coercion is OK";
    is $bool, True, "Bool coercion is OK";
    
}, "Initial Variable version. Loaded from Package";

done-testing;
