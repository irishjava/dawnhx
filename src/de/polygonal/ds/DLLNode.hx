/*
 * HX3DS - DATA STRUCTURES FOR GAME PROGRAMMERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package de.polygonal.ds;

class DLLNode<T> implements haxe.rtti.Generic
{
	public var val:T;

	public var next:DLLNode<T>;
	public var prev:DLLNode<T>;
	
	var _list:DLL<T>;
	
	/**
	 * Store a value inside a new DLLNode instance.
	 */
	public function new(val:Null<T>, list:DLL<T>)
	{
		this.val = val;
		_list = list;
	}
	
	/**
	 * True if this node has a next node.
	 */
	inline public function hasNext():Bool
	{
		return next != null;
	}

	/**
	 * True if this node has a previous node.
	 */
	inline public function hasPrev():Bool
	{
		return prev != null;
	}
	
	/**
	 * Access the value of the next node.
	 */
	inline public function nextVal():T
	{
		#if debug
		if (!hasNext()) throw "node does not exist";
		#end
		
		return next.val;
	}
	
	/**
	 * Access the value of the previous node.
	 */
	inline public function prevVal():T
	{
		#if debug
		if (!hasPrev()) throw "node does not exist";
		#end
		
		return prev.val;
	}
	
	/**
	 * A reference to the list that this node is contained in.
	 */
	inline public function getList():DLL<T>
	{
		return _list;
	}
	
	/**
	 * Remove this node from the list.
	 */
	inline public function remove():Void
	{
		_list.remove(this);
	}
	
	/**
	 * Insert the given node after this node.
	 * This a helper function used by the DLL class.
	 */
	inline public function insertAfter(node:DLLNode<T>):Void
	{
		node.next = next;
		node.prev = this;
		if (hasNext()) next.prev = node;
		next = node;
	}
	
	/**
	 * Insert the given node before this node.
	 * This a helper function used by the DLL class.
	 */
	inline public function insertBefore(node:DLLNode<T>):Void
	{
		node.next = this;
		node.prev = prev;
		if (hasPrev()) prev.next = node;
		prev = node;
	}
	
	/**
	 * Prepend a node to this node assuming this is the <b>tail</b> of the list.
	 * 
	 *  @return The list's new head node.
	 */
	inline public function prepend(node:DLLNode<T>):DLLNode<T>
	{
		if (node != null) node.next = this;
		prev = node;
		return node;
	}
	
	/**
	 * Append a node to this node assuming this is the <b>tail</b> of the list.
	 * 
	 *  @return The lists's new tail node.
	 */
	inline public function append(node:DLLNode<T>):DLLNode<T>
	{
		next = node;
		if (node != null) node.prev = this;
		return node;
	}
	
	/**
	 * Prepend this node to the given node assuming the given node is the <b>head</b> of the list.
	 * Useful for updating a list which is not managed by a DLL class.
	 * 
	 * @return The list's new head node.
	 */
	inline public function prependTo(node:DLLNode<T>):DLLNode<T>
	{
		next = node;
		if (node != null) node.prev = this;
		return this;
	}
	
	/**
	 * Append this node to the given node assuming the given node is the <b>tail</b> of the list.
	 * Useful for updating a list which is not managed by a DLL class.
	 * 
	 * @return The lists's new tail node.
	 */
	inline public function appendTo(node:DLLNode<T>):DLLNode<T>
	{
		prev = node;
		if (node != null) node.next = this;
		return this;
	}
	
	/**
	 * Unlink a node from a list. This a helper function used by the DLL class.
	 * Don't use this method in a list managed by the DLL class, since the lists's
	 * head, tail and size fields become invalid.
	 * 
	 * @return This node's next node.
	 */
	inline public function unlink():DLLNode<T>
	{
		var t:DLLNode<T> = next;
		if (hasPrev()) prev.next = next;
		if (hasNext()) next.prev = prev;
		next = prev = null;
		return t;
	}
}