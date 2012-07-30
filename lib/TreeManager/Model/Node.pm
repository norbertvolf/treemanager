package TreeManager::Model::Node;

use utf8;

use Mojo::Base 'Mojolicious::Cafe::Class';
use Scalar::Util qw(looks_like_number);
use TreeManager::Model::Node::List;

sub new {
	my ( $class, $c, $idnode ) = @_;
	my $pos  = 0;
	my $self = $class->SUPER::new(
		$c,
		{
			entity  => 'node',
			columns => {
				idnode     => { type => $c->DB_INT, required => 0, rule => 1, primary_key => 1, sequence => 'node_sequence', },
				idparent   => { type => $c->DB_INT, required => 0, rule => 1, },
				lval       => { type => $c->DB_INT, default  => 0, },
				rval       => { type => $c->DB_INT, default  => 0, },
				state      => { type => $c->DB_INT },
				stateuser  => { type => $c->DB_INT },
				statestamp => { type => $c->DB_DATE },
			},
		}
	);
	$self->idnode($idnode) if ( looks_like_number($idnode) );
	$self->load if ($idnode);
	return $self;
}

sub validate {
	my $self = shift;
	my $params = shift;
	my $ok = $self->SUPER::validate($params);
	if ( $ok ) {
		my $obj = TreeManager::Model::Node::List->new($self->c);
		$obj->validate( { filters => { idnode => { value => $self->idparent }, }, } );
		$obj->load;
		$obj->debug;
		if ( ! scalar(@{$obj->list}) ) {
			my $columns = $self->definition->{columns}->{idparent}->{invalid} = 1;
			$ok = undef;
		}
	}
	return($ok);
}

1;

