/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ByteBuffer.as 240 2010-02-01 10:53:22Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 240 $ $LastChangedDate: 2010-02-01 05:53:22 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/ByteBuffer.as $
*
* The contents of this file are subject to  LGPL license 
* (the "GNU LIBRARY GENERAL PUBLIC LICENSE"), in which case the
* provisions of LGPL are applicable instead of those above.  If you wish to
* allow use of your version of this file only under the terms of the LGPL
* License and not to allow others to use your version of this file under
* the MPL, indicate your decision by deleting the provisions above and
* replace them with the notice and other provisions required by the LGPL.
* If you do not delete the provisions above, a recipient may use your version
* of this file under either the MPL or the GNU LIBRARY GENERAL PUBLIC LICENSE
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the License.
*
* The Original Code is 'iText, a free JAVA-PDF library' ( version 4.2 ) by Bruno Lowagie.
* All the Actionscript ported code and all the modifications to the
* original java library are written by Alessandro Crugnola (alessandro@sephiroth.it)
*
* This library is free software; you can redistribute it and/or modify it
* under the terms of the MPL as stated above or under the terms of the GNU
* Library General Public License as published by the Free Software Foundation;
* either version 2 of the License, or any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU LIBRARY GENERAL PUBLIC LICENSE for more
* details
*
* If you didn't download this code from the following link, you should check if
* you aren't using an obsolete version:
* http://code.google.com/p/purepdf
*
*/
package org.purepdf.pdf
{
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.NumberUtils;
	import org.purepdf.utils.pdf_core;
	
	public class ByteBuffer implements IOutputStream
	{
		private static var byteCacheSize: int = 0;
		private static var byteCache: Vector.<Bytes> = new Vector.<Bytes>();
		private static const chars: Vector.<String> = Vector.<String>(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);
		private static const bytes: Bytes = new Bytes( [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102] );

		public static const ZERO: int = 48;
		public static const SEPARATOR: int = 10;
		
		protected var count: int;
		protected var buf: Bytes;
		
		use namespace pdf_core;
		
		public function ByteBuffer()
		{
			buf = new Bytes();
		}
		
		public function reset(): void
		{
			count = 0;
		}
		
		/**
		 * Creates a newly allocated byte array. Its size is the current
		 * size of this output stream and the valid contents of the buffer
		 * have been copied into it.
		 *
		 * @return  the current contents of this output stream, as a byte array.
		 */
		public function toByteArray(): Bytes
		{
			var newbuf: Bytes = new Bytes();
			newbuf.writeBytes( buf, 0, count );
			return newbuf;
		}
		
		public function getBuffer(): ByteArray
		{
			return buf.buffer;
		}
		
		public function get size(): int
		{
			return count;
		}
		
		public function set size( value: int ): void
		{
			if( value > count || value < 0 )
			{
				throw IllegalOperationError("the new size must be positive and <= the current size");
			}
			count = value;
		}
		
		public function toString(): String
		{
			var res: String = "";
			for( var a: int = 0; a < count; a++ )
			{
				res += String.fromCharCode( buf[a] );
			}
			return res;
		}
		
		public function appendHex( b: int ): ByteBuffer
		{
			append_byte( bytes[(b >> 4) & 0x0f] );
			return append_byte( bytes[b & 0x0f] );
		}
		
		/**
		 * Appends an <CODE>int</CODE>. The size of the array will grow by one.
		 * @param b the int to be appended
		 * @return a reference to this <CODE>ByteBuffer</CODE> object
		 */
		pdf_core function append_int( b: int ): ByteBuffer
		{
			var newcount: int = count + 1;
			
			/*if( newcount > buf.length )
			{
				var newbuf: Bytes = new Bytes();
				newbuf.writeBytes( buf, 0, count );
				buf = newbuf;
			}*/
			
			buf[count] = b;
			count = newcount;
			return this;
		}
		
		/**
		 * Append one char to the array
		 */
		public function append_char( value: String ): ByteBuffer
		{
			return append_int( value.charCodeAt( 0 ) );
		}
		
		public function append_separator(): ByteBuffer
		{
			return append_int( SEPARATOR );
		}
		
		public function append_string( str: String): ByteBuffer
		{
			if (str != null)
				return append_bytes( PdfWriter.getISOBytes( str ) );
			return this;
		}
		
		/**
		 * Append a generic object to the current content
		 * @param value	only String or int are allowed here
		 * 
		 */
		public function append( value: * ): ByteBuffer
		{
			if( value is String )
				return append_string( value );
			else if( NumberUtils.is_int( value ) )
				return append_number( Number( value ) );
			else throw new Error("Only string and int allowed");
		}
		
		public function append_byte( b: int ): ByteBuffer {
			return append_int( b );
		}
		
		public function append_bytes( b: Bytes, off: int = 0, len: int = 0 ): ByteBuffer
		{
			if( len == 0 ) len = b.length;
			
			if ((off < 0) || (off > b.length) || (len < 0) || ((off + len) > b.length) || ((off + len) < 0) || len == 0)
				return this;
			
			var newcount: int = count + len;
			var a: int;
			
			/*if( newcount > buf.length )
			{
				var newbuf: Bytes = new Bytes();
				newbuf.writeBytes( buf, 0, count );
				buf = newbuf;
			}*/
			
			for( a = 0; a < len; a++ )
			{
				buf[count+a] = b[off+a];
			}
			
			count = newcount;
			return this;
		}
		
		/**
		 * Appends another <CODE>ByteBuffer</CODE> to this buffer.
		 * @param buf the <CODE>ByteBuffer</CODE> to be appended
		 */
		public function append_bytebuffer( buf: ByteBuffer ): ByteBuffer
		{
			return append_bytearray( buf.getBuffer(), 0, buf.count );
		}
		
		public function append_bytearray( b: ByteArray, off: int = 0, len: int = 0 ): ByteBuffer
		{
			if( len == 0 ) len = b.length;
			
			if ((off < 0) || (off > b.length) || (len < 0) ||
				((off + len) > b.length) || ((off + len) < 0) || len == 0)
				return this;
			
			var newcount: int = count + len;
			/*
			if( newcount > buf.length )
			{
				var newbuf: Bytes = new Bytes();
				newbuf.writeBytes( buf, 0, count );
				buf = newbuf;
			}
			*/
			for( var a: int = 0; a < len; a++ )
			{
				buf[count+a] = b[off+a];
			}
			
			count = newcount;
			return this;
		}
		
		public function append_number( value: Number ): ByteBuffer
		{
			if( isNaN( value ) ) throw new IllegalOperationError("value cannot be NaN");
			
			// TODO: check if it's better to formatDouble the passed number or use Number.toFixed
			append_string( formatDouble( value, this ) );
			return this;
		}
		
		public static function formatDouble( d: Number, buf: ByteBuffer = null ): String
		{
			var negative: Boolean = false;
			var v: int;
			var res: String;
			
			if( Math.abs(d) < 0.000015 )
			{
				if( buf != null )
				{
					buf.append_byte( ZERO );
					return null;
				} else {
					return "0";
				}
			}
			
			if( d < 0 )
			{
				negative = true;
				d = -d;
			}
			
			if( d < 1.0 )
			{
				d += 0.000005;
				if( d >= 1 )
				{
					if( negative )
					{
						if( buf != null )
						{
							buf.append_int( 45 );	// '-'
							buf.append_int( 49 );	// '1'
							return null;
						} else {
							return "-1";
						}
					} else {
						if( buf != null ) {
							buf.append_int( 49 );	// '1'
							return null;
						} else {
							return "1";
						}
					}
				}
			
				if( buf != null )
				{
					v = int(d*100000);
					if( negative )
						buf.append_int( 45 );	// '-'
					buf.append_int( 48 );	// '0'
					buf.append_int( 46 );	// '.'
					
					buf.append_int( intToByte( int(v / 10000) + ZERO ) );
					if( v % 10000 != 0 )
					{
						buf.append_int( intToByte( int(v/1000)%10 + ZERO) );
						if( v % 1000 != 0 )
						{
							buf.append_int( intToByte( int(v/100)%10 + ZERO ) );
							if( v % 100 != 0 )
							{
								buf.append_int( intToByte( int(v/10)%10 + ZERO ) );
								if( v % 10 != 0 )
								{
									buf.append_int( intToByte( int( v )%10 + ZERO ) );
								}
							}
						}
					}
					return null;
				} else {
					var x: int = 100000;
					v = d*x;
					res = "";
					if( negative ) res += "-";
					
					res += "0.";
					
					while( v < x/10 ) {
						res += "0";
						x /= 10;
					}
					
					res += v;
					var cut: int = res.length - 1;
					while( res.charAt( cut ) == '0' )
					{
						--cut;
					}
					res = res.substr( 0, cut + 1 );
					return res;
				}
			} else if( d <= 32767 )
			{
				d += 0.005;
				v = d*100;
				
				if( v < byteCacheSize && byteCache[v] != null )
				{
					if( buf != null )
					{
						if( negative ) buf.append_int( 45 );	// '-'
						buf.append_bytes( byteCache[v] );
						return null;
					} else {
						var tmp: String = PdfEncodings.convertToString( byteCache[v], null );
						if( negative ) tmp = "-" + tmp;
						return tmp;
					}
				}
				
				if( buf != null )
				{
					if (v < byteCacheSize) {
						var cache: Bytes = new Bytes();
						var size: int = 0;
						if (v >= 1000000) {
							size += 5;
						} else if (v >= 100000) {
							size += 4;
						} else if (v >= 10000) {
							size += 3;
						} else if (v >= 1000) {
							size += 2;
						} else if (v >= 100) {
							size += 1;
						}
						
						if (v % 100 != 0) {
							size += 2;
						}
						if (v % 10 != 0) {
							size++;
						}
						
						cache = new Vector.<int>( size );
						var add: int = 0;
						if (v >= 1000000)
						{
							cache[add++] = bytes[int(v / 1000000)];
						}
						
						if (v >= 100000) {
							cache[add++] = bytes[int(v / 100000) % 10];
						}
						if (v >= 10000) {
							cache[add++] = bytes[int(v / 10000) % 10];
						}
						if (v >= 1000) {
							cache[add++] = bytes[int(v / 1000) % 10];
						}
						if (v >= 100) {
							cache[add++] = bytes[int(v / 100) % 10];
						}
						
						if (v % 100 != 0) {
							cache[add++] = 46;	// '.'
							cache[add++] = bytes[int(v / 10) % 10];
							if (v % 10 != 0) {
								cache[add++] = bytes[v % 10];
							}
						}
						byteCache[v] = cache;
					}
					
					if (negative) buf.append_int( 45 );	// '-'
					if (v >= 1000000) {
						buf.append_int( bytes[int(v / 1000000)] );
					}
					if (v >= 100000) {
						buf.append_int( bytes[int(v / 100000) % 10] );
					}
					if (v >= 10000) {
						buf.append_int( bytes[int(v / 10000) % 10] );
					}
					if (v >= 1000) {
						buf.append_int( bytes[int(v / 1000) % 10] );
					}
					if (v >= 100) {
						buf.append_int( bytes[int(v / 100) % 10] );
					}
					
					if (v % 100 != 0) {
						buf.append_int( 46 );	// '.'
						buf.append_int( bytes[int(v / 10) % 10] );
						if (v % 10 != 0) {
							buf.append_int( bytes[v % 10] );
						}
					}
					return null;
					
				} else {
					res = "";
					if (negative) res += "-";
					
					if (v >= 1000000) {
						res += ( chars[int(v / 1000000)] );
					}
					if (v >= 100000) {
						res += ( chars[int(v / 100000) % 10] );
					}
					if (v >= 10000) {
						res += ( chars[int(v / 10000) % 10] );
					}
					if (v >= 1000) {
						res += ( chars[int(v / 1000) % 10] );
					}
					if (v >= 100) {
						res += ( chars[int(v / 100) % 10] );
					}
					
					if (v % 100 != 0) 
					{
						res += '.';
						res += ( chars[int(v / 10) % 10] );
						if (v % 10 != 0) {
							res += ( chars[v % 10] );
						}
					}
					return res;
				}
					
			} else
			{
				res = "";
				if (negative) res += '-';
				d += 0.5;
				res += d;
				return res;
			}
		}
		
		public function writeInt( value: int ): void
		{
			append_byte( intToByte( value ) );
		}
		
		public function writeBytes( value: Bytes, off: int = 0, len: int = 0 ): void
		{
			append_bytes( value, off, len );
		}
		
		public function writeByteArray( value: ByteArray, off: int = 0, len: int = 0 ): void
		{
			append_bytearray( value, off, len );
		}
		
		/**
		 * Writes the complete contents of this byte buffer output to
		 * the specified output stream argument, as if by calling the output
		 * stream's write method using <code>out.write(buf, 0, count)</code>.
		 *
		 * @param      out   the output stream to which to write the data.
		 */
		public function writeTo( out: ByteArray ): void
		{
			out.writeBytes( buf.buffer, 0, count );
		}
		
		public static const BYTE_MAX_VALUE: int = 127;
		public static const BYTE_MIN_VALUE: int = -128;
		
		public static function intToByte( value: int ): int
		{
			if( value >= BYTE_MIN_VALUE && value <= BYTE_MAX_VALUE )
				return value;
			
			var r: int = value%128;
			var neg: Boolean = value < 0;
			
			if( neg )
				return r;
			else
				return r - 128;
		}

	}
}