#
# react-scroll-listener - listen for and handle scroll events in React applications
# includes: ScrollListener.Mixin
#
# Copyright (c) 2015 Dennis Raymondo van der Sluis
#
# This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
#

ViewportMetrics	= require 'react/lib/ViewportMetrics'
types					= require 'types.js'

#
# ScrollListener
#

class ScrollListener

	DEFAULT_TIMEOUT_DELAY = 300

	constructor: ( settings ) ->
		settings					= types.forceObject settings
		@scrollHost				= types.forceObject settings.host
		@scrollStartHandlers	= {}
		@scrollEndHandlers	= {}
		@scrollTop				= 0
		@isScrolling			= false
		@scrollTimeoutDelay 	= types.forceNumber settings.delay, DEFAULT_TIMEOUT_DELAY
		@_scrollTimeout		= undefined
		@scrollListenerAdded	= false



	addScrollEventListener: ->
		return if @scrollListenerAdded

		if not @scrollHost.addEventListener
			if 'undefined' is typeof window
				return console.log 'ScrollListener::addScrollEventListener -> bad or missing host/window, cannot add event-listener!'
			else
				@scrollHost= window

		@scrollHost.addEventListener 'scroll', @_onHostScroll
		return @scrollListenerAdded= true



	removeScrollEventListener: -> @scrollHost.removeEventListener 'scroll', @_onHostScroll


	setScrollHandler: ( id, handler, onScrollEnd ) ->
		# TODO

	addScrollHandler: ( id, handler, onScrollEnd ) ->
		id= types.forceString id
		if not id
			return console.log 'ScrollListener::addScrollHandler -> could not add handler! id: '+ id
		handler= types.forceFunction handler
		if onScrollEnd and not @scrollEndHandlers[ id ]
			@scrollEndHandlers[ id ]= handler
		else if not @scrollStartHandlers[ id ]
			@scrollStartHandlers[ id ]= handler

		return @addScrollEventListener()



	removeScrollHandler: ( id, onScrollEnd ) ->
		if onScrollEnd
			delete @scrollEndHandlers[ id ]
		else
			delete @scrollStartHandlers[ id ]


	_onHostScrollEnd: =>
		if @scrollTop is ViewportMetrics.currentScrollTop
			clearTimeout @_scrollTimeout
			@isScrolling = false
			for handler of @scrollEndHandlers
				@scrollEndHandlers[ handler ]()


	_onHostScroll: =>
		 @isScrolling	= true
		 @scrollTop		= ViewportMetrics.currentScrollTop
		 clearTimeout @_scrollTimeout
		 for handler of @scrollStartHandlers
			 @scrollStartHandlers[ handler ]()
		 @_scrollTimeout= setTimeout @_onHostScrollEnd, @scrollTimeoutDelay



#
#	 ScrollListener.Mixin:
#
#	the mixin adds the scrollListener instance to the component
#	can set id's for reuse and optimization
#
#	use this.onScrollStart and this.onScrollEnd in your component
#

_scrollListeners= {}
getScrollListener= ( id ) -> _scrollListeners[ id ] or _scrollListeners[ id ]= new ScrollListener

Mixin= ( id, startHandlerId, endHandlerId ) ->

	scrollStartId	= types.forceString startHandlerId, Date.now()
	scrollEndId		= types.forceString endHandlerId, Date.now()+ 1

	return Mixin=

		scrollListener	: getScrollListener types.forceString id, 'generic'

		componentDidMount: ->
			@scrollListener.addScrollHandler scrollStartId, @onScrollStart
			@scrollListener.addScrollHandler scrollEndId, @onScrollEnd, true

		componentWillUnmount: ->
			@scrollListener.removeScrollHandler scrollStartId
			@scrollListener.removeScrollHandler scrollEndId, true


Mixin.componentWillMount= -> throw new Error 'You are trying to use ScrollListener.Mixin as an object, but it\'s a Function! Check the mixin for usage details.'


ScrollListener.Mixin= Mixin

module.exports= ScrollListener
