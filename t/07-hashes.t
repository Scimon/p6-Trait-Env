use v6.c;
use Test;
use Trait::Env;

class TestClass {
    has %.sep-hash is env{:default({"a"=>"b"}), :sep<:>, :kvsep<;>} is default({"a" => "b"});
}

subtest {
    temp %*ENV = ( :SEP_HASH<a;b:b;c:d;e> );

    my $tc = TestClass.new();
    is $tc.sep-hash, { "a" => "b", "b" => "c", "d" => "e" } , "String to Hash works";

}, "Simple KV Hash";


done-testing;
