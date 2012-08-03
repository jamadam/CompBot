use strict;
use warnings;
use utf8;
use FindBin;
use File::Basename 'dirname';
use File::Spec;
use lib join '/', File::Spec->splitdir(File::Spec->rel2abs(dirname(__FILE__))), '../lib';
use lib join '/', File::Spec->splitdir(File::Spec->rel2abs(dirname(__FILE__))), 'lib';
use Test::More;
use Mojo::DOM;
use Mojo::URL;

use Test::More tests => 45;

use CompBot;

my $base = Mojo::URL->new('http://example.com/base/');
my @urls;

@urls = CompBot->collect_urls($base, Mojo::DOM->new(<<EOF));
<a href="/test/"></a>
EOF

is_deeply \@urls, ['http://example.com/test/'];

@urls = CompBot->collect_urls($base, Mojo::DOM->new(<<EOF));
<a href="./test/"></a>
EOF

is_deeply \@urls, ['http://example.com/base/test/'];

@urls = CompBot->collect_urls($base, Mojo::DOM->new(<<EOF));
<a href="test/"></a>
EOF

is_deeply \@urls, ['http://example.com/base/test/'];

@urls = CompBot->collect_urls($base, Mojo::DOM->new(<<EOF));
<a href="../"></a>
EOF

is_deeply \@urls, ['http://example.com/'];

@urls = CompBot->collect_urls($base, Mojo::DOM->new(<<EOF));
<a href="./"></a>
EOF

is_deeply \@urls, ['http://example.com/base/'];



__END__
