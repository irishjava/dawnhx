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

class VectorTools
{
	inline public static function insert<T>(v:Vector<T>, pos:Int, val:T):Void
	{
		var i:Int = v.length;
		var j:Int = i - 1;
		while (i > pos)
		{
			v[i] = v[j];
			i--;
			j--;
		}
		
		v[pos] = val;
	}
	
	inline public static function remove<T>(a:Vector<T>, val:T):Void
	{
		for (i in 0...a.length)
		{
			if (a[i] == val)
			{
				removeAt(a, i);
				break;
			}
		}
	}
	
	inline public static function removeAt<T>(a:Vector<T>, pos:Int):T
	{
		var val:T = a[pos];
		
		var k:Int = a.length;
		var i:Int = pos + 1;
		var j:Int = pos;
		while (i < k)
		{
			a[j] = a[i];
			i++;
			j++;
		}
		
		a.length--;
		return val;
	}
	
	inline public static function shuffle<T>(v:Vector<T>):Void
	{
		var m = Math;
		var s:Int = v.length, i:Int, t:T;
		while (s > 1)
		{
			s--;
			i = Std.int(m.random() * s);
			t    = v[s];
			v[s] = v[i];
			v[i] = t;
		}
	}
	
	inline public static function assign<T>(v:Vector<T>, val:T, ?args:Array<Dynamic>):Void
	{
		if (Type.getClass(val) != null)
		{
			for (i in 0...v.length)
				v[i] = val;
		}
		else
		{
			var type:String = untyped __typeof__(val);
			if (type == "number" || type == "string" || type == "boolean")
			{
				for (i in 0...v.length)
					v[i] = val;
			}
			else
			if (Type.getClass(val) == null)
			{
				for (i in 0...v.length)
					v[i] = Type.createInstance(untyped val, args);
			}
			else
				throw "unknown type";
		}
	}
	
	inline public static function memmove<T>(v:Vector<T>, destination:Int, source:Int, size:Int):Void
	{
		if (destination + size < source)
		{
			for (i in 0...size)
				v[destination + 1] = v[source + i];
		}
		else
		if (destination > source + size)
		{
			for (i in 0...size)
				v[destination + 1] = v[source + i];
		}
		else
		{
			var t:Vector<T> = new Vector<T>();
			for (i in 0...size)
				t[i] = v[source + i];
			for (i in 0...size)
				v[destination + i] = t[i];
		}
	}
}