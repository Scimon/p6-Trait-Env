use v6;

unit module Trait::Env::Attribute;

use Trait::Env::Exceptions;
use Trait::Env::Shared;
use JSON::Tiny;

my role TraitEnvStore {
    has Str $.store-env-name is rw;
    has $.store-type is rw;
    has %.store-settings is rw;

    method scalar-build( $, $default ) {       
        with %*ENV{$!store-env-name} -> $value {
             if ( %!store-settings<json>:exists ) {
                 from-json( $value );
             } else {
                 coerce-value( $!store-type, $value );
             }
        } elsif $default|%!store-settings<default> {
            $default // %!store-settings<default>;
        } elsif %!store-settings<required> {
            die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$!store-env-name} not found in ENV") );
        } else {
            $!store-type;
        }
    }

    method associative-build( *@ ) {
        my %data;
	if ( %!store-settings<sep>:exists && %!store-settings<kvsep> ) {
	    %data = do with %!store-settings{"sep", "kvsep"} -> ( $sep, $kvsep ) {
		%*ENV{$!store-env-name}:exists ?? %*ENV{$!store-env-name}.split($sep).map( -> $str { my ($k, $v ) = $str.split($kvsep); $k => $v; } ) !! {};
	    }
	} else {
	    %data = ( ( %!store-settings<post_match>) || ( %!store-settings<pre_match>:exists ) ) ?? %*ENV !! ();
	    if %!store-settings<post_match>:exists {
		%data = %data.grep( -> $p { $p.key.ends-with( %!store-settings<post_match> ) } );
	    }
	    if %!store-settings<pre_match>:exists {
		%data = %data.grep( -> $p { $p.key.starts-with( %!store-settings<pre_match> ) } );
	    }
	}
	if %data.keys {
	    %data.map( -> $p { $p.key => coerce-value( $!store-type, $p.value ) } );
	} elsif %!store-settings<default> {
            %!store-settings<default>;
        } elsif %!store-settings<required> {
            die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$!store-env-name} not found in ENV") );
        }
    }

    method positional-build ( *@ ) {
        my $name = $!store-env-name;
        my $name-match = /^ "$name" .+ $/;
        my @values = do with %!store-settings<sep> -> $sep {
	    %*ENV{$!store-env-name}:exists ?? %*ENV{$!store-env-name}.split($sep) !! [];
        } else {
            %*ENV.keys.grep( $name-match ).sort.map( -> $k { %*ENV{$k} } );
        }
        if ( ( ! @values ) && ( %*ENV{$!store-env-name}:exists ) ) {
            @values = %*ENV{$!store-env-name}.split( "{$*DISTRO.path-sep}" );
        }
        if @values.elems {
            @values.map( -> $v { coerce-value( $!store-type, $v ) } );
        } elsif %!store-settings<default> {
            %!store-settings<default>;
        } elsif %!store-settings<required> {
            die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$!store-env-name} not found in ENV") );
        } else {
            $!store-type;
        }
    }
}

multi sub trait_mod:<is> ( Attribute $attr, :%env ) is export {
    apply-trait( $attr, %env );
}

multi sub trait_mod:<is> ( Attribute $attr, List :$env ) is export {
    apply-trait( $attr, $env.hash );
}


multi sub trait_mod:<is> ( Attribute $attr, :$env ) is export {
    apply-trait( $attr, {} );
}   

sub apply-trait ( Attribute $attr, %settings ) {
    my $env-name = coerce-name( $attr.name, :attr );
    given $attr.type {
        when Positional {
            my $type = Positional ~~ $attr.type ?? Any !! $attr.type.^role_arguments[0];
            $attr does TraitEnvStore;
            $attr.store-type = $type;
            $attr.store-env-name = $env-name;
            $attr.store-settings = %settings;
            $attr.set_build( -> |c { $attr.positional-build(|c) } );
        };
        when Associative {
            my $type = Associative ~~ $attr.type ?? Any !! $attr.type.^role_arguments[0];
            $attr does TraitEnvStore;
            $attr.store-type = $type;
            $attr.store-env-name = $env-name;
            $attr.store-settings = %settings;
            $attr.set_build( -> |c { $attr.associative-build(|c) } );
        };
        default {
            my $type =  Any ~~ $attr.type ?? Any !! $attr.type;
            $attr does TraitEnvStore;
            $attr.store-type = $type;
            $attr.store-env-name = $env-name;
            $attr.store-settings = %settings;
            $attr.set_build( -> |c { $attr.scalar-build(|c); } );
        };
    }
}
