package Mojolicious::Cafe::Controller;

use utf8;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Exception;
use DBI;
use POSIX qw(strftime locale_h setlocale LC_ALL);

#{{{ dbh
#Return instance of DBI class. The class
#is used as interface between database
#and application. The instance
sub dbh {
	my $self = shift;
	my %params = @_ if ( scalar(@_) && ( scalar(@_) % 2 ) == 0 );

	if ( !exists( $self->app->{_dbh} ) ) {
		$self->app->log->warn("Connecting to database...");
		$self->app->{_dbh} =
		  DBI->connect( $self->config->{dbi_dsn}, $self->config->{dbi_user}, $self->config->{dbi_pass}, $self->config->{dbi_attr} );
	}
	else {
		my $ping = $self->app->{_dbh}->ping;
		if ( !$ping ) {
			$self->app->log->warn("Database connection has disconnected. Trying to reconnect...");
			$self->app->{_dbh}->disconnect;
			$self->app->{_dbh} =
			  DBI->connect( $self->config->{dbi_dsn}, $self->config->{dbi_user}, $self->config->{dbi_pass}, $self->config->{dbi_attr} );
		}
		elsif ( $params{check} && $ping > 1 ) {
			$self->app->log->warn('Database connection is dirty. Cleanup..');
			$self->app->{_dbh}->disconnect;
			$self->app->{_dbh} =
			  DBI->connect( $self->config->{dbi_dsn}, $self->config->{dbi_user}, $self->config->{dbi_pass}, $self->config->{dbi_attr} );
		}
	}
	return ( $self->app->{_dbh} );
}

#}}}
#{{{ restore_locale
#Restore_locale locale from LIFO
sub restore_locale {
	my ($self) = shift;

	$self->{_local_locale} = [] if ( !defined( $self->{_local_locale} ) );
	if ( scalar( @{ $self->{_local_locale} } ) ) {
		my $locale = pop( @{ $self->{_local_locale} } );
		if ($locale) {
			$ENV{LANG} = $locale;    #For TextDomain we mu set LANG also
			$ENV{LANGUAGE} = $locale;    #For TextDomain we mu set LANG also
			setlocale( LC_ALL, $locale );
			my $foo = setlocale(LC_ALL);
		}
	}
	else {
		Mojo::Exception->throw("Locale array is empty, when I want restore locale.");
	}
}

#}}}
#{{{ set_locale
#Set locale and save original locale to LIFO
sub set_locale {
	my $self   = shift;
	my $locale = shift;
	my $orig;

	#As first local we must use "C" instead of locally defined
	if ( !exists( $self->{_begin} ) ) {
		$self->{_begin} = 1;
		$orig = "C";
	}
	else {
		$orig = setlocale(LC_ALL);
	}

	#Set new locale
	$locale = "C" unless ($locale);
	$ENV{LANG} = $locale;    #For TextDomain we mu set LANG also
	$ENV{LANGUAGE} = $locale;    #For TextDomain we mu set LANG also
	setlocale( LC_ALL, $locale );

	#Keep previous locale for reset
	$self->{_local_locale} = [] if ( !$self->{_local_locale} );
	push( @{ $self->{_local_locale} }, $orig );
}

#}}}
#{{{ constants
#Redefine Cafe::Class constants as methods
sub DB_VARCHAR { return (0); }
sub DB_INT     { return (1); }
sub DB_DATE    { return (2); }
sub DB_NUMERIC { return (3); }
sub DB_INT8    { return (6); }
sub CAFE_TTL   { return (300); }
sub OK         { return (1); }
sub NOK        { return (0); }
sub NEXT       { return (1); }
sub PREV       { return (2); }
sub LAST       { return (3); }
sub FIRST      { return (4); }
sub PAGE       { return (5); }
sub PAGESIZE   { return (20); }

#}}}
#{{{ caller
#Return string with caller
sub caller {
	my $self = shift;
	my @stack;
	my ( $package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash );
	my ( $prevline, $prevfilename );
	my $i = 0;
	( $package, $prevfilename, $prevline, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash ) =
	  caller( $i++ );
	do {
		( $package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash ) =
		  caller( $i++ );
		$subroutine = ( $package . $subroutine ) if ( $subroutine && $subroutine eq '(eval)' );
		push( @stack, "($i) $subroutine:$prevline ($prevfilename)" ) if ($subroutine);
		( $prevfilename, $prevline ) = ( $filename, $line );
	} while ( $subroutine && $i < 5 );
	return ( "\n" . join( "\n", @stack ) . "\n...\n" );
}

#}}}

1;

__END__
#{{{ pod
=head1 NAME

Mojolicious::Cafe::Controller - controller

=head1 METHODS

L<Mojolicious::Cafe::Controller> inherits all methods from L<Mojolicious::Controllers> and 
implements the following new ones.

=head2 C<dbh>

  my $sth = $app->dbh->prepare(q(SELECT * FROM table));

Return DBI object for communicat with database. Database handlers
is depend on virtual host.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>. L<https://caramel.bata.eu/foswiki/bin/view/>.

=cut
#}}}
