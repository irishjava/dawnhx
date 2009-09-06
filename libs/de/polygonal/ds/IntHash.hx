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

class IntHash
{
	public static var NULL_VALUE:Int = (1 << 31) - 1;
	
	private var _hashTable:Vector<IntNode>;
	private var _size:Int;
	private var _mask:Int;
	
	#if debug
	public var collisions:Int;
	#end
	
	public function new(size:Int)
	{
		#if debug
		if (size > 0 && (size & (size - 1)) != 0)
			throw "size not power of 2";
		collisions = 0;
		#end
		
		_size = 0;
		_mask = size - 1;
		_hashTable = new Vector<IntNode>(size, true);
	}
	
	inline public function get(key:Int):Int
	{
		var n:IntNode = _hashTable[hash(key)];
		if (n == null)
			return NULL_VALUE;
		else
		if (n.i == key)
			return n.val;
		else
		{
			var val:Int = NULL_VALUE;
			var walker:IntNode = n.next;
			while (walker != null)
			{
				if (walker.i == key)
				{
					val = walker.val;
					break;
				}
				walker = walker.next;
			}
			return val;
		}
	}
	
	inline public function set(key:Int, val:Int):Void
	{
		var h:Int = hash(key);
		var n:IntNode = _hashTable[h];
		if (n == null)
		{
			n = new IntNode();
			n.i = key;
			n.val = val;
			_hashTable[h] = n;
			_size++;
		}
		else
		{
			var walker:IntNode = n;
			while (true)
			{
				if (walker == null)
				{
					var t:IntNode = n;
					n = new IntNode();
					n.i = key;
					n.val = val;
					n.next = t;
					_hashTable[h] = n;
					_size++;
					#if debug
					collisions++;
					#end
					break;
				}
				
				if (walker.i == key)
				{
					walker.val = val;
					break;
				}
				
				walker = walker.next;
			}
		}
	}
	
	inline public function has(key:Int):Bool
	{
		var h:Int = hash(key);
		var n:IntNode = _hashTable[h];
		
		if (n == null)
			return false;
		else
		if (n.i == key)
			return true;
		else
		{
			var walker:IntNode = n.next;
			var found:Bool = false;
			while (walker != null)
			{
				if (walker.i == key)
				{
					found = true;
					break;
				}
				walker = walker.next;
			}
			return found;
		}
	}
	
	inline public function del(key:Int):Void
	{
		var h:Int = hash(key);
		var n:IntNode = _hashTable[h];
		if (n == null)
			return;
		else
		if (n.i == key)
		{
			_hashTable[h] = n.next;
			_size--;
		}
		else
		{
			var walker:IntNode = n;
			while (walker.next != null)
			{
				if (walker.next.i == key)
				{
					walker.next = walker.next.next;
					_size--;
					#if debug
					collisions--;
					#end
					break;
				}
				walker = walker.next;
			}
		}
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	//public function contains(val:V):Bool
	//{
		//for (i in this)
		//{
			//if (get(i) == val)
			//return true;
		//}
		//
		//return false;
	//}
	
	public function clear():Void
	{
		//for (key in this) remove(key);
		//_map = new Dictionary(_weakKeys);
	}
	
	//inline public function iterator():Iterator<K>
	//{
		//return untyped __keys__(_map).iterator();
	//}
	
	public function size():Int
	{
		return _size;
	}

	public function isEmpty():Bool
	{
		return size() == 0;
	}

	//public function toArray():Array<K>
	//{
		//var a:Array<K> = new Array<K>();
		//var i:Int = 0;
		//for (val in this) a[i++] = val;
		//return a;
	//}
//
	//public function toVector():Vector<K>
	//{
		//var v:Vector<K> = new Vector<K>(size(), true);
		//var i:Int = 0;
		//for (val in this) v[i++] = val;
		//return v;
	//}

	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	//public function clone(copier:V->V):IntHash<Int, V>
	//{
		//return null;
	//}
	
	
	
	inline private function hash(key:Int):Int
	{
		return untyped (key * 73856093) & _mask;
	}
	
	public function toString():String
	{
		//#if debug
		//var s:String = "\nHashMap\n{\n";
		//var i:Iterator<K> = iterator();
		//for (key in i)
			//s += "\t" + key + " -> " + get(key) + "\n";
		//return s + "}\n";
		//#else
		return "{IntHash}";
		//#end
	}
}

class IntNode
{
	public var next:IntNode;
	
	public var i:Int;
	public var val:Int;
	
	public function new() {}
}