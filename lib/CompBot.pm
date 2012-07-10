package CompBot;
use strict;
use warnings;
use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::DOM;
use Mojo::IOLoop;
use Text::Diff;
use Test::More;
use List::Util;
our $VERSION = '0.01';
    
    has ua              => sub {Mojo::UserAgent->new->max_redirects(5)};
    has preprocess_a    => sub {sub {shift}};
    has preprocess_b    => sub {sub {shift}};
    has 'url_translate';
    has sleep           => '1';
    has 'url_match'     => '';
    has shuffle         => 0;
    has extension_not   => sub{[]};
    
    sub start {
        my ($self, $url) = @_;
        
        my @queue;
        
        push(@queue, $url);
        
        my %fixed;
        my $loop_id;
        
        $loop_id = Mojo::IOLoop->recurring($self->{sleep} => sub {
            if (my $url = shift @queue) {
                if ($fixed{$url}) {
                    return;
                }
                $fixed{$url}++;
                my $url_a = Mojo::URL->new($url);
                my $url_b = Mojo::URL->new($self->url_translate->($url_a->clone));
                my $res_a = $self->ua->get($url_a)->res;
                my $res_b = $self->ua->get($url_b)->res;
                if ($res_a->code ne $res_b->code) {
                    ok 0, "right http status code for $url_a";
                    return;
                }
                
                if ($res_a->headers->content_type =~ qr{^text/}) {
                    my $a = $self->preprocess_a->($res_a->body);
                    my $b = $self->preprocess_b->($res_b->body);
                    is diff(\"$a", \"$b"), '', "exact match for $url_a";
                } else {
                    is $res_a->body, $res_b->body, "exact match for $url_a";
                }
                
                if ($res_a->headers->content_type =~ qr{^text/html\b}) {
                    push(@queue, $self->collect_urls($url_a, $res_a->dom));
                    if ($self->shuffle) {
                        @queue = List::Util::shuffle @queue;
                    }
                }
            }
        });
        
        Mojo::IOLoop->start;
    }
    
    sub collect_urls {
        my ($self, $base, $dom) = @_;
        
        my $collection =
        $dom->find('script, link, a, img, area, embed, frame, iframe, input, meta[http\-equiv=Refresh]')->map(sub {
            my $dom = shift;
            if (my $href = $dom->{href} || $dom->{src} ||
                $dom->{content} && ($dom->{content} =~ qr{URL=(.+)}i)[0]) {
                my $url = Mojo::URL->new($href);
                
                if (! $url->path->trailing_slash) {
                    if ((${$url->path->parts}[-1] || '') =~ qr{\.(\w+)$}) {
                        my $ext = $1;
                        if (grep {$_ eq $ext} @{$self->extension_not}) {
                            return;
                        }
                    }
                }
                
                my $ret = $url->base($base)->fragment(undef)->to_abs->to_string;
                
                if ($ret !~ $self->url_match) {
                    return;
                }
                
                return $ret;
            }
        })->grep(sub{$_})->uniq;
        
        return @$collection;
    }

1;

__END__

=head1 NAME

CompBot - Compare a site with mirror

=head1 SYNOPSIS

    use CompBot;
    
    my $cbot = CompBot->new;
    $cbot->url_match(qr{dev.example.com});
    $cbot->url_translate(sub {
        my $url = shift;
        $url->host('example.com');
        return $url;
    });
    $cbot->start('http://dev.example.com/index.htm');

=head1 DESCRIPTION

This is a tool for comparing two websites. You can recursively compare the web
pages of two.

=head1 ATTRIBUTES

=head2 ua

Mojo::UserAgent instance.

=head2 preprocess_a

Can set code ref for pre-processing for response body of A.

=head2 preprocess_b

Can set code ref for pre-processing for response body of B.

=head2 url_translate

Generate B URL from A URL. The code gets Mojo::URL object and must
returns B URL.

    $cbot->url_translate(sub {
        my $url = shift;
        $url->host('example.com');
        return $url;
    });

=head2 shuffle

Shuffle the queue so that the tests are run random order.

=head2 sleep

Set the interval of HTTP requests in second.

=head2 url_match

Restrict target URL by regular expression. This is matched to A URL.

=head1 METHODS

=head2 CompBot->start

Start comparing.

    $cbot->start('http://dev.example.com/index.htm');

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
