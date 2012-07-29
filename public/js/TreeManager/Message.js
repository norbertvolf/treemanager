/* {{{ constructor */
/* Initialize message box */
TreeManager.Message = function(block) {
	this.block = block;
	this.jQuery = jQuery;
	
	if ( this.block.length ) {
		this.block.hide();
		this.block.removeClass('display-no');
		//Bind event handler to save banner informations
		this.block.find('#message-btn-close').click(this.handleClose.bind(this));

		//Subscribe events
		TreeManager.subscribe('Message.Ok', this.handleMessageOk.bind(this));
		TreeManager.subscribe('Message.Err', this.handleMessageErr.bind(this));
		TreeManager.subscribe('Message.Err.HTTP', this.handleMessageErrHTTP.bind(this));


	}
};
/* }}} */
/* {{{ handleMessageOk */
/* Show ok message */
TreeManager.Message.prototype.handleMessageOk = function( message ) {
	if ( message != null ) {
		this.block.find("#message-text").html(message);
		this.focusMessage();
		 setTimeout(this.handleCloseLazy.bind(this), 1000);
	}
	return true;
};
/* }}} */
/* {{{ handleMessageErr */
/* Show error message */
TreeManager.Message.prototype.handleMessageErr = function( message, errors ) {
	this.block.hide();
	if ( typeof message == "string" ) {
		this.block.find("#message-text").html(message);
		this.focusMessage();
	} 
	
	if ( typeof errors == "object" ) {
		var func = function (error, i) {
			output = "<p>" + error.label + ":" + error.error + "</p>";
			this.block.find("#message-text").append(jQuery(output));
		};
		$.map( errors,  func.bind(this));
	}
	this.block.show(300);
	return true;
};
/* }}} */
/* {{{ handleMessageErrHTTP */
/* Show error message after HTTP error */
TreeManager.Message.prototype.handleMessageErrHTTP = function( state ) {
	var message;
	if ( state != null ) {
		message =  TreeManager.__('Error on server side. Pls contant administrators.') + ' (' + TreeManager.stringify(state) + ')';
		this.block.find("#message-text").html(message);
		this.focusMessage();
	}
	return true;
};
/* }}} */
/* {{{ handleClose */
/* Hide message block */
TreeManager.Message.prototype.handleClose = function() {
	this.block.hide();
	TreeManager.publish('Message.Close', [ this.block ]);
	return true;
};
/* }}} */
/* {{{ handleCloseLazy */
/* Hide message block after 500ms */
TreeManager.Message.prototype.handleCloseLazy = function( ) {
	var func = function () { TreeManager.publish('Message.Close', [ this.block ]); };
	this.block.hide(700, func.bind(this));
	return true;
};
/* }}} */
/* {{{ focusMessage */
/* Move focus to message */
TreeManager.Message.prototype.focusMessage = function() {
	this.block.show();
	window.scrollTo(0, 0);
	TreeManager.publish('Message.Open', [ this.block ]);
	return true;
};
/* }}} */
