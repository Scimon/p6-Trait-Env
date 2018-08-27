use v6.c;
use Test;
use Trait::Env;

class TestClass {
    has %.sep-hash is env{:default({"a"=>"b"}), :sep<:>, :kvsep<;>};
}

subtest {
    temp %*ENV = ( :SEP_HASH<a;b:b;c:d;e> );

    my $tc = TestClass.new();
    is $tc.sep-hash, { "a" => "b", "b" => "c", "d" => "e" } , "String to Hash works";

}, "Simple KV Hash";

subtest {
    temp %*ENV = ();

    my $tc = TestClass.new();
    is $tc.sep-hash, { "a" => "b" } , "Default is good";

}, "Simple KV Hash Default";

class RequiredTest {
    has %.sep-hash is env{:required, :sep<:>, :kvsep<;>};
}

subtest {
    temp %*ENV = ();

    throws-like { my $tc = RequiredTest.new() }, X::Trait::Env::Required::Not::Set, "Test Class dies with missing required";

}, "Required Test";

class NamedHash {
    has %.post-hash is env( :post_match<_POST> );
    has %.pre-hash is env( :pre_match<PRE_> );
    has %.both-hash is env{ :pre_match<PRE_>, :post_match<_POST> };
}

subtest {
    temp %*ENV = ( :TEST_POST<test>, :HOME_POST<home>,
		   :THIS_PRE_POST_NOT<nope>,
		   :PRE_TEST<test>, :PRE_HOME<home>,
		   :PRE_TEST_POST<test>
		 );

    my $tc = NamedHash.new();
    is $tc.post-hash, { "TEST_POST" => "test", "HOME_POST" => "home", "PRE_TEST_POST" => "test"  } , "Post Named hashes";
    is $tc.pre-hash, { "PRE_TEST" => "test", "PRE_HOME" => "home", "PRE_TEST_POST" => "test"  } , "Pre Named hashes";
    is $tc.both-hash, { "PRE_TEST_POST" => "test"  } , "Both Named hashes";

}, "Named hashes";

done-testing;
