//
// scroll-listener - listen for scroll events in React applications
//
// Copyright (c) 2015 Dennis Raymondo van der Sluis
//
// This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
//
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.
//
//     You should have received a copy of the GNU General Public License
//     along with this program.  If not, see <http://www.gnu.org/licenses/>
//


import ViewportMetrics	from 'react/lib/ViewportMetrics';
import types				from 'types.js';

const DEFAULT_TIMEOUT_DELAY= 300;



class ScrollListener {


	constructor(){
	   this.scrollTop		= 0;
	   this.isScrolling	= false;
		this.onChange		= types.forceFunction();
		this._timeout		= undefined;
	   this.scrollTimeoutDelay	= DEFAULT_TIMEOUT_DELAY;
	}


	init( onChangeCallback, delay ){
		this.scrollTimeoutDelay= types.forceNumber( delay, DEFAULT_TIMEOUT_DELAY );
		if ( 'undefined' !== typeof window ){
			this.onChange= types.forceFunction( onChangeCallback );
	   	window.addEventListener( 'scroll', this.onWindowScroll.bind(this) );
		}
	}


	remove(){
		if ( 'undefined' !== typeof window ){
	   	window.removeEventListener( 'scroll', this.onWindowScroll );
		}
	}


	onTimeout(){
	  if ( this.scrollTop === ViewportMetrics.currentScrollTop ){
		 clearTimeout( this._timeout );
		 this.isScrolling= false;
		 this.onChange();
	  }
	}


	onWindowScroll(){
		 this.scrollTop	= ViewportMetrics.currentScrollTop;
		 this.isScrolling	= true;
		 clearTimeout( this._timeout );
		 this._timeout= setTimeout( this.onTimeout.bind(this), this.scrollTimeoutDelay );
		 this.onChange();
	}

};

module.exports = ScrollListener;
