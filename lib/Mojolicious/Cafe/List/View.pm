package Mojolicious::Cafe::List::View;

use Mojo::Base 'Mojolicious::Cafe::List';
use DBD::Pg qw(:pg_types);
use Scalar::Util qw(looks_like_number);
use Encode;

use constant DEFAULT_LIMIT => 20;
use constant DEFAULT_OFFSET => 0;

#{{{ new
#Create new instance of Mojolicious::Cafe::Listing
sub new {
	my $class = shift;
	my $c = shift;
	my $definition = shift;
	my $self = $class->SUPER::new($c, $definition);
	#Restore limit from session
	$self->limit(DEFAULT_LIMIT);
	#Restore offset from session
	$self->offset(DEFAULT_OFFSET);
	return($self);
}
#}}}
#{{{check
#Check definiton, passed as paramaters
sub check {
	my $self = shift;
	my $def = shift;
	#Check tests from base
	$self->SUPER::check($def);
	#Is ordering valid HASH
	if ( exists($def->{ordering}) && ! ( ref($def->{ordering}) eq 'HASH' )  ) {
		Mojo::Exception->throw('"ordering" value in definition is not HASH in class ' . ref($self) . '.');
		#Zkontolovat, ze neexistuje column ordering
		Mojo::Exception->throw('"ordering" is not valid column name in class ' . ref($self) . '.') if ( exists($def->{columns}->{ordering}) );
	}
	#Is filters valid HASH
	if ( exists($def->{filters}) && ! ( ref($def->{filters}) eq 'HASH' )  ) {
		Mojo::Exception->throw('"filters" value in definition is not HASH in class ' . ref($self) . '.');
		#Zkontolovat, ze neexistuje column filters
		Mojo::Exception->throw('"filters" is not valid column name.') if ( exists($def->{columns}->{filters}) );
		#Kontrolovat, ze hodnoty klice column existuji v columns definici
		foreach my $key ( keys(%{$def->{filters}}) ) {
			if ( exists($def->{filters}->{$key}->{column}) && ! exists($def->{columns}->{$def->{filters}->{$key}->{column}}) ) {
				Mojo::Exception->throw("\"$def->{filters}->{$key}->{column}\" column from filter definition  is not valid column name from columns definitions in class " . ref($self) . '.');
			}
			if ( ! exists($def->{filters}->{$key}->{condition})  ) {
				Mojo::Exception->throw("\"$key\" filter definition does not contains mandatory directive \"condition\" in class " . ref($self) . '.');
			}
		}
	}
	return($def);
}
#}}}
#{{{ validate
#Overload Mojolicious::Cafe::Base::validate to keep session columns
sub validate {
	my $self = shift;
	my $params = shift;
	#Validate parameter limit from client
	$self->limit($1) if ( $params->{limit} && $params->{limit} =~ /(\d+)/ );
	#Validate parameter offset from client
	$self->offset($1) if ( $params->{offset} && $params->{offset} =~ /(\d+)/ );
	#Validate ordering
	$self->ordering($params->{ordering});
	#Validate filtering
	if ( ref($params->{filters}) eq 'HASH') {
		my %filters;
		my %columns;
		foreach my $key ( keys(%{$params->{filters}}) ) {
			#If filter key exists in definition create item for WHERE clause
			if ( ref($params->{filters}->{$key}) eq 'HASH'  &&  exists($self->definition->{filters}) && exists($self->definition->{filters}->{$key}) ) {
				if ( exists($self->definition->{filters}->{$key}->{column} )  ) {
					$columns{$self->definition->{filters}->{$key}->{column}} = $params->{filters}->{$key}->{value};
				}
				$filters{$key} = $self->definition->{filters}->{$key};
			} elsif ( ref($params->{filters}->{$key}) eq 'HASH'  &&  ! exists($self->definition->{filters}->{$key}) ) {
				$self->c->app->log->warn(qq(You have send filter request "$key" without filter definition in class ) . ref($self) . '.');
			} elsif ( ! ref($params->{filters}->{$key}) eq 'HASH' ) {
				$self->c->app->log->warn(qq(You have send filter request without valid filter definition filter value must be hash.) . ref($self) . '.');
			}
		} 
		$self->{_filters} = \%filters;
		#Combine columns from filters and params from client to pass params for parent validation
		@{$params}{keys %columns} = values %columns;
		
	}
	my $retval = $self->SUPER::validate($params);
	return($retval);
}
#}}}
#{{{ query
#Overwrite getter for query from parent to 
#generate dynamic WHERE and ORDER BY clause
sub query {
	my $self = shift;

	my $query = $self->SUPER::query(@_);
	#Add always filters
	foreach my $key ( keys(%{$self->definition->{filters}}) ) {
		my $definition = $self->definition->{filters}->{$key};
		if ( 
			! exists($self->{_filters}->{$key}) && 
			$definition->{always} 
		) {
			$self->{_filters}->{$key} = $definition 
		}
	}

	#Rich WHERE clause by dynamic content
	if ( 
		exists($self->{_filters}) && 
		ref($self->{_filters}) eq 'HASH' && 
		scalar(keys(%{$self->{_filters}}))
	) {
		#Rich WHERE clause in query
		my @where = map { "( $self->{_filters}->{$_}->{condition} )" } grep { exists($self->{_filters}->{$_}->{condition}) } keys(%{$self->{_filters}});
		#Add original where 
		CORE::push(@where, $query->orig_where_clause) if ($query->orig_where_clause);
		$query->where_clause( join (' AND ', @where) );

	}

	#Overwrite ORDER BY clause by dynamic content
	if ( 
		exists($self->{_ordering}) && 
		ref($self->{_ordering}) eq 'ARRAY' && 
		scalar(@{$self->{_ordering}}) 
	) {
		#Overwrite ORDER BY in query
		$query->orderby_clause( join (',', @{$self->{_ordering}}) );
	}

	#And return query
	return($query);
}
#}}}
#{{{ ordering
#Ordering setter
#generate dynamic ORDER BY clause
sub ordering {
	my $self = shift;
	my $ordering = shift;
	if ( ref($ordering) eq 'ARRAY') {
		my @ordering;
		foreach my $order ( @{$ordering} ) {
			#If order key exists in definition create item for ORDER BY clause
			if ( ref($order) eq 'HASH' &&  exists($self->definition->{ordering}) && scalar(grep { $order->{key} eq $_ } keys(%{$self->definition->{ordering}})) ) {
				if ( $order->{how} =~ /desc/i ) {
					push(@ordering, $self->definition->{ordering}->{$order->{key}} . ' DESC');
				} else {
					push(@ordering, $self->definition->{ordering}->{$order->{key}} . ' ASC');
				}
			} elsif ( ref($order) eq 'HASH' && ! exists($self->definition->{ordering}) ) {
				$self->c->app->log->warn('You have send ordering request without ordering definition in class ' . ref($self) . '.');
			}
		}
		$self->{_ordering} = \@ordering;
	}
}
#}}}
#{{{ tmp
#return
sub tmp {
	my $self = shift;

	$self->c->tmp->{ref($self)} = {} if ( ! $self->c->tmp->{ref($self)} );
	return($self->c->tmp->{ref($self)});
}
#}}}

1;

__END__

=head1 NAME

Mojolicious::Cafe::List::View - extend Mojolicious::Cafe::List for user
interaction

=head1 DIRECTIVES

Mojolicious::Cafe::Listing inherites all directivs from Mojolicious::Cafe::Base
and implements the following new ones.

=head2 ordering

If B<ordering> is hash. Keys define possible ordering items and values are SQL
pieces

	ordering => {
		idbanner => 'b.idbanner',
		title => 'title',
		statestamp => 'b.statestamp',
		tabsnum => 'b.tabsnum',
	},      

=head2 filters

If B<filters> is hash. Keys define possible filters and values defines SQL 
pieces

   filters => {    
      idterritory => { condition => 'idfoo = @idfoo', column => 'idfoo' },
      state => { condition => 'b.state & 4 = 0', always => 1 },
   },

=head1 METHODS

Mojolicious::Cafe::Listing inherites all methods from Mojolicious::Cafe::Base
and implements the following new ones.

=head2 tmp

B<tmp> return temporary hash to keep values in session structure. The tmp hash
is uniques per class (not per instance).
Internally is set default values from session for filters.

C<$self->tmp->{key} = 100;>
C<my $value = $self->tmp->{key};>

=head2 validate

B<validate> is based on parent validate method and try to validate ordering, 
filters, limit and offset parameters. Default values are difined by constants 
DEFAULT_LIMIT and DEFAULT_OFFSET.

=head2 ordering

B<ordering> is used to set ordering 

=head2 query

B<query> is overwritten method from parent class. Generate SQL query with 
ORDER BY and WHERE clauser from ordering and filters.


=head2 check

B<check> is overwritten method from parent class. Check definition from the 
class point of view. Add checking of filter and ordering directive.
