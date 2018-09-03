use v6.c;

unit module Trait::Env::Variable;

use Trait::Env::Exceptions;

multi sub trait_mod:<is>(Variable $var, :$env ) is export {
    my $env-name = $var.name.substr(1).uc;
    $env-name ~~ s:g/'-'/_/;
    $var.var = %*ENV{$env-name};
    return $var;
}
