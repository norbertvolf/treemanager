package TreeManager::Model::Node::List;
use strict;
use warnings;
use base qw(Mojolicious::Cafe::List::View);
use TreeManager::Model::Node;

#{{{ new
sub new {
	my ( $class, $c ) = @_;
	my $self = $class->SUPER::new(
		$c,
		{
			query => q(
				SELECT
					idnode,
					idparent,
					lval,
					rval
					FROM node
					WHERE ( state & 4 ) = 0
					ORDER BY idnode
			),
			columns => { idnode => { type      => $c->DB_INT,          rule   => 1, }, },
			filters => { idnode => { condition => q(idnode = @idnode), column => 'idnode' }, },
		}
	);
	bless($self);
	$self->limit(undef);
	$self->{_table} = [];
	return $self;
}

#}}}
#{{{ tree
#Prepare tree structure to show them on client via jstree
sub tree {
	my $self     = shift;
	my $idparent = shift;
	my $deep     = ( shift // 0 );
	my $data     = [];
	$deep++;
	foreach my $row ( @{ $self->list } ) {
		if (   ( !defined($idparent) && !defined( $row->{idparent} ) )
			|| ( defined( $row->{idparent} ) && defined($idparent) && $row->{idparent} == $idparent ) )
		{
			my $children = $self->tree( $row->{idnode}, $deep );

			#Prepare colspan for table generation
			my $colspan = 1;
			if ( scalar( @{$children} ) ) {
				$colspan = 0;
				map { $colspan += $_->{data}->{attr}->{colspan}; } @{$children};
			}
			my $hash = {
				data => {
					title => $row->{idnode},
					attr  => {
						colspan  => $colspan,
						idparent => $row->{idparent},
						deep     => $deep,
						title    => $self->c->__('Node') . ': ' . $row->{idnode},
						idnode   => $row->{idnode},
					},
				},
				children => $children,
			};
			push( @{$data},                            $hash );
			push( @{ $self->{_table}->[ $deep - 1 ] }, $hash );
		}
	}
	return ($data);
}

#}}}
#{{{ table
#Prepare tree structure to show them on client via jstree
sub table {
	my $self = shift;
	if ( !$self->{__table} ) {
		$self->{_table} = [];
		$self->tree;

		#Normalize table
		for ( my $i = 1 ; $i < scalar( @{ $self->{_table} } ) ; $i++ ) {
			my @newrow;
			my $k = 0;    #Counter for original row
			for ( my $j = 0 ; $j < scalar( @{ $self->{_table}->[ $i - 1 ] } ) ; $j++ ) {
				if ( scalar( @{ $self->{_table}->[ $i - 1 ]->[$j]->{children} } ) == 0 ) {
					push(
						@newrow,
						{
							data => {
								title => undef,
								attr  => {
									colspan  => 1,
									idparent => undef,
									deep     => $i + 1,
									title    => undef,
									idnode   => undef,
								},
							},
							children => [],
						}
					);
				}
				else {
					push( @newrow, @{ $self->{_table}->[ $i - 1 ]->[$j]->{children} } );
				}
			}
			$self->{_table}->[$i] = \@newrow;
		}
		$self->{__table} = $self->{_table};
	}
	return ( $self->{__table} );
}

#}}}
#{{{ headerspan
#Return span of headers
sub headerspan {
	my $self = shift;
	my $span = 0;
	map { $span += $_->{data}->{attr}->{colspan}; } @{ $self->table->[0] } if ( scalar( @{ $self->list } ) );
	return ( $span || 1 );
}

#}}}
#{{{ recalculate
#Recalculate lval/rval on tree for futuer usage
sub recalculate {
	my $self = shift;
}

#}}}

1;
