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

import flash.utils.Dictionary;
import flash.Vector;

class HashMap<K, V>
{
	private var _map:Dictionary;
	private var _weakKeys:Bool;
	
	public function new(?weak:Bool = false)
	{
		_map = new Dictionary(_weakKeys = weak);
	}
	
	inline public function get(key:K):V
	{
		return untyped _map[key];
	}
	
	inline public function set(key:K, val:V):Void
	{
		untyped _map[key] = val;
	}
	
	inline public function setIfAbsent(key:K, val:V):Bool
	{
		if (has(key))
			return false;
		else
		{
			set(key, val);
			return true;
		}
	}
	
	inline public function setAll(h:HashMap<K, V>):Void
	{
		for (i in h) set(i, h.get(i));
	}
	
	inline public function has(key:K):Bool
	{
		return untyped _map[key] != null;
	}
	
	inline public function remove(key:K):Void
	{
		untyped __delete__(_map, key);
	}
	
	inline public function removeIfExists(key:K):Bool
	{
		if (!has(key))
			return false;
			else
		{
			remove(key);
			return true;
		}
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nHashMap\n{\n";
		var i:Iterator<K> = iterator();
		for (key in i)
			s += "\t" + key + " -> " + get(key) + "\n";
		return s + "}\n";
		#else
		return "{HashMap}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:V):Bool
	{
		for (i in this)
		{
			if (get(i) == val)
			return true;
		}
		
		return false;
	}
	
	public function clear():Void
	{
		for (key in this) remove(key);
		_map = new Dictionary(_weakKeys);
	}
	
	inline public function iterator():Iterator<K>
	{
		return untyped __keys__(_map).iterator();
	}
	
	public function size():Int
	{
		var c:Int = 0;
		for (i in this) c++;
		return c;
	}

	public function isEmpty():Bool
	{
		return size() == 0;
	}

	public function toArray():Array<K>
	{
		var a:Array<K> = new Array<K>();
		var i:Int = 0;
		for (val in this) a[i++] = val;
		return a;
	}

	public function toVector():Vector<K>
	{
		var v:Vector<K> = new Vector<K>(size(), true);
		var i:Int = 0;
		for (val in this) v[i++] = val;
		return v;
	}

	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone(copier:V->V):HashMap<K, V>
	{
		var copy:HashMap<K, V> = new HashMap<K, V>(_weakKeys);
		if (copier == null)
		{
			for (i in this)
				copy.set(i, untyped _map[i]);
		}
		else
		{
			for (i in this)
				copy.set(i, copier(untyped _map[i]));
		}
		
		return copy;
	}
}