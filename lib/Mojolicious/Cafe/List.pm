package Mojolicious::Cafe::List;

use Mojo::Base 'Mojolicious::Cafe::Base';
use DBD::Pg qw(:pg_types);
use Scalar::Util qw(looks_like_number);
use Mojolicious::Cafe::SQL::Query;
use Encode;
use DateTime;


has 'limit';
has 'offset';

#{{{ new
#Create new instance of Mojolicious::Cafe::Listing
sub new {
	my $class = shift;
	my $c = shift;
	my $definition = shift;
	my $self = $class->SUPER::new($c, $definition);

	#Initialize list as empty refarray
	$self->list([]);

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
	#Exists primary key 
	Mojo::Exception->throw("Not defined query.") if ( ! defined($def->{query}) );
	return($def);
}
#}}}
#{{{ load
#Load persistent data from databases by query defined
#in class.
sub load {
	my ($self, $force) = @_;
	if ( ! $self->loaded || $force ) {
		$self->c->app->log->debug("Query (" . ref($self) . "):\n" . $self->query->pretty("\t") );
		my $sth = $self->dbh->prepare($self->query_compiled, { pg_server_prepare => 0 });
		my $start;
		if ( $self->c->app->mode eq 'development' ) {
			$start = Time::HiRes::gettimeofday();
		}
		$sth->execute($self->query_params());
		if ( $self->c->app->mode eq 'development' ) {
			my $end = Time::HiRes::gettimeofday();
			$self->c->app->log->debug("Execution time: " . sprintf("%.2f ms (" . ref($self) . ")\n", ($end - $start) * 1000 ));
		}
		$self->list($sth->fetchall_arrayref({}));
		#Normalize rows
		foreach my $r ( $self->list ) {
			#Convert timestamp from databaze to Datetime
			map { $r->{$_} = $self->func_parse_pg_date($r->{$_}); } map { $_->{key} } grep { $_->{type} == $self->c->DB_DATE } $self->columns;
			map { 
				$r->{$_} = Encode::is_utf8($r->{$_}) ? $r->{$_} : decode("utf-8", $r->{$_}); 
			} map { $_->{key} } grep { $_->{type} == $self->c->DB_VARCHAR } $self->columns;
		}
	}
	return($self->list);
}
#}}}
#{{{ list
#Getter/setter for list of records
sub list {
	my $self = shift;
	if ( scalar(@_) ) {
		$self->{_list} = shift;
		Mojo::Exception->throw("List is not array reference.") if ( ! ref($self->{_list}) eq 'ARRAY' ); 
	}
	return(wantarray ? @{$self->{_list}} : $self->{_list});
}
#}}}
#{{{ query
#Getter for query
sub query {
	my $self = shift;
	if ( ! $self->{_query} ) {
		$self->{_query} = Mojolicious::Cafe::SQL::Query->new($self->definition->{query});
	}
	return($self->{_query});
}
#}}}
#{{{ push
#add new value to list 
sub push {
	my $self = shift;
	Mojo::Exception->throw("You must pass some value to push them to the list.") if ( ! scalar(@_) ); 
	push( @{$self->{_list}}, shift);
}
#}}}
#{{{ hash
#Returns formated values by hash based on definition of columns
sub hash {
	my ($self, $unlocalized) = @_;
	my $data = $self->SUPER::hash;
	my @list = map {
		my $val;
		if ( ref($_) eq "HASH") {
			$val = $_;
			#Use user defined formating function
			foreach my $key ( map { $_->{key} } grep { $_->{format} } $self->columns ) {
				$val->{$key} = &{$self->definition->{columns}->{$key}->{format}}($val->{$key});
			}
			#Convert timestamps to locale date format
			foreach my $key ( map { $_->{key} } grep { $_->{type} == $self->c->DB_DATE && ! exists($_->{format}) } $self->columns ) {
				$val->{$key} = defined($val->{$key}) ? $val->{$key}->strftime("%x") : undef ;
			}
		} elsif ( ref($_) eq "ARRAY") {
			$val = $_;
		} elsif ( ! ( ref($_) eq "" ) ) {
			$val = $_->hash;
		}
		$val;
	} $self->list;
	$data->{list} =  \@list;
	return($data);
}
#}}}
#{{{ dump
#Return string with dumped data
sub dump {
	my $self = shift;
	my $dump = "\n" . $self->SUPER::dump . "\n\nlist = [\n";
	foreach my $r (  $self->list ) { 
		my $part = '';
		if ( ref($r) && ( ref($r) eq 'HASH' || ref($r) eq 'ARRAY' || ref($r) eq 'SCALAR') ) {
			$part = $self->c->app->dumper($r) . "\n";
		} elsif( ref($r) ) {
			$part = $r->dump . "\n";
		}
		$part =~ s/^/  /mg;
		$dump .= $part;
	}
	$dump .= "]\n\n";
	return($dump);
}
#}}}
#{{{ search
#Return array with items corresponding, with parameters 
#passed as hash
#ex.: $self->search(articlenumber => '3334422')
sub search {
	my $self = shift;
	my %hash = @_;
	my $equals = 0;
	my @arr;

	foreach my $r (  $self->list ) {
		if ( ref($r) eq 'HASH' ) {
			$equals = grep { ( ( defined($r->{$_}) &&  defined($hash{$_}) && $r->{$_} eq $hash{$_} ) || ( ! defined($r->{$_}) &&  ! defined($hash{$_}) ) ) } keys(%hash);
		} else {
			$equals = grep { ( ( defined($r->$_) &&  defined($hash{$_}) && $r->$_ eq $hash{$_} ) || ( ! defined($r->$_) &&  ! defined($hash{$_}) ) ) } keys(%hash);
		}
		CORE::push(@arr, $r) if ( $equals == scalar(keys(%hash)) );
	}
	return(@arr);
}
#}}}

#{{{ private query_compiled
#Remove parameters and dynamically used SQL keywords
#from query
sub query_compiled {
	my $self = shift;

	#Add limit and offset
	if ( defined($self->limit) && looks_like_number($self->limit) ) {
		my $limit_clause = $self->limit;
		$limit_clause = join(' ', $self->limit, "OFFSET", $self->offset) if ( defined($self->offset) && looks_like_number($self->offset) );
		$self->query->limit_clause($limit_clause);

	}
	return($self->query->placeholdered);
}
#}}}
#{{{ private query_params
#Prepare params for compiled query 
sub query_params {
	my $self = shift;
	my @params = map { $self->$_ } $self->query->parameters;	
	$self->c->app->log->debug("Query parameters: " . join(', ', map { (defined($_) ? qq("$_") : "NULL") } @params) . ".") if ( scalar(@params) ); 
	return(@params);
}
#}}}

1;

__END__

=head1 NAME

Mojolicious::Cafe::Base - base class to build Postgresql Web applications


=head1 DIRECTIVES

Mojolicious::Cafe::Listing inherites all directivs from Mojolicious::Cafe::Base and implements the following new ones.

=head2 format

B<format> is anonymous function to re

C<format =E<gt> sub { my $value = shift; return( sprintf('%03d', $value) ) }>
