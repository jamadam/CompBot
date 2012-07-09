=head1 NAME

CompBot - Compare a site with mirror

=head1 SYNOPSIS

    use CompBot;
    
    my $sd = CompBot->new;
    $sd->url_match(qr{dev.example.com});
    $sd->url_translate(sub {
        my $url = shift;
        $url->host('example.com');
        return $url;
    });
    $sd->start('http://dev.example.com/index.htm');

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

    $sd->url_translate(sub {
        my $url = shift;
        $url->host('example.com');
        return $url;
    });

=head2 sleep

Set the interval of HTTP requests in second.

=head2 url_match

Restrict target URL by regular expression. This is matched to A URL.

=head1 METHODS

=head2 CompBot->start

Start comparing.

    $sd->start('http://dev.example.com/index.htm');

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
