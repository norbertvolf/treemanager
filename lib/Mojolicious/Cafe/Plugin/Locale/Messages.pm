package Mojolicious::Cafe::Plugin::Locale::Messages;

use utf8;
use Mojo::Base 'Mojolicious::Plugin';
use Locale::Messages qw (:locale_h :libintl_h);
use Encode;

sub register {
	my ($self, $app) = @_;

	$app->helper(
		__ => sub {
			my $c = shift; 
			my $msgid = shift;
			$c->set_locale($c->user->locale);
			my $retval = decode('utf-8', gettext($msgid));
			$c->restore_locale($c->user->locale);
			return($retval);
		}
	);
}

1;
