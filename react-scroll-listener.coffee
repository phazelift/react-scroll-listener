#
# react-scroll-listener - listen for and handle scroll events in React applications
# includes: ScrollListener.Mixin and/or ScrollListenerMixin
#
# MIT License
#
# Copyright (c) 2015 Dennis Raymondo van der Sluis
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

types			= require 'types.js'
uniqueUUID	= require 'node-uuid'

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
		@scrollListenerSet	= false



	addScrollEventListener: ->
		return if @scrollListenerSet

		if not @scrollHost.addEventListener
			if 'undefined' is typeof window
				return console.log 'ScrollListener::addScrollEventListener -> bad or missing host/window, cannot add event-listener!'
			else
				@scrollHost= window

		@scrollHost.addEventListener 'scroll', @_onHostScroll
		return @scrollListenerSet= true



	removeScrollEventListener: -> @scrollHost.removeEventListener 'scroll', @_onHostScroll


	addScrollHandler: ( id, handler, onScrollEnd ) ->
		id= types.forceString id
		if not id
			return console.log 'ScrollListener::addScrollHandler -> cannot add handler without id!'
		handler= types.forceFunction handler
		if onScrollEnd and not @scrollEndHandlers[ id ]
			@scrollEndHandlers[ id ]= handler
		else if not @scrollStartHandlers[ id ]
			@scrollStartHandlers[ id ]= handler

		return @addScrollEventListener()

	addScrollStartHandler: ( id, handler ) -> @addScrollHandler id, handler
	addScrollEndHandler: ( id, handler ) -> @addScrollHandler id, handler, true


	removeScrollStartHandler: ( id ) ->	delete @scrollStartHandlers[ id ]
	removeScrollEndHandler: ( id ) -> delete @scrollEndHandlers[ id ]

	removeScrollHandlers: () ->
		@scrollStartHandlers= {};
		@scrollEndHandlers= {};

	# TODO: this should make possible overwriting an existing handler
	# setScrollStartHandler: ( id, handler) ->
	# setScrollEndHandler: ( id, handler) ->


	_onHostScrollEnd: ( event ) =>
		if @scrollTop is @scrollHost.pageYOffset
			clearTimeout @_scrollTimeout
			@isScrolling = false
			for handler of @scrollEndHandlers
				@scrollEndHandlers[ handler ]( event )


	_onHostScroll: ( event ) =>
		 @isScrolling	= true
		 @scrollTop		= @scrollHost.pageYOffset
		 clearTimeout @_scrollTimeout
		 for handler of @scrollStartHandlers
			 @scrollStartHandlers[ handler ]( event )
		 @_scrollTimeout= setTimeout @_onHostScrollEnd.bind(@, event), @scrollTimeoutDelay



#
#	 ScrollListener.Mixin:
#

_scrollListeners= {}
getScrollListener= ( id ) -> _scrollListeners[ id ] or _scrollListeners[ id ]= new ScrollListener


ScrollListenerMixin= ( id ) ->

	scrollStartId	= uniqueUUID.v1()
	scrollEndId		= uniqueUUID.v1()

	return Mixin=

		scrollListener	: getScrollListener types.forceString id, 'generic'

		componentDidMount: ->
			@scrollListener.addScrollStartHandler scrollStartId, @onScrollStart
			@scrollListener.addScrollEndHandler scrollEndId, @onScrollEnd

		componentWillUnmount: ->
			@scrollListener.removeScrollStartHandler scrollStartId
			@scrollListener.removeScrollEndHandler scrollEndId


ScrollListener.componentWillMount= -> throw new Error 'You are trying to use ScrollListenerMixin as an object, but it\'s a Function! Check the mixin for usage details.'


ScrollListener.Mixin= ScrollListenerMixin
ScrollListener.ScrollListenerMixin= ScrollListenerMixin

module.exports= ScrollListener
