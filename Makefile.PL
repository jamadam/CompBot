#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'CompBot',
  VERSION_FROM => 'CompBot',
  AUTHOR       => 'jamadam <sugama@jamadam.com>',
  PREREQ_PM    => {
        'Mojolicious'   => '3',
        'Text::Diff'    => '1.41',
    },
  test         => {TESTS => 't/*.t'},
);
