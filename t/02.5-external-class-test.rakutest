use v6;
use Test;
use lib "{$*PROGRAM.dirname}/lib";
use Config;

subtest {
    temp %*ENV = { :VALUE<value> }
    my $c;
    ok $c = Config.new(), "External Class created OK";
    is $c.value, 'value', "Config value OK";
}

done-testing;
