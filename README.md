[![Build Status](https://travis-ci.org/Scimon/p6-Trait-Env.svg?branch=master)](https://travis-ci.org/Scimon/p6-Trait-Env)

NAME
====

Trait::Env - Trait to set an attribute from an environment variable.

SYNOPSIS
========

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

DESCRIPTION
===========

Trait::Env is exports the new trait `is env`.

Currently it's only working on Class / Role Attributes but I plan to expand it to variables as well in the future. 

Note the the variable name will be uppercased and any dashes changed to underscores before matching against the environment. This functionality may be modifiable in the future.

For Booleans the standard Empty String == `False` other String == `True` works but the string "True" and "False" (any capitalization) will also map to True and False respectively.

If a required attribute is not set the code will raise a `X::Trait::Env::Required::Not::Set` Exception.

Defaults can be set using the standard `is default` trait or the `:default` key. Note that for Positional attributes only the `:default` key works.

Positional attributes will use the attribute name (after coercing) as the prefix to scan %*ENV for. Any keys starting with that prefix will be ordered by the key name lexically and their values put into the attribute.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

Thanks to Jonathan Worthington and Elizabeth Mattijsen for giving me the framework to build this on. Any mistakes are mine. 

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
