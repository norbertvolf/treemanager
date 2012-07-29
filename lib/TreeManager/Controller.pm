package TreeManager::Controller;

use Mojo::Base 'Mojolicious::Cafe::Controller';

#{{{ tree
sub tree {
	my $self = shift;
	$self->render(template => 'tree'); 
}
#}}}
#{{{ login
#Show page to login user
sub login {
	shift->render(template => 'login'); 
}
#}}}
#{{{ logout
#Show page to logout user
sub logout { 
	shift->render(template => 'logout'); 
}
#}}}

1;
