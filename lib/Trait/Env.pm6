use v6.c;


my %EXPORT;
# Save the original trait_mod:<is> candidates, so we can pass on through
# all of the trait_mod:<is>'s that cannot be handled here.
# Stolen from Lizmat in Hash::LRU.
BEGIN my $original_trait_mod_is = &trait_mod:<is>;

class X::Trait::Env::Required::Not::Set is Exception {
    has $.payload;
    method message() {
        $.payload;
    }
}

module Trait::Env:ver<0.2.0>:auth<cpan:SCIMON> {

    # Manually export
    %EXPORT<&trait_mod:<is>> := proto sub trait_mod:<is>(|) {*}

    multi sub trait_mod:<is> ( Attribute $attr, :%env ) {
        apply-trait( $attr, %env );
    }
    
    multi sub trait_mod:<is> ( Attribute $attr, :$env ) {
        apply-trait( $attr, {} );
    }   

    sub coerce-name ( Str \name ) {
        my $env-name = name.substr(2).uc;
        $env-name ~~ s:g/'-'/_/;
        $env-name;
    }

    sub apply-trait ( Attribute $attr, %env ) {
        my $env-name = coerce-name( $attr.name );
        my &build = do given $attr.type {
            when Positional { positional-build( $env-name, $attr, %env ) };
            default { scalar-build( $env-name, $attr, %env ) };
        }
        $attr.set_build( &build );
    }

    sub coerce-value( Mu $type, $value ) {
        if ( Bool ~~ $type && so $value ~~ m:i/"false"|"true"/ ) {
            so $value ~~ m:i/"true"/;
        } else {
            Any ~~ $type ?? $value !! $type($value);
        }
    }

    sub positional-build ( Str $env-name, Attribute $attr, %env ) {
        my $name-match = /^ "$env-name" .+ $/;
        return -> | {
            my @values = %*ENV.keys.grep( $name-match ).sort.map( -> $k { %*ENV{$k} } );
            my $type = Positional ~~ $attr.type ?? Any !! $attr.type.^role_arguments[0];
            if @values.elems {
                @values.map( -> $v { coerce-value( $type, $v ) } );
            } elsif %env<default> {
                %env<default>;
            } elsif %env<required> {
                die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
            } else {
                $type;
            }
        };
    }
    
    sub scalar-build ( Str $env-name, Attribute $attr, %env ) {
        return -> $, $default {
            with %*ENV{$env-name} -> $value {
                coerce-value( $attr.type, $value );
            } elsif $default|%env<default> {
                $default // %env<default>;
            } elsif %env<required> {
                die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
            } else {
                Any ~~ $attr.type ?? Any !! $attr.type;
            }
        };
    }

    # Make sure we can hadle other traits.
    multi sub trait_mod:<is>(|c) { $original_trait_mod_is(|c) }

}

sub EXPORT { %EXPORT }

=begin pod

=head1 NAME

Trait::Env - Trait to set an attribute from an environment variable.

=head1 SYNOPSIS

  use Trait::Env;
  class Test {
      # Sets from %*ENV{HOME}. Undef if the var doesn't exist
      has $.home is env;
      # Sets from %*ENV{TMPDIR}. Defaults to '/tmp'
      has $.tmpdir is env is default "/tmp"; 
      # Sets from %*ENV{EXTRA_DIR}. Defaults to '/tmp'
      has $.extra-dir is env( :default</tmp> ); 
      # Set from %*ENV{WORKDIR}. Dies if not set.
      has $.workdir is env(:required);
      # Set from %*ENV{READ_DIRS.+} ordered lexically
      has @.read-dirs is env;
  }

=head1 DESCRIPTION

Trait::Env is exports the new trait C<is env>.

Currently it's only working on Class / Role Attributes but I plan to expand it to variables as well in the future. 

Note the the variable name will be uppercased and any dashes changed to underscores before matching against the environment.
This functionality may be modifiable in the future.

For Booleans the standard Empty String == C<False> other String == C<True> works but the string "True" and "False" (any capitalization) will also map to True and False respectively.

If a required attribute is not set the code will raise a C<X::Trait::Env::Required::Not::Set> Exception.

Defaults can be set using the standard C<is default> trait or the C<:default> key. Note that for Positional attributes only the C<:default> key works.

Positional attributes will use the attribute name (after coercing) as the prefix to scan %*ENV for.
Any keys starting with that prefix will be ordered by the key name lexically and their values put into the attribute.

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

Thanks to Jonathan Worthington and Elizabeth Mattijsen for giving me the framework to build this on. Any mistakes are mine. 

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
