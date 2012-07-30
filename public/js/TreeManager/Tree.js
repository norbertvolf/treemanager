//core
// {{{ constructor
// Initialize tree
TreeManager.Tree = function(block) {
	this.jQuery = jQuery;
	this.block = this.jQuery('#treemanager-container');
	this.find('.tree-manager-button-add').click(this.add.bind(this));
	this.requesttree();
};
// }}}
//{{{ find
TreeManager.Tree.prototype.find = function(selector) {
	return(this.block.find(selector));
};
//}}}
// {{{ data
// prepare JSON structure of node
TreeManager.Tree.prototype.data = function() {

	var data = {};
	data.idnode = null;
	data.idparent = this.find('.tree-manager-input-idnode').val();

	if ( TreeManager.isNumber(data.idparent) || data.idparent.match(/NONE/) ) {
		return(data);
	} else {
		TreeManager.publish('Message.Err', [ TreeManager.__('The parent have to be integer or "NONE" for root nodes.') ]);
		return(null);
	}
}
//}}}

//fillers
//{{{ filltree 
//Send request to create new node 
TreeManager.Tree.prototype.filltree = function( result ) {
	if ( result.errors && result.errors.length > 0 ) {
		var message = [ result.message ];
		for(var i = 0; i < result.errors.length; i++ ) {
			message.push(result.errors[i].error );
		}
		TreeManager.publish('Message.Err', [ message.join(" ") ] );
	} else {
		this.find('.treemanager-tree-header-nodes').attr('colspan', result.data.headerspan);
		this.find('.treemanager-tree-body').empty();
		for(var i = 0; i < result.data.table.length; i++ ) {
			var tr = this.find('.treemanager-tree-row-template').clone().removeClass('treemanager-tree-row-template display-no').empty();
			var row = result.data.table[i];
			var td = this.find('.treemanager-tree-column-template').clone().removeClass('treemanager-tree-column-template display-no').text((i + 1 ) + ".");
			tr.append(td);
			for(var j = 0; j < row.length; j++ ) {
				var td = this.find('.treemanager-tree-column-template').clone().removeClass('treemanager-tree-column-template display-no');
				tr.append(td);
				if ( row[j].data.title ) {
					td.html( ( row[j].data.attr.idparent || 'NONE') + '&nbsp;<img src="/images/ico-arrow-right.gif">&nbsp;' + row[j].data.attr.idnode );
				} else {
					td.html( '&nbsp;' );
				}
				td.attr('colspan', row[j].data.attr.colspan );
				tr.append(td);
			}
			this.find('.treemanager-tree-body').append(tr);
		}

	}
}
//}}} 

//requestors
//{{{ requestadd 
//Send request to create new node 
TreeManager.Tree.prototype.requestadd = function() {
	if ( this.data() ) {
		TreeManager.publish('Message.Close');
		var error = function error(state) { TreeManager.publish('Message.Err.HTTP', [ state ]); };
		TreeManager.request({
				url: '/node/',
				type: 'POST',
				data: TreeManager.stringify(this.data()),
			},
			this.filltree.bind(this),
			error.bind(this)
		);
	}
}
//}}} 
/* {{{ requesttree */
/* Send request to load tree */
TreeManager.Tree.prototype.requesttree = function( value ) {
	var data = {
		'limit' : null,
		'offset' : null
	};
	var error = function error(state) { TreeManager.publish('Message.Err.HTTP', [ state ]); };
	TreeManager.request({
			url: "/tree/",
			data: encodeURI(TreeManager.stringify(data)),
			type: 'GET'
		},
		this.filltree.bind(this),
		error.bind(this)
	);
};
/* }}} */

//handlers
// {{{ handlers
// Send request to save node
TreeManager.Tree.prototype.add = function() {
	this.requestadd();
	return false;
};
//}}}
