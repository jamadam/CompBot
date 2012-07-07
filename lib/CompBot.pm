package CompBot;
use strict;
use warnings;
use lib 'lib';
use Mojo::UserAgent;
use Mojo::Base -base;
use Mojo::DOM;
use Mojo::IOLoop;
use Text::Diff;
use Test::More;
our $VERSION = '0.01';
    
    has ua => sub {Mojo::UserAgent->new};
    has preprocess_a => sub {sub {shift}};
    has preprocess_b => sub {sub {shift}};
    has 'url_translate';
    has queue => sub {[]};
    has sleep => '1';
    has 'url_match';
    
    sub start {
        my ($self, $url) = @_;
        
        push(@{$self->queue}, $url);
        
        my %fixed;
        my $loop_id;
        
        $loop_id = Mojo::IOLoop->recurring($self->{sleep} => sub {
            if (my $url = shift @{$self->queue}) {
                if ($fixed{$url}) {
                    return;
                }
                $fixed{$url}++;
                my $url_a = Mojo::URL->new($url);
                my $url_b = Mojo::URL->new($self->url_translate->($url_a->clone));
                my $res_a = $self->ua->get($url_a)->res;
                my $res_b = $self->ua->get($url_b)->res;
                if ($res_a->code ne $res_b->code) {
                    ok 0, "right http status code for $res_a";
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
                    push(@{$self->queue},
                        $self->collect_urls($url_a, $res_a->dom));
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
                $url->base($base)->fragment(undef)->to_abs->to_string;
            }
        })->grep(sub {
            $_ && $_ =~ $self->url_match;
        })->uniq;
        return @$collection;
    }

1;
