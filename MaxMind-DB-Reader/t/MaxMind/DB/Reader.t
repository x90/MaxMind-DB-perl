use strict;
use warnings;

use MaxMind::DB::Reader;
use Test::More;

my $geoip2 = MaxMind::DB::Reader->new;

my $host       = 'www.maxmind.com';
my $ip_address = $geoip2->_resolve_hostname( $host );
is( $ip_address, '174.36.207.186', "returns correct ip for $host" );

done_testing();
