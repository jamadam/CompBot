#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use File::Basename 'dirname';
use File::Spec;
use lib join '/', File::Spec->splitdir(File::Spec->rel2abs(dirname(__FILE__))), 'lib';
use CompBot;
    
    my $sd = CompBot->new;
    $sd->ua->max_redirects(5);
    $sd->url_match(qr{test.example.com});
    $sd->url_translate(sub {
        my $url = shift;
        $url->host('example.com');
        return $url;
    });
    $sd->start('http://example.com/index.htm');
