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
        # Set from %*ENV{WORKDIR}. Dies if not set.
        has $.workdir is env(:required);
    }

DESCRIPTION
===========

Trait::Env is exports the new trait `is env`.

Currently it's only working on Class / Role Attributes but I plan to expand it to variables as well in the future. 

Note the the varialbe name will be uppercased and any dashes changed to underscores before matching against the environment. This functionality may be modifiable in the future.

For Booleans the standard Empty String == `False` other String == `True` works but the string "True" and "False" (any capitalization) will also map to True and False respectively.

If a required attribute is not set the code will raise a `X::Trait::Env::Required::Not::Set` Exception.

Thanks to Jonathan Worthington and Elizabeth Mattijsen for giving me the framework to build this on. Any mistakes are mine. 

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
