react-scroll-listener (+ mixin)
========

A scroll-event listener class for React apps.

<br/>

___
### usage:

<br/>

>`npm install --save react-scroll-listener`

<br/>

```javascript
var ScrollListener = require('react-scroll-listener');

// the mixin
var ScrollListenerMixin = ScrollListener.Mixin;
// with es6
import { ScrollListenerMixin } from 'react-scroll-listener';


// you can extend a class:
class myClass extends ScrollListener {

	constructor(){
		// can pass config object to constructor
		super({
			host	: window 	// default host
			delay   : 300 		// default scroll-end timeout
		});
	}
}

// or just create a default instance:
var scrollListener = new ScrollListener();


// create handlers:
var myScrollStartHandler = function( event ){
	console.log( 'logs on every scroll move' );
};

var myScrollEndHandler = function( event ){
	console.log( 'logs only when scrolling has stopped (default 300ms delay)' );
};

// and add handlers after window is loaded
window.onLoad = function(){
	scrollListener.addScrollHandler('some-id', myScrollStartHandler, myScrollEndHandler );
};

// or in a React class:
componentDidMount: function(){
	scrollListener.addScrollHandler('some-id', myScrollStartHandler, myScrollEndHandler );
}
```

###as mixin:

```javascript
var MyComponent = React.createClass({

	// call as a function, give an id for efficient reuse in other components
	mixins: [ ScrollListenerMixin('my-component') ],

	// mixin adds onScrollStart and onScrollEnd to the context, so you can use them like this:
	onScrollStart: function( event ){
		// you could re-render on each onscrollstart event (inhibit in child components shouldComponentUpdate with (! this.onScrolling) for performance)
		this.forceUpdate();
	},

	onScrollEnd: function( event ){
		console.log('logs when no scroll-events occurred in the last 300ms(default)');
	},

	render: function(){
		console.log('logs every scrollstart event due to this.onScrollStart handler');
		return <ChildComponent />;
	}
});


var ChildComponent = React.createClass({

	// call as a function, give an id for efficient reuse in other components
	mixins: [ ScrollListenerMixin('my-component') ],

	// inhibit re-rendering during scrollstart events
	shouldComponentUpdate: function(){
		return ! this.scrollListener.isScrolling;
	},

	render: function(){
		console.log('this component will not re-render during scrollstart events');
		console.log('but will re-render after 300ms(default) timeout for scrollend event');
		return null;
	}
});
```

###methods and props

```javascript
//
// after creation/initialization the following properties are available in context
//
this.scrollHost				= {}
this.scrollStartHandlers	= {}
this.scrollEndHandlers		= {}
this.scrollTop				= 0
this.isScrolling			= false
this.scrollTimeoutDelay		= 300 // ms
this.scrollListenerSet		= false

// and the following methods:

this.addScrollEventListener();
this.removeScrollEventListener();
this.addScrollHandler( <string/number> id, <function> handler, <boolean> onScrollEnd );
this.addScrollStartHandler( <string/number> id, <function> handler )
this.addScrollEndHandler( <string/number> id, <function> handler )
this.removeScrollStartHandler( <string/number> id )
this.removeScrollEndHandler( <string/number> id )
this.removeScrollHandlers()
this.getScrollListener( <string/number> id )

// internals, don't use
this._scrollListeners
this._scrollTimeout
this._onHostScroll
this._onHostScrollEnd
```
___


##Change log:

>0.6.0

- moved from node-uuid v1 to uuid v4
- fixed typo in readme

---


>0.5.0

- made available the actual scroll event as argument on onScrollStart and onScrollEnd
- now using node-uuid for generating unique id's

---

>0.4.2

changed license to MIT

---

>0.4.0

removes ViewportMetrics dependency

---


##License

MIT
