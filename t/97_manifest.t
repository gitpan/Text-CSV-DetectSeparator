#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use Test::More tests => 1;

eval "use Test::CheckManifest 0.5";
plan skip_all => "Test::CheckManifest 0.5 required" if $@;
ok_manifest();

