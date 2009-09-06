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

class Bits
{
	inline public static var BIT_01:Int  = 1 << 00;
	inline public static var BIT_02:Int  = 1 << 01;
	inline public static var BIT_03:Int  = 1 << 02;
	inline public static var BIT_04:Int  = 1 << 03;
	inline public static var BIT_05:Int  = 1 << 04;
	inline public static var BIT_06:Int  = 1 << 05;
	inline public static var BIT_07:Int  = 1 << 06;
	inline public static var BIT_08:Int  = 1 << 07;
	inline public static var BIT_09:Int  = 1 << 08;
	inline public static var BIT_10:Int  = 1 << 09;
	inline public static var BIT_11:Int  = 1 << 10;
	inline public static var BIT_12:Int  = 1 << 11;
	inline public static var BIT_13:Int  = 1 << 12;
	inline public static var BIT_14:Int  = 1 << 13;
	inline public static var BIT_15:Int  = 1 << 14;
	inline public static var BIT_16:Int  = 1 << 15;
	inline public static var BIT_17:Int  = 1 << 16;
	inline public static var BIT_18:Int  = 1 << 17;
	inline public static var BIT_19:Int  = 1 << 18;
	inline public static var BIT_20:Int  = 1 << 19;
	inline public static var BIT_21:Int  = 1 << 20;
	inline public static var BIT_22:Int  = 1 << 21;
	inline public static var BIT_23:Int  = 1 << 22;
	inline public static var BIT_24:Int  = 1 << 23;
	inline public static var BIT_25:Int  = 1 << 24;
	inline public static var BIT_26:Int  = 1 << 25;
	inline public static var BIT_27:Int  = 1 << 26;
	inline public static var BIT_28:Int  = 1 << 27;
	inline public static var BIT_29:Int  = 1 << 28;
	inline public static var BIT_30:Int  = 1 << 29;
	inline public static var BIT_31:Int  = 1 << 30;
	inline public static var BIT_32:Int  = 1 << 31;
	inline public static var BIT_ALL:Int = -1;
	
	public var value:Int;
	
	public function new(?val:Int = 0)
	{
		zero();
		set(val);
	}
	
	inline public function get(bit:Int):Bool
	{
		return (value & bit) == bit;
	}
	
	inline public function set(bit:Int):Void
	{
		value |= bit;
	}
	
	inline public function setIf(condition:Bool, bit:Int):Void
	{
		condition ? set(bit) : clr(bit);
	}
	
	inline public function clr(bit:Int):Void
	{
		value = value & ~bit;
	}
	
	inline public function has(bit:Int):Bool
	{
		return (value & bit) != 0;
	}
	
	inline public function flip(bit:Int):Void
	{
		value ^= bit;
	}
	
	inline public function zero():Void
	{
		value = 0;
	}
	
	inline public function setRange(min:Int, max:Int):Void
	{
		#if debug
		if (min > max || min == max) throw "invalid range";
		if (min < 0 || min > 31) throw "min bit out of bounds";
		if (max < 0 || max > 31) throw "max bit out of bounds";
		#end
		
		for (i in min...max + 1) set(1 << (i - 1));
	}
	
	inline public function toString():String
	{
		var t:UInt = value;
		var b:String = '';
		while (t > 0)
		{
			b = (((t & 0x1) > 0) ? '1' : '0') + b;
			t >>>= 1;
		}
		
		var t:UInt = value;
		var h:String = '';
		var r:Int;
		while (t > 0)
		{
			r = t & 15;
			t >>>= 4;
			switch (r)
			{
				case 10: h = 'A' + h;
				case 11: h = 'B' + h;
				case 12: h = 'C' + h;
				case 13: h = 'D' + h;
				case 14: h = 'E' + h;
				case 15: h = 'F' + h;
				default: h = r + h;
			}
		}
		return "{Bits, binary: " + b + ", hex: " + h + "}";
	}
}