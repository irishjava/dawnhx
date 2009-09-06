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

import de.polygonal.ds.DLL;
import de.polygonal.ds.DLLNode;
import flash.Vector;

class TreeNode<T> implements haxe.rtti.Generic
{
	public var val:T;
	
	public var parent:TreeNode<T>;
	public var children:TreeNode<T>;
	public var prev:TreeNode<T>;
	public var next:TreeNode<T>;
	
	public var marked:Bool;
	
	public function new(val:Null<T>, ?parent:TreeNode<T> = null)
	{
		this.val = val;
		this.parent = parent;
		
		children = null;
		prev = null;
		next = null;
		
		if (hasParent())
		{
			if (parent.hasChildren())
			{
				var tail:TreeNode<T> = parent.getLastChild();
				tail.next = this;
				this.prev = tail;
				next = null;
			}
			else
				parent.children = this;
		}
	}
	
	inline public function isRoot():Bool
	{
		return parent == null;
	}
	
	inline public function isLeaf():Bool
	{
		return children == null;
	}
	
	inline public function isChild():Bool
	{
		return valid(parent);
	}
	
	inline public function hasParent():Bool
	{
		return isChild();
	}
	
	inline public function hasChildren():Bool
	{
		return valid(children);
	}
	
	inline public function hasSiblings():Bool
	{
		if (valid(parent))
			return valid(prev) || valid(next);
		return false;
	}
	
	inline public function hasNextSibling():Bool
	{
		return valid(next);
	}
	
	inline public function hasPrevSibling():Bool
	{
		return valid(prev);
	}
	
	inline public function numChildren():Int
	{
		if (hasChildren())
			return 1 + children.numSiblings();
		else
			return 0;
	}
	
	inline public function numSiblings():Int
	{
		var c:Int = 0;
		var node:TreeNode<T>;
		
		node = next;
		while (valid(node))
		{
			c++;
			node = node.next;
		}
		
		node = prev;
		while (valid(node))
		{
			c++;
			node = node.prev;
		}
		
		return c;
	}
	
	inline public function depth():Int
	{
		if (isRoot())
			return 0;
		else
		{
			var node:TreeNode<T> = this, c:Int = 0;
			while (node.hasParent())
			{
				c++;
				node = node.parent;
			}
			return c;
		}
	}
	
	inline public function getLastSibling():TreeNode<T>
	{
		return findTail(this);
	}
	
	inline public function getLastChild():TreeNode<T>
	{
		if (hasChildren())
			return findTail(children);
		else
			return null;
	}
	
	public function preOrder(process:TreeNode<T>->Bool):Void
	{
		if (process(this))
		{
			var child:TreeNode<T> = children;
			while (child != null)
			{
				preOrderInternal(child, process);
				child = child.next;
			}
		}
	}
	
	public function postOrder(process:TreeNode<T>->Bool):Void
	{
		var child:TreeNode<T> = children;
		while (child != null)
		{
			preOrderInternal(child, process);
			child = child.next;
		}
		process(this);
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\n";
		preOrder(function(node:TreeNode<T>):Bool
		{
			var d:Int = node.depth();
			for (i in 0...d)
			{
				if (i == d - 1)
					s += "+---";
				else
					s += "|   ";
			}
			s += node.describe() + "\n";
			return true;
		});
		return s;
		#end
		return describe();
	}
	
	private function describe():String
	{
		var s:String = "{TreeNode";
		
		var flags:String = "";
		if (isRoot())  flags += "R";
		if (isLeaf())  flags += "L";
		if (isChild()) flags += "C";
		s += " " + flags;
		if (numChildren() > 0)
			s += ", children: " + numChildren();
		s += ", depth:" + depth();
		s += ", value: " + val;
		s += "}";
		return s;
	}
	
	private function preOrderInternal(node:TreeNode<T>, process:TreeNode<T>->Bool):Void
	{
		if (process(node))
		{
			if (node.hasChildren())
			{
				var walker:TreeNode<T> = node.children;
				while (walker != null)
				{
					preOrderInternal(walker, process);
					walker = walker.next;
				}
			}
		}
	}
	
	private function postOrderInternal(node:TreeNode<T>, process:TreeNode<T>->Bool):Bool
	{
		if (node.hasChildren())
		{
			var walker:TreeNode<T> = node.children;
			while (walker != null)
			{
				if (!postOrderInternal(walker, process)) break;
				walker = walker.next;
			}
		}
		return process(node);
	}
	
	inline private function valid(node:TreeNode<T>):Bool
	{
		return node != null;
	}
	
	inline private function findTail(node:TreeNode<T>):TreeNode<T>
	{
		while (node.next != null) node = node.next;
		return node;
	}
	
	inline public function assign(val:T):Void
	{
		var process = function(node:TreeNode<T>):Bool
		{
			node.val = val;
			return true;
		}
		preOrder(process);
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		var process = function(node:TreeNode<T>):Bool
		{
			node.val = Type.createInstance(cl, args);
			return true;
		}
		preOrder(process);
	} 
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		var found:Bool = false;
		preOrder(function(node:TreeNode<T>):Bool
		{
			if (node.val == val)
			{
				found = true;
				return false;
			}
			return true;
		});
		return found;
	}
	
	public function clear():Void
	{
		var node:TreeNode<T> = children;
		while (valid(node))
		{
			var hook:TreeNode<T> = node.next;
			
			node.prev = null;
			node.next = null;
			
			node.clear();
			
			node = hook;
		}
	}
	
	public function iterator():Iterator<T>
	{
		return new TreeIterator<T>(this);
	}
	
	public function size():Int
	{
		var c:Int = 1;
		var node:TreeNode<T> = children;
		while (valid(node))
		{
			c += node.size();
			node = node.next;
		}
		return c;
	}
	
	public function isEmpty():Bool
	{
		return hasChildren() == false;
	}
	
	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		var c:Int = 0;
		preOrder(function(node:TreeNode<T>):Bool
		{
			a[c++] = node.val;
			return true;
		});
		return a;
	}
	
	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>();
		var c:Int = 0;
		preOrder(function(node:TreeNode<T>):Bool
		{
			v[c++] = node.val;
			return true;
		});
		return v;
	}
	
	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var stack:Vector<TreeNode<T>> = new Vector<TreeNode<T>>();
		var copy:TreeNode<T> = new TreeNode<T>(copier != null ? copier(val) : val);
		
		stack.push(this);
		stack.push(copy);
		
		var i:Int = 2;
		
		if (copier == null)
		{
			while (i > 0)
			{
				var c = stack[--i];
				var n = stack[--i];
				
				if (n.hasChildren())
				{
					var nchild = n.children;
					var cchild = c.children = new TreeNode<T>(nchild.val, c);
					
					stack[i++] = nchild;
					stack[i++] = cchild;
					
					nchild = nchild.next;
					while (nchild != null)
					{
						cchild.next = new TreeNode<T>(nchild.val, c);
						cchild = cchild.next;
						
						stack[i++] = nchild;
						stack[i++] = cchild;
						
						nchild = nchild.next;
					}
				}
			}
		}
		else
		{
			while (i > 0)
			{
				var c = stack[--i];
				var n = stack[--i];
				
				if (n.hasChildren())
				{
					var nchild = n.children;
					var cchild = c.children = new TreeNode<T>(copier(nchild.val), c);
					
					stack[i++] = nchild;
					stack[i++] = cchild;
					
					nchild = nchild.next;
					while (nchild != null)
					{
						cchild.next = new TreeNode<T>(copier(nchild.val), c);
						cchild = cchild.next;
						
						stack[i++] = nchild;
						stack[i++] = cchild;
						
						nchild = nchild.next;
					}
				}
			}
		}
		
		return cast copy;
	}
}