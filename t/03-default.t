use v6.c;
use Test;
use Trait::Env;

class TestClass {
    has $.attribute is env is default("attr");
    has $.attribute-two is default("attr2") is env;
}

subtest {
    temp %*ENV<ATTRIBUTE> = "Here";
    temp %*ENV<ATTRIBUTE_TWO> = "Here2";

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, "Here", "We have a test value";
    is $tc.attribute-two, "Here2", "We have a test value";   
    
    
}, "Defaults OK work and are ignored";

subtest {
    %*ENV<ATTRIBUTE>:delete;
    %*ENV<ATTRIBUTE_TWO>:delete;

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, "attr", "Test value is default";
    is $tc.attribute-two, "attr2", "Test value is default";   
    
    
}, "Defaults OK.";


done-testing;
