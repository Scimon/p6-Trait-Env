use v6.c;
unit class Trait::Env:ver<0.0.1>:auth<cpan:SCIMON>;

multi sub trait_mod:<is> ( Attribute $attr, :$env! ) is export {
    my $env-name = $attr.name.substr(2).uc;
    $attr.set_build(
        -> $, $default {
            with %*ENV{$env-name} -> $value {
                Any ~~ $attr.type ?? $value !! $attr.type()($value);
            } elsif $default {
                $default;
            } else {
                die "environment name $env-name must exist";
            }
        }
    );
}

=begin pod

=head1 NAME

Trait::Env - Trait to set an attribute from an environment variable.

=head1 SYNOPSIS

  use Trait::Env;

=head1 DESCRIPTION

Trait::Env is ...

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
