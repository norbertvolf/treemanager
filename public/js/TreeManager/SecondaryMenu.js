/* {{{ constructor */
/* Initialize secondary menu */
TreeManager.SecondaryMenu = function($node) {
	this.node = $node;
	this.jQuery = jQuery;
	jQuery(document).click(this.close.bind(this));
	this.node.find('a.active-popup-submenu').click(this.toggle);
};
/* }}} */
/* {{{ toggle */
/* Toggle block joined to menu item */
TreeManager.SecondaryMenu.prototype.toggle = function() {
	var obj = $(this).parent('.to-popup').children('.popup-submenu');
	var link = $(this);  
	var action;
	if(obj.hasClass('display-yes')) {
		obj.removeClass('display-yes');
		obj.addClass('display-no');
		link.removeClass('first-level-active');    
		action = "close";
	} else {
		$('#secondary-menu .popup-submenu').removeClass('display-yes');
		$('#secondary-menu .popup-submenu').addClass('display-no');
		obj.addClass('display-yes');
		$('#secondary-menu a.first-level').removeClass('first-level-active');
		link.addClass('first-level-active');
		action = "open";
	}
	TreeManager.publish('SecondaryMenu.toggle', [ action, link ]);
	return false;
};
/* }}} */
/* {{{ close */
/* Close all blocks joined to menu items */
TreeManager.SecondaryMenu.prototype.close = function() {
	var obj = this.jQuery('.to-popup .popup-submenu');
	if(obj.hasClass('display-yes')) {
		obj.removeClass('display-yes');
		obj.addClass('display-no');
		this.jQuery('#secondary-menu a.first-level').removeClass('first-level-active');    
	}
	TreeManager.publish('SecondaryMenu.close', undefined);
	return true;
};
/* }}} */
