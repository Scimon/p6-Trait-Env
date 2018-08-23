use v6.c;
use Test;
use Trait::Env;

class TestClass {
    has @.simple-array is env(:default([1,2]));
}



subtest {
    temp %*ENV = (
        :SIMPLE_ARRAY_1<1>,
        :SIMPLE_ARRAY_2<2>,
        :SIMPLE_ARRAY_3<3>,
        :SIMPLE_ARRAY_4<4>
    );

    my $tc = TestClass.new();
    is $tc.simple-array, ["1","2","3","4"], "Simple Array Works";
    
}, "Simple Numeric Array";

subtest {
    temp %*ENV = (
        :SIMPLE_ARRAY1<4>,
        :SIMPLE_ARRAY2<3>,
        :SIMPLE_ARRAY3<2>,
        :SIMPLE_ARRAY4<1>
    );

    my $tc = TestClass.new();
    is $tc.simple-array, ["4","3","2","1"], "Ordering on keys works";
    
}, "Check Ordering";

subtest {
    temp %*ENV = ();

    my $tc = TestClass.new();
    is $tc.simple-array, [1,2], "Default OK";
    
}, "Check Default";


done-testing;
