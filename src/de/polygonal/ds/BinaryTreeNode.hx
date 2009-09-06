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

class BinaryTreeNode<T>
{
	public var parent:BinaryTreeNode<T>;
	public var val:T;

	public var l:BinaryTreeNode<T>;
	public var r:BinaryTreeNode<T>;

	public function new(val:T)
	{
		this.val = val;
	}

	public function preorder(process:BinaryTreeNode<T>->Void):Void
	{
		process(this);
		if (hasL()) preorderInternal(l, process);
		if (hasR()) preorderInternal(r, process);
	}

	public function inorder(process:BinaryTreeNode<T>->Void):Void
	{
		if (hasL()) inorderInternal(l, process);
		process(this);
		if (hasR()) inorderInternal(r, process);
	}

	public function postorder(process:BinaryTreeNode<T>->Void):Void
	{
		if (hasL()) postorderInternal(l, process);
		if (hasR()) postorderInternal(r, process);
		process(this);
	}

	inline public function hasL():Bool
	{
		return l != null;
	}

	inline public function setL(val:T):Void
	{
		if (l == null)
		{
			l = new BinaryTreeNode<T>(val);
			l.parent = this;
		}
		else
			l.val = val;
	}

	inline public function hasR():Bool
	{
		return r != null;
	}

	inline public function setR(val:T):Void
	{
		if (r == null)
		{
			r = new BinaryTreeNode<T>(val);
			r.parent = this;
		}
		else
			r.val = val;
	}

	inline public function isL():Bool
	{
		return this == parent.l;
	}

	inline public function isR():Bool
	{
		return this == parent.r;
	}

	public function depthUp():Int
	{
		var node:BinaryTreeNode<T> = parent;
		var c:Int = 0;
		while (node != null)
		{
			node = node.parent;
			c++;
		}
		return c;
	}
	
	public function depthDown(?node:BinaryTreeNode<T> = null):Int
	{
		var left:Int = -1, right:Int = -1;
			
		if (node == null) node = this;
		
		if (node.hasL())
			left = depthDown(node.l);
		
		if (node.hasR())
			right = depthDown(node.r);
		
		return ((left > right ? left : right) + 1);
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nBinaryTree, size: " + size() + " depth: " + depthDown() + "\n{\n";
		
		var test = function(node:BinaryTreeNode<T>):Void
		{
			var d:Int = node.depthUp();
			var t:String = "";
			for (i in 0...d)
			{
				if (i == d - 1)
					t += "+---";
				else
					t += "|   ";
			}
			
			t = "\t" + t;
			s += t + node.val + "\n";
		}
		preorder(test);
		return s + "}";
		#else
		return "{BinaryTree, size: " + size() + " depth: " + depthDown() + "}";
		#end
	}

	private function preorderInternal(node:BinaryTreeNode<T>, process:BinaryTreeNode<T>->Void):Void
	{
		process(node);
		
		if (node.hasL())
			preorderInternal(node.l, process);
		
		if (node.hasR())
			preorderInternal(node.r, process);
	}

	private function inorderInternal(node:BinaryTreeNode<T>, process:BinaryTreeNode<T>->Void):Void
	{
		if (node.hasL())
			inorderInternal(node.l, process);
		
		process(node);
		
		if (node.hasR())
			inorderInternal(node.r, process);
	}

	private function postorderInternal(node:BinaryTreeNode<T>, process:BinaryTreeNode<T>->Void):Void
	{
		if (node.hasL())
			postorderInternal(node.l, process);
		
		if (node.hasR())
			postorderInternal(node.r, process);
		
		process(node);
	}

	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/

	public function contains(val:T):Bool
	{
		var stack:Vector<BinaryTreeNode<T>> = new Vector<BinaryTreeNode<T>>();
		stack[0] = this;
		var w:BinaryTreeNode<T>;
		var c:Int = 1;
		while (c > 0)
		{
			w = stack[--c];
			if (w.val == val) return true;
			if (w.hasL()) stack[c++] = w.l;
			if (w.hasR()) stack[c++] = w.r;
		}
		return false;
	}

	public function clear():Void
	{
		if (hasL())
		{
			l.clear();
			l = null;
		}
		if (hasR())
		{
			r.clear();
			r = null;
		}
	}

	public function iterator():BinaryTreeNodeIterator<T>
	{
		return new BinaryTreeNodeIterator<T>(this);
	}

	public function size():Int
	{
		var c:Int = 1;

		if (hasL())
			c += l.size();
		if (hasR())
			c += r.size();

		return c;
	}

	public function isEmpty():Bool
	{
		throw "unsupported operation";
		return false;
	}

	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		var i:Int = 0;
		var f:BinaryTreeNode<T>->Void = function(node:BinaryTreeNode<T>)
		{
			a[i++] = node.val;
		}
		preorder(f);
		return a;
	}

	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>(size(), true);
		var i:Int = 0;
		preorder(function(node:BinaryTreeNode<T>):Void { v[i++] = node.val; });
		return v;
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var stack:Vector<BinaryTreeNode<T>> = new Vector<BinaryTreeNode<T>>();
		var copy:BinaryTreeNode<T> = new BinaryTreeNode<T>(copier != null ? copier(val) : val);
		stack.push(this);
		stack.push(copy);
		var i:Int = 2;
		
		if (copier == null)
		{
			while (i > 0)
			{
				var c = stack[--i];
				var n = stack[--i];
				if (n.hasR())
				{
					c.setR(n.r.val);
					stack[i++] = n.r;
					stack[i++] = c.r;
				}
				if (n.hasL())
				{
					c.setL(n.l.val);
					stack[i++] = n.l;
					stack[i++] = c.l;
				}
			}
		}
		else
		{
			while (i > 0)
			{
				var c = stack[--i];
				var n = stack[--i];
				if (n.hasR())
				{
					c.setR(copier(n.r.val));
					stack[i++] = n.r;
					stack[i++] = c.r;
				}
				if (n.hasL())
				{
					c.setL(copier(n.l.val));
					stack[i++] = n.l;
					stack[i++] = c.l;
				}
			}
		}
		
		return cast copy;
	}
}

class BinaryTreeNodeIterator<T> implements haxe.rtti.Generic
{
	private var _node:BinaryTreeNode<T>;
	private var _stack:Vector<BinaryTreeNode<T>>;
	private var _c:Int;

	public function new(node:BinaryTreeNode<T>)
	{
		_node = node;

		var b:BinaryTreeNode<T>;
		_stack = new Vector<BinaryTreeNode<T>>();
		_stack[0] = _node;
		_c = 1;
	}

	public function start():Void
	{
		_stack[0] = _node;
		_c = 1;
	}

	public function hasNext():Bool
	{
		return _c > 0;
	}

	public function next():T
	{
		var w:BinaryTreeNode<T> = _stack[--_c];
		if (w.hasL()) _stack[_c++] = w.l;
		if (w.hasR()) _stack[_c++] = w.r;
		return w.val;
	}
}