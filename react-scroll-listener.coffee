#
# react-scroll-listener - listen for and handle scroll events in React applications
# includes: ScrollListener.Mixin and/or ScrollListenerMixin
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

types= require 'types.js'

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


	_onHostScrollEnd: =>
		if @scrollTop is @scrollHost.pageYOffset
			clearTimeout @_scrollTimeout
			@isScrolling = false
			for handler of @scrollEndHandlers
				@scrollEndHandlers[ handler ]()


	_onHostScroll: =>
		 @isScrolling	= true
		 @scrollTop		= @scrollHost.pageYOffset
		 clearTimeout @_scrollTimeout
		 for handler of @scrollStartHandlers
			 @scrollStartHandlers[ handler ]()
		 @_scrollTimeout= setTimeout @_onHostScrollEnd, @scrollTimeoutDelay



#
#	 ScrollListener.Mixin:
#

_scrollListeners= {}
getScrollListener= ( id ) -> _scrollListeners[ id ] or _scrollListeners[ id ]= new ScrollListener


ScrollListenerMixin= ( id ) ->

	scrollStartId	= types.forceString Date.now()
	scrollEndId		= types.forceString Date.now()+ 1

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
