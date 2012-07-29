package TreeManager::Model::Node;

use utf8;

use Mojo::Base 'Mojolicious::Cafe::Class';
use Scalar::Util qw(looks_like_number);

sub new {
	my ( $class, $c, $idnode ) = @_;
	my $pos  = 0;
	my $self = $class->SUPER::new(
		$c,
		{
			title   => 'Node',
			entity  => 'node',
			columns => {
				idnode => {
					type        => $c->DB_INT,
					required    => 0,
					rule        => 1,
					primary_key => 1,
					sequence    => 'node_sequence',

				},
				idparent => {
					type     => $c->DB_INT,
					required => 0,
					rule     => 1,

				},
				lval => {
					type     => $c->DB_INT,
					required => 1,
					rule     => 1,

				},
				rval => {
					type     => $c->DB_INT,
					required => 1,
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

