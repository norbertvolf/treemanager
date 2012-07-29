// bind {{{
// Define bind method for Function class if does not exists
if (!Function.prototype.bind) {
	Function.prototype.bind = function(oThis) {
		if (typeof this !== 'function') {
			throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable');
		}

		var	aArgs = Array.prototype.slice.call(arguments, 1),
			fToBind = this,
			fNOP = function() {},
			fBound = function() {
				return fToBind.apply(
					(this instanceof fNOP) ? this : oThis || window,
					aArgs.concat(Array.prototype.slice.call(arguments))
				);
			};

		fNOP.prototype = this.prototype;
		fBound.prototype = new fNOP();

		return fBound;
	};
}
//}}}

var TreeManager = TreeManager || {};

TreeManager.globals = {};

// lang {{{
// getter/setter for actual lang. Must be initialized in template (see default layout)
TreeManager.lang = function(lang) {
	if ( TreeManager.globals.lang == null ) {
		this.globals.lang = lang;
	}
	if ( lang != null ) {
		this.globals.lang = lang;
	}
	return(this.globals.lang);
}
//}}}
// locale {{{
// getter/setter for actual locale. Must be initialized in template (see default layout)
TreeManager.locale = function(locale) {
	if ( TreeManager.globals.locale == null ) {
		this.globals.locale = locale;
	}
	if ( locale != null ) {
		this.globals.locale = locale;
	}
	return(this.globals.locale);
}
//}}}
// __ {{{
// getter/setter for gallery url. Must be initialized in template (see default layout)
TreeManager.__ = function( message ) {
	if ( ! this.globals.gt ) {
		this.globals.gt = new Gettext( { 'domain' : 'messages' } );
	}
	return(this.globals.gt.gettext(message));
}
//}}}
// uniqId {{{
// generate uniqid 
TreeManager.uniqId = function() {
	return Math.random() * Math.pow(10, 17) + Math.random() * Math.pow(10, 17) + Math.random() * Math.pow(10, 17);
};
//}}}
// request {{{
// wrap jQuery ajax method 
TreeManager.request = function(params, cbSuccess, cbError) {
	//Warning see http://api.jquery.com/jQuery.ajax/
	//success and error are deprecated from 1.8
	//We must rewrite the request method to use
	//done & fail & always method !!!!!!!!!!!!!!!!
	TreeManager.show('.caramel-header-block-loading');
	var request = $.ajax({
		url	: params.url,
		type	: params.type,
		data	: params.data,
		dataType: 'json',
		success: function(data, state) {
			TreeManager.hide('.caramel-header-block-loading');
			cbSuccess(data, state);
		},
		error: function(xhr, state){
			TreeManager.hide('.caramel-header-block-loading');
			cbError(state);
		}
	});
};
//}}}
// publish {{{
// wrap jQuery pubsub plugin publish method
TreeManager.publish = function(topic, args) {
	$.publish(topic, args);
};
//}}}
// subscribe {{{
// wrap jQuery pubsub plugin subscribe method
TreeManager.subscribe = function(topic, cb) {
	$.subscribe(topic, cb);
};
//}}}
// stringify {{{
// Convert value to JSON string
TreeManager.stringify = function(value, replacer, space) {
	return(JSON.stringify(value, replacer, space));
};
//}}}
// destringify {{{
// Convert json string to object
TreeManager.destringify = function(text, reviver) {
	try {
		return(JSON.parse(text, reviver));
	}
	catch(e) {
		if(TreeManager.isDev()) {
			console.log("Error while calling destringify: " + text);
		}
		return '';
	}
};
//}}}
// storage {{{
// Save to value to local storage
TreeManager.storage = function( key, value, default_value ) {
	
	if ( key == undefined ) {
		throw "Key for TreeManager.storage not found.";
	}
	if(typeof(Storage)!=="undefined") {
		var path = window.location.pathname;
		path = path.replace(/\/$/, '');
		if ( value != undefined ) {
			sessionStorage.setItem(path + '/' + key  , value);			
			retval = value;
		} else {
			if ( sessionStorage.getItem(path + '/' + key) === null && default_value != undefined ) {
				retval = default_value;
			} else {
				retval = sessionStorage.getItem(path + '/' + key);			
			}
		}
	} else {
		if ( value != undefined ) {
			this["_" + key] = value;
			retval = value;
		} else {
			if ( this["_" + key] == undefined && default_value != undefined ) {
				retval = default_value;
			} else {
				retval = retval = this["_" + key];			
			}
		}
	}
	return(retval);
};
///}}}
// hide {{{
// Centralized hide method
TreeManager.hide = function( select ) {
	if ( typeof(select) == "string") {
		select = jQuery(select);
	} 
	
	if ( typeof(select) == "object" ) {
		select.each(function(index, el) {
			el = jQuery(el);
			if ( el.is('td') ) {
				el.hide();
			} else {
				el.addClass('display-no');
			}
		});
	}
};
///}}}
// show {{{
// Centralized show method
TreeManager.show = function( select ) {
	if ( typeof(select) == "string") {
		select = jQuery(select);
	} 
	
	if ( typeof(select) == "object" ) {
		select.each(function(index, el) {
			el = jQuery(el);
			if ( el.is('td') ) {
				el.show();
			} else {
				el.removeClass('display-no');
			}
		});
	}
};
///}}}
// keys {{{
// Return keys of Object (hash in perl terminology)
TreeManager.keys = function( hash ) {
	var keys = [];
	for(var key in hash) {
		keys.push(key);
	}
	return keys;
};
//}}}
// isNumber {{{
// Check if value is numeric
TreeManager.isNumber = function(n) {
	  return !isNaN(parseFloat(n)) && isFinite(n);
};
///}}}
