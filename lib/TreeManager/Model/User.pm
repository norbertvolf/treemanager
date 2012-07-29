package TreeManager::Model::User;

use utf8;

use Mojo::Base 'Mojolicious::Cafe::Class';
use Scalar::Util qw(looks_like_number);

has locale => 'cs_CZ.UTF-8';
has lang => 'cs';

sub new {
	my ($class, $c, $iduser) = @_;
	my $pos = 0;
	my $self = $class->SUPER::new(
		$c, 
		{
			entity => 'user',
			columns => {
				iduser => {
					type => $c->DB_INT,
					required => 0,
					rule => 1,
					primary_key => 1,
					sequence => 'treemanager.iduser',

				},
				username => {
					type => $c->DB_VARCHAR,
					required => 0,
					rule => 1,

				},
			},
		}
	); 
	$self->iduser($iduser) if ( looks_like_number($iduser) );
	$self->load if ( $iduser );	
	return $self;
}

1;

