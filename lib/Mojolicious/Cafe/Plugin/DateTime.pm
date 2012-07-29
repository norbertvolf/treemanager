package Mojolicious::Cafe::Plugin::DateTime;

use Mojo::Base 'Mojolicious::Plugin';
use DateTime;

#Return actuale time.
#If timezone is defined, return timezone based time
#If not use localtime from server
sub register {
	my ($self, $app) = @_;
	$app->helper( 
		cnow => sub {
			my ($self, $timezone) = @_;
			return( DateTime->from_epoch( epoch => time(), time_zone => ( $timezone // 'Europe/Prague') ) );
		}

	);
}

1;
