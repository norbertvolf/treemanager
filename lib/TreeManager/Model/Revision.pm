package TreeManager::Model::Revision;

use utf8;

use Mojo::Base 'Mojolicious::Cafe::Class';
use Scalar::Util qw(looks_like_number);

sub new {
	my ( $class, $c, $idnode ) = @_;
	my $pos  = 0;
	my $self = $class->SUPER::new(
		$c,
		{
			title   => 'Revision',
			entity  => 'treemanager.revision',
			columns => {
				idnode => {
					type        => $c->DB_INT,
					required    => 0,
					rule        => 1,
					primary_key => 1,
					sequence    => 'treemanager.idnode',

				},
				alldata => {
					type     => $c->DB_VARCHAR,
					required => 0,
					rule     => 1,

				},
				state => {
					type => $c->DB_INT,

				},
				stateuser => {
					type => $c->DB_INT,

				},
				statestamp => {
					type => $c->DB_DATE,

				},
			},
			autoloaders => {

				#				test => {
				#					class => 'Test::Item',
				#					params => {,
				#						iduser => sub { my $self = shift; return $self->iduser; },',
				#					},
				#				},
			},
		}
	);
	$self->idnode($idnode) if ( looks_like_number($idnode) );
	$self->load if ($idnode);
	return $self;
}

1;

