package Mojolicious::Cafe::Plugin::User;

use Mojo::Base 'Mojolicious::Plugin';
use TreeManager::Model::User;

sub register {
	my ($self, $app) = @_;
	$app->helper(
		user => sub {
			my $c = shift; 
			$c->{_user} = TreeManager::Model::User->new($c, 1) if ( ! $c->{_user} );
			return($c->{_user});
		}
	);
}

1;
