#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use File::Basename 'dirname';
use File::Spec;
use lib join '/', File::Spec->splitdir(File::Spec->rel2abs(dirname(__FILE__))), 'lib';
use CompBot;
    
    my $cbot = CompBot->new;
    $cbot->url_match(qr{dev.example.com});
    $cbot->url_translate(sub {
        my $url = shift;
        $url->host('example.com');
        return $url;
    });
    $cbot->start('http://dev.example.com/index.htm');
