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

import flash.Vector;

class TreeIterator<T> implements haxe.rtti.Generic
{
	private var _stack:Vector<TreeNode<T>>;
	
	private var _node:TreeNode<T>;
	private var _childItr:TreeNode<T>;
	
	public function new(node:TreeNode<T>)
	{
		_node = node;
		_stack = new Vector<TreeNode<T>>();
		_stack.push(node);
		
		start();
	}
	
	public function hasNext():Bool
	{
		return _stack.length > 0;
	}
	
	public function next():T
	{
		var node:TreeNode<T> = _stack.pop();
		var walker:TreeNode<T> = node.children;
		while (walker != null)
		{
			_stack.push(walker);
			walker = walker.next;
		}
		return node.val;
	}
	
	inline public function getVal():T
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		return _node.val;
	}
	
	inline public function setVal(val:T):Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		_node.val = val;
	}
	
	inline public function getNode():TreeNode<T>
	{
		return _node;
	}
	
	inline public function getChildVal():T
	{
		#if debug
		if (!childValid()) throw "child node is invalid";
		#end
		
		return _childItr.val;
	}
	
	inline public function getChildNode():TreeNode<T>
	{
		#if debug
		if (!childValid()) throw "child node is invalid";
		#end
		
		return _childItr;
	}

	inline public function valid():Bool
	{
		return _node != null;
	}
	
	/*///////////////////////////////////////////////////////
	// vertical
	///////////////////////////////////////////////////////*/
	
	inline public function start():Void
	{
		root();
		childStart();
	}
	
	inline public function root():Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		while (_node.hasParent())
			_node = _node.parent;
		reset();
	}
	
	inline public function up():Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		_node = _node.parent;
		reset();
	}
	
	inline public function down():Void
	{
		#if debug
		if (!childValid()) throw "child node is invalid";
		#end
		
		_node = _childItr;
		reset();
	}
	
	/*///////////////////////////////////////////////////////
	// horizonal
	///////////////////////////////////////////////////////*/
	
	inline public function nextChild():Void
	{
		#if debug
		if (!childValid()) throw "child node is invalid";
		#end
		
		_childItr = _childItr.next;
	}
	
	inline public function prevChild():Void
	{
		#if debug
		if (!childValid()) throw "child node is invalid";
		#end
		
		_childItr = _childItr.prev;
	}
	
	inline public function childStart():Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		_childItr = _node.children;
	}
	
	inline public function childEnd():Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		_childItr = _node.getLastChild();
	}
	
	inline public function childValid():Bool
	{
		return _childItr != null;
	}
	
	inline public function appendChild(val:T):Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		_childItr = createChildNode(val, true);
	}
	
	inline public function prependChild(val:T):Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		var childNode:TreeNode<T> = createChildNode(val, false);
		
		if (childValid())
		{
			childNode.next = _node.children;
			_node.children.prev = childNode;
			_node.children = childNode;
		}
		else
			_node.children = childNode;
		
		_childItr = childNode;
	}
	
	inline public function insertBeforeChild(val:T):Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		if (childValid())
		{
			var childNode:TreeNode<T> = createChildNode(val, false);
			
			childNode.next = _childItr;
			childNode.prev = _childItr.prev;
			
			if (_childItr.hasPrevSibling())
				_childItr.prev.next = childNode;
			
			_childItr.prev = childNode;
			_childItr = childNode;
		}
		else
			appendChild(val);
	}
	
	inline public function insertAfterChild(val:T):Void
	{
		#if debug
		if (!valid()) throw "node is invalid";
		#end
		
		if (childValid())
		{
			var childNode:TreeNode<T> = createChildNode(val, false);
			
			childNode.prev = _childItr;
			childNode.next = _childItr.next;
			
			if (_childItr.hasNextSibling())
				_childItr.next.prev = childNode;
			
			_childItr.next = childNode;
			_childItr = childNode;
		}
		else
			appendChild(val);
	}
	
	inline public function removeChild():Void
	{
		#if debug
		if (!(valid() && childValid()))
			throw "node is invalid";
		#end
		
		_childItr.parent = null;
		
		var node:TreeNode<T> = _childItr;
		_childItr = node.next;
		
		if (node.hasPrevSibling()) node.prev.next = node.next;
		if (node.hasNextSibling()) node.next.prev = node.prev;
		node.parent = node.next = node.prev = null;
	}
	
	inline private function reset():Void
	{
		if (valid()) _childItr = _node.children;
	}
	
	inline private function createChildNode(val:T, append:Bool)
	{
		if (append)
			return new TreeNode<T>(val, _node);
		else
		{
			var node:TreeNode<T> = new TreeNode<T>(val);
			node.parent = _node;
			return node;
		}
	}
	
	inline private function getTail(node:TreeNode<T>):TreeNode<T>
	{
		var tail:TreeNode<T> = node;
		while (tail.hasNextSibling()) tail.next;
		return tail;
	}
	
	public function toString():String
	{
		return "{TreeIterator, V: " + (valid() ? _node.val : null) + ", H: " + (childValid() ? _childItr.val : null) + "}";
	}
}