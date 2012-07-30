package TreeManager;

use Mojo::Base 'Mojolicious';

#{{{ startup
#setup application
sub startup {
	my $self = shift;

	# Router
	my $r = $self->routes;

	#Set up GNU text
	$self->plugin('Mojolicious::Cafe::Plugin::Locale::Messages');

	#Set up authrization
	$self->plugin('Mojolicious::Cafe::Plugin::User');

	#Set up config
	$self->plugin( 'Config', { file => 'tree_manager.conf' } );

	#Set up secret
	$self->secret( $self->config->{secret} );

	#We are using DateTime class to work with times instead of Time::Piece
	#See helpers provided in plugin in in POD and source code
	$self->plugin('Mojolicious::Cafe::Plugin::DateTime');

	#Make sessions valid to end of user session
	$self->sessions->default_expiration(0);

	# Normal route to controller
	$r->get('/tree')->to('controller#tree');
	$r->route('/node')->to('controller#node');
	$r->route('/logout')->to('controller#logout');
	$r->route('/login')->to('controller#login');
}
#}}}
#{{{ validator
#Return set/get validators by class name
sub validator {
	my $self  = shift;
	my $class = shift;

	#class parameter is required
	Mojo::Exception->throw("\$class parameter missing") if ( !$class );

	#Create validator hash
	$self->{_validators} = {} if ( !ref( $self->{_validators} ) eq 'HASH' );

	#Initialize validator
	$self->{_validators}->{$class} = undef if ( !exists( $self->{_validators}->{$class} ) );

	#Set validator
	$self->{_validators}->{$class} = shift if ( !defined( $self->{_validators}->{$class} ) && scalar(@_) );

	return ( $self->{_validators}->{$class} );
}

#}}}

1;
