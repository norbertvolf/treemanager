package Mojolicious::Cafe::SQL::Query;

use Mojo::Base 'Mojo::Base';


has 'columns';
has 'from_clause';
has 'where_clause';
has 'groupby_clause';
has 'orderby_clause';
has 'limit_clause';

#{{{ new
#Create new instance of Mojolicious::Cafe::Listing
sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	$self->query(shift);
	return($self);
}
#}}}
#{{{ parameters
#Return parameters from query
sub parameters {
	my $self = shift;
	my $query = $self->query;
	my @parameters;
	while ( $query =~ s/@(\w+)/?/ ) {
		push(@parameters, $1);
	}
	return(@parameters);
}
#}}}

#{{{ query
#Query setter/getter 
sub query {
	my $self = shift;
	if ( scalar(@_) ) {
		$self->{_query} = shift;
		$self->parse();
		$self->{_orig_where_clause} = $self->where_clause;
	}
	#Generate query from clauses
	my @query;
	push(@query, 'SELECT', $self->columns, 'FROM',  $self->from_clause);
	if ( $self->where_clause ) {
		push(@query, 'WHERE', $self->where_clause, );
	}
	if ( $self->groupby_clause ) {
		push(@query, 'GROUP BY', $self->groupby_clause, ) 
	}
	if ( $self->orderby_clause ) {
		push(@query, 'ORDER BY', $self->orderby_clause, );
	}
	if ( $self->limit_clause ) {
		push(@query, 'LIMIT', $self->limit_clause, );
	}
	return(join(' ', @query));
}
#}}}
#{{{ fullfeatured
#Alias for query 
sub fullfeatured {
	my $self = shift;
	return($self->query);
}
#}}}
#{{{ pretty
#Return formatted query
sub pretty {
	my $self = shift;
	my $indent = shift // "";
	#Generate query from clauses
	my @query;
	push(@query, $indent . "SELECT", $self->columns);

	my $from_clause = $self->from_clause;
	$from_clause =~ s/(LEFT JOIN|RIGHT JOIN|CROSS JOIN|INNER JOIN|JOIN)/\n$indent\t\t$1/g;
	push(@query, "\n$indent\tFROM",  $from_clause);
	if ( $self->where_clause ) {
		my $where_clause = $self->where_clause;
		$where_clause =~ s/(AND)/\n$indent\t\t$1/g;
		push(@query, "\n$indent\tWHERE", $where_clause );
	}
	if ( $self->groupby_clause ) {
		push(@query, "\n$indent\tGROUP BY", $self->groupby_clause, ) 
	}
	if ( $self->orderby_clause ) {
		push(@query, "\n$indent\tORDER BY", $self->orderby_clause, );
	}
	if ( $self->limit_clause ) {
		push(@query, "\n$indent\tLIMIT", $self->limit_clause, );
	}
	return(join(' ', @query));
}
#}}}
#{{{ placeholdered
#Return query where variables are converted to to placeholders
sub placeholdered {
	my $self = shift;
	my $query = $self->query;
	$query =~ s/@\w+/?/g;
	return($query);
}
#}}}
#{{{ orig_where_clause
#Return original where clause to combine where clause from query and 
#dynamically prepare where clause
sub orig_where_clause {
	return(shift->{_orig_where_clause});
}
#}}}

#{{{ private parse
#Parse query and fill clause attributes
sub parse {
	my $self = shift;
	my $str = $self->cleanupquery($self->{_query});
	$str =~ s/^SELECT (.+)$/$1/i;
	if ( $str =~ s/^(.+) LIMIT (.+)$/$1/i ) { 
		$self->limit_clause($2 // ''); 
	}
	if ( $str =~ s/^(.+) ORDER BY (.+)$/$1/i ) { 
		$self->orderby_clause($2 // ''); 
	}
	if ( $str =~ s/^(.+) GROUP BY (.+)$/$1/i ) { 
		$self->groupby_clause($2 // ''); 
	}
	if ( $str =~ s/^(.+?) WHERE (.+)$/$1/i ) { 
		$self->where_clause($2 // ''); 
	}
	if ( $str =~ s/^(.+?) FROM (.+)$/$1/i ) { 
		$self->from_clause($2 // ''); 
	}
	$self->columns($str);
}
#}}}
#{{{ private cleanupquery
#Remove all EOLs and whitespace chains
sub cleanupquery {
	my $self = shift;
	my $str = shift;
	$str =~ s/--[^\n]+\n/ /g;
	$str =~ s/\n/ /g;
	$str =~ s/^\s+//;
	$str =~ s/\s+/ /g;
	return($str);
}
#}}}
1;

__END__

=head1 NAME

Mojolicious::Cafe::SQL::Query - 'parse' SQL query. Provide utilities for 
Mojolicious::Cafe::List* classes SQL query .

=head1 CLAUSES

=head2 columns

Return column clause (list of columns passed after SELECT keyword)

=head2 from_clause

Return FROM clause

=head2 where_clause

Return WHERE clause

=head2 groupby_clause

Return GROUP BY clause

=head2 orderby_clause

Return ORDER BY clause

=head2 limit_clause

Return LIMIT/OFFSET clause

=head1 METHODS

Mojolicious::Cafe::SQL::Query inherites all methods from Mojo::Base 
and implements the following new ones.

=head2 parse

B<parse> divide the query to clauses.
