package TreeManager::Controller;

use Mojo::Base 'Mojolicious::Cafe::Controller';
use TreeManager::Model::Node::List;
use Encode;

#{{{ tree
sub tree {
	my $self = shift;
	if ( $self->req->method eq 'GET' ) {
		#Return JSON/HTML page with app
		if ( $self->req->headers->accept() && $self->req->headers->accept() =~ /application\/json/ ) {
			my $inst = TreeManager::Model::Node::List->new($self);
			my @arr = %{ $self->req->params->to_hash };

			#Convert GET query to JSON
			if ( scalar(@arr) ) {
				my $json = Mojo::JSON->new;
				my $hash = $json->decode( encode( 'utf8', $arr[0] ) );
				$inst->validate($hash);
			}
			$inst->load;
			my $hash = $inst->hash;
			$hash->{data}->{tree} = $inst->tree;
			$hash->{data}->{table} = $inst->table;
			$hash->{data}->{headerspan} = $inst->headerspan;
			return ( $self->render( json => $hash ) );
		}
		else {
			return( $self->render( template => 'tree' ) ); 
		}
	}
	return ( $self->render_not_found );
}

#}}}
#{{{ node
sub node {
	my $self = shift;
	if ( $self->req->method eq 'POST' && ref( $self->req->json ) eq 'HASH' ) {

		#Save data to database
		my $json = $self->req->json;
		my $node = TreeManager::Model::Node->new($self);
		if ( $node->validate($json) ) {
			$node->save;
			my $inst = TreeManager::Model::Node::List->new($self);
			$inst->load;
			my $hash = $inst->hash;
			$hash->{tree} = $inst->tree;
			$hash->{table} = $inst->table;
			$hash->{headerspan} = $inst->headerspan;
			$json = {
				data    => $hash,
				message => $self->__('Node has been added successfully.')
			};
		}
		else {
			$json = {
				data    => $node->hash,
				message => $self->__('Node data has not been add.'),
				errors  => $node->errors,
			};
		}
		return ( $self->render( json => $json ) );
	} elsif ( $self->req->method eq 'DELETE' && ref( $self->req->json ) eq 'HASH' ) {
		#Save data to database
		my $json = $self->req->json;
		my $node = TreeManager::Model::Node->new($self);
		if ( $node->validate($json) ) {
			$node->remove;
			my $inst = TreeManager::Model::Node::List->new($self);
			$inst->load;
			my $hash = $inst->hash;
			$hash->{tree} = $inst->tree;
			$hash->{table} = $inst->table;
			$hash->{headerspan} = $inst->headerspan;
			$json = {
				data    => $hash,
				message => $self->__('Node has been removed successfully.')
			};
		}
		return ( $self->render( json => $json ) );
	}
	return ( $self->render_not_found );
}

#}}}
#{{{ login
#Show page to login user
sub login {
	shift->render( template => 'login' );
}

#}}}
#{{{ logout
#Show page to logout user
sub logout {
	shift->render( template => 'logout' );
}

#}}}

1;
