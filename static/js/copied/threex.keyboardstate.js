/* 
-- Original Git repository --
https://github.com/jeromeetienne/threex.keyboardstate

-- Copied from LICENSE File --
The MIT License (MIT)

Copyright (c) 2013 Jerome Etienne

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// THREEx.KeyboardState.js keep the current state of the keyboard.
// It is possible to query it at any time. No need of an event.
// This is particularly convenient in loop driven case, like in
// 3D demos or games.
//
// # Usage
//
// **Step 1**: Create the object
//
// ```var keyboard	= new THREEx.KeyboardState();```
//
// **Step 2**: Query the keyboard state
//
// This will return true if shift and A are pressed, false otherwise
//
// ```keyboard.pressed("shift+A")```
//
// **Step 3**: Stop listening to the keyboard
//
// ```keyboard.destroy()```
//
// NOTE: this library may be nice as standaline. independant from three.js
// - rename it keyboardForGame
//
// # Code
//

/** @namespace */
var THREEx	= THREEx 		|| {};

/**
 * - NOTE: it would be quite easy to push event-driven too
 *   - microevent.js for events handling
 *   - in this._onkeyChange, generate a string from the DOM event
 *   - use this as event name
*/
THREEx.KeyboardState	= function(domElement)
{
	this.domElement= domElement	|| document;
	// to store the current state
	this.keyCodes	= {};
	this.modifiers	= {};
	
	// create callback to bind/unbind keyboard events
	var _this	= this;
	this._onKeyDown	= function(event){ _this._onKeyChange(event)	}
	this._onKeyUp	= function(event){ _this._onKeyChange(event)	}

	// bind keyEvents
	this.domElement.addEventListener("keydown", this._onKeyDown, false);
	this.domElement.addEventListener("keyup", this._onKeyUp, false);

	// create callback to bind/unbind window blur event
	this._onBlur = function(){
		for(var prop in _this.keyCodes)  _this.keyCodes[prop] = false;
		for(var prop in _this.modifiers)  _this.modifiers[prop] = false;
	}

	// bind window blur
	window.addEventListener("blur", this._onBlur, false);
}

/**
 * To stop listening of the keyboard events
*/
THREEx.KeyboardState.prototype.destroy	= function()
{
	// unbind keyEvents
	this.domElement.removeEventListener("keydown", this._onKeyDown, false);
	this.domElement.removeEventListener("keyup", this._onKeyUp, false);

	// unbind window blur event
	window.removeEventListener("blur", this._onBlur, false);
}

THREEx.KeyboardState.MODIFIERS	= ['shift', 'ctrl', 'alt', 'meta'];
THREEx.KeyboardState.ALIAS	= {
	'left'		: 37,
	'up'		: 38,
	'right'		: 39,
	'down'		: 40,
	'space'		: 32,
	'pageup'	: 33,
	'pagedown'	: 34,
	'tab'		: 9,
	'escape'	: 27
};

/**
 * to process the keyboard dom event
*/
THREEx.KeyboardState.prototype._onKeyChange	= function(event)
{
	// log to debug
	//console.log("onKeyChange", event, event.keyCode, event.shiftKey, event.ctrlKey, event.altKey, event.metaKey)

	// update this.keyCodes
	var keyCode		= event.keyCode
	var pressed		= event.type === 'keydown' ? true : false
	this.keyCodes[keyCode]	= pressed
	// update this.modifiers
	this.modifiers['shift']	= event.shiftKey
	this.modifiers['ctrl']	= event.ctrlKey
	this.modifiers['alt']	= event.altKey
	this.modifiers['meta']	= event.metaKey
}

THREEx.KeyboardState.prototype.keynameToKeycode	= function(key){
	if( Object.keys(THREEx.KeyboardState.ALIAS).indexOf( key ) != -1 ){
		return THREEx.KeyboardState.ALIAS[key];
	}else {
		return key.toUpperCase().charCodeAt(0);
	}
}

/**
 * query keyboard state to know if a key is pressed of not
 *
 * @param {String} keyDesc the description of the key. format : modifiers+key e.g shift+A
 * @returns {Boolean} true if the key is pressed, false otherwise
*/
THREEx.KeyboardState.prototype.pressed	= function(keyDesc){
	var keys	= keyDesc.split("+");
	for(var i = 0; i < keys.length; i++){
		var key		= keys[i]
		var pressed	= false
		if( THREEx.KeyboardState.MODIFIERS.indexOf( key ) !== -1 ){
			pressed	= this.modifiers[key];
		}else{
			pressed	= this.keyCodes[ this.keynameToKeycode( key ) ];
		}
		if( !pressed)	return false;
	}
	return true;
}

/**
 * return true if an event match a keyDesc
 * @param  {KeyboardEvent} event   keyboard event
 * @param  {String} keyDesc string description of the key
 * @return {Boolean}         true if the event match keyDesc, false otherwise
 */
THREEx.KeyboardState.prototype.eventMatches = function(event, keyDesc) {
	var aliases	= THREEx.KeyboardState.ALIAS
	var aliasKeys	= Object.keys(aliases)
	var keys	= keyDesc.split("+")
	// log to debug
	// console.log("eventMatches", event, event.keyCode, event.shiftKey, event.ctrlKey, event.altKey, event.metaKey)
	for(var i = 0; i < keys.length; i++){
		var key		= keys[i];
		var pressed	= false;
		if( key === 'shift' ){
			pressed	= (event.shiftKey	? true : false)
		}else if( key === 'ctrl' ){
			pressed	= (event.ctrlKey	? true : false)
		}else if( key === 'alt' ){
			pressed	= (event.altKey		? true : false)
		}else if( key === 'meta' ){
			pressed	= (event.metaKey	? true : false)
		}else if( aliasKeys.indexOf( key ) !== -1 ){
			pressed	= (event.keyCode === aliases[key] ? true : false);
		}else if( event.keyCode === key.toUpperCase().charCodeAt(0) ){
			pressed	= true;
		}
		if( !pressed )	return false;
	}
	return true;
}
