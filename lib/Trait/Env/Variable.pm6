use v6.c;

unit module Trait::Env::Variable;

use Trait::Env::Exceptions;
use Trait::Env::Shared;

multi sub trait_mod:<is>(Variable $var, :$env ) is export {
    my $env-name = coerce-name( $var.name, :!attr );
    $var.var = coerce-value( $var.var, %*ENV{$env-name} );
    return $var;
}
