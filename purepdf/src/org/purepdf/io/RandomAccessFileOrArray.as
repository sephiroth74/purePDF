/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: RandomAccessFileOrArray.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/io/RandomAccessFileOrArray.as $
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
package org.purepdf.io
{
	import flash.errors.EOFError;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.utils.ByteArrayUtils;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.DoubleUtils;
	import org.purepdf.utils.FloatUtils;

	public class RandomAccessFileOrArray implements IDataInput
	{
		private var _length: int;
		private var _startOffset: int = 0;
		private var arrayIn: ByteArray;
		private var arrayInPtr: int = 0;
		private var back: int;
		private var isBack: Boolean = false;
		private var plainRandomAccess: Boolean = false;

		public function RandomAccessFileOrArray( arrayIn: ByteArray )
		{
			this.arrayIn = arrayIn;
		}
		
		public function close(): void
		{
			isBack = false;
		}
		
		public function reOpen(): void
		{
			var n: ByteArray = new ByteArray();
			n.writeBytes( arrayIn, 0, arrayIn.length );
			arrayIn = n;
			seek(0);
		}

		public function get bytesAvailable(): uint
		{
			return 0;
		}

		public function get endian(): String
		{
			return null;
		}

		public function set endian( type: String ): void
		{
		}

		public function getFilePointer(): uint
		{
			var n: int = isBack ? 1 : 0;
			return arrayInPtr - n - _startOffset;
		}

		public function get length(): int
		{
			return arrayIn.length - _startOffset;
		}

		public function get objectEncoding(): uint
		{
			return 0;
		}

		public function set objectEncoding( version: uint ): void
		{
		}

		public function pushBack( b: int ): void
		{
			back = b;
			isBack = true;
		}

		public function read(): int
		{
			if(isBack) {
				isBack = false;
				return back & 0xff;
			}
			if (arrayInPtr >= arrayIn.length)
				return -1;
			return arrayIn[arrayInPtr++] & 0xff;
		}

		public function readBoolean(): Boolean
		{
			const ch: int = this.read();
			if (ch < 0)
				throw new EOFError();
			return (ch != 0);
		}

		public function readByte(): int
		{
			const ch: int = this.read();
			if (ch < 0)
				throw new EOFError();
			return ByteBuffer.intToByte( ch );
		}

		public function readBytes( bytes: ByteArray, offset: uint = 0, length: uint = 0 ): void
		{
			throw new NonImplementatioError();
		}

		public function readDouble(): Number
		{
			return DoubleUtils.longBitsToDouble(readLong());
		}
		
		public function readDoubleLE(): Number
		{
			return DoubleUtils.longBitsToDouble(readLong());
		}
		
		public function readLong(): uint
		{
			return (readInt() << 32) + ( readInt() & 0xFFFFFFFF );
		}

		public function readFloat(): Number
		{
			return FloatUtils.intBitsToFloat(readInt());
		}
		
		public function readFloatLE(): Number
		{
			return FloatUtils.intBitsToFloat(readIntLE());
		}
		
		public function read1( b: ByteArray, off: uint = 0, len: uint = 0 ): int
		{
			if ( len == 0 )
				return 0;
			
			var n: int = 0;
			if (isBack) {
				isBack = false;
				if (len == 1) {
					b[off] = back;
					return 1;
				}
				else {
					n = 1;
					b[off++] = back;
					--len;
				}
			}
			if (arrayInPtr >= arrayIn.length)
				return -1;
			
			if (arrayInPtr + len > arrayIn.length)
				len = arrayIn.length - arrayInPtr;
			
			// System.arraycopy( arrayIn, arrayInPtr, b, off, len );
			b.position = off;
			b.writeBytes( arrayIn, arrayInPtr, len );
			
			arrayInPtr += len;
			return len + n;
		}

		/**
		 * @throws EOFError
		 */
		public function readFully( b: Bytes, off: int, len: int ): void
		{
			var n: int = 0;
			do
			{
				var count: int = read1( b.buffer, off + n, len - n );
				if ( count < 0 )
					throw new EOFError();
				n += count;
			} while ( n < len );
		}

		public function readInt(): int
		{
			const ch1: int = this.read();
			const ch2: int = this.read();
			const ch3: int = this.read();
			const ch4: int = this.read();
			if ((ch1 | ch2 | ch3 | ch4) < 0)
				throw new EOFError();
			return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + ch4);
		}
		
		public function readIntLE(): int
		{
			const ch1: int = this.read();
			const ch2: int = this.read();
			const ch3: int = this.read();
			const ch4: int = this.read();
			if ((ch1 | ch2 | ch3 | ch4) < 0)
				throw new EOFError();
			return ((ch4 << 24) + (ch3 << 16) + (ch2 << 8) + (ch1 << 0));
		}

		public function readMultiByte( length: uint, charSet: String ): String
		{
			return null;
		}

		public function readObject(): *
		{
			return null;
		}

		public function readShort(): int
		{
			const ch1: int = this.read();
			const ch2: int = this.read();
			if ((ch1 | ch2) < 0)
				throw new EOFError();
			return ((ch1 << 8) + ch2);
		}
		
		public function readShortLE(): int
		{
			const ch1: int = this.read();
			const ch2: int = this.read();
			if ((ch1 | ch2) < 0)
				throw new EOFError();
			return ((ch2 << 8) + (ch1 << 0));
		}

		public function readUTF(): String
		{
			return null;
		}

		public function readUTFBytes( length: uint ): String
		{
			return null;
		}

		public function readUnsignedByte(): uint
		{
			const ch: int = this.read();
			if (ch < 0)
				throw new EOFError();
			return ch;
		}

		/**
		 * Reads an unsigned 32-bit integer from this stream. 
		 * This method reads 4 bytes from the stream, starting at the current stream pointer.
		 * If the bytes read, in order, are <code>b1</code>,
		 * <code>b2</code>, <code>b3</code>, and <code>b4</code>, where
		 * <code>0&nbsp;&lt;=&nbsp;b1, b2, b3, b4&nbsp;&lt;=&nbsp;255</code>,
		 * then the result is equal to:
		 * <blockquote><pre>
		 *     (b1 &lt;&lt; 24) | (b2 &lt;&lt; 16) + (b3 &lt;&lt; 8) + b4
		 * </pre></blockquote>
		 * <p>
		 * This method blocks until the four bytes are read, the end of the
		 * stream is detected, or an exception is thrown.
		 *
		 * @return     the next four bytes of this stream, interpreted as a
		 *             <code>long</code>.
		 * @throws	EOFError
		 */
		public function readUnsignedInt(): uint
		{
			const ch1: uint = this.read();
			const ch2: uint = this.read();
			const ch3: uint = this.read();
			const ch4: uint = this.read();
			if ((ch1 | ch2 | ch3 | ch4) < 0)
				throw new EOFError();
			return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0));
		}
		
		public function readUnsignedIntLE(): uint
		{
			const ch1: uint = this.read();
			const ch2: uint = this.read();
			const ch3: uint = this.read();
			const ch4: uint = this.read();
			if ((ch1 | ch2 | ch3 | ch4) < 0)
				throw new EOFError();
			return ((ch4 << 24) + (ch3 << 16) + (ch2 << 8) + (ch1 << 0));
		}

		public function readUnsignedShort(): uint
		{
			const ch1: int = this.read();
			const ch2: int = this.read();
			if ((ch1 | ch2) < 0)
				throw new EOFError();
			return (ch1 << 8) + ch2;
		}
		
		/**
		 * Reads an unsigned 16-bit number from this stream in little-endian order.
		 * This method reads
		 * two bytes from the stream, starting at the current stream pointer.
		 * If the bytes read, in order, are
		 * <code>b1</code> and <code>b2</code>, where
		 * <code>0&nbsp;&lt;=&nbsp;b1, b2&nbsp;&lt;=&nbsp;255</code>,
		 * then the result is equal to:
		 * <blockquote><pre>
		 *     (b2 &lt;&lt; 8) | b1
		 * </pre></blockquote>
		 * <p>
		 * This method blocks until the two bytes are read, the end of the
		 * stream is detected, or an exception is thrown.
		 *
		 * @return     the next two bytes of this stream, interpreted as an
		 *             unsigned 16-bit integer.
		 * @thorws EOFError
		 */
		public function readUnsignedShortLE(): int
		{
			const ch1: int = this.read();
			const ch2: int = this.read();
			if ((ch1 | ch2) < 0)
				throw new EOFError();
			return (ch2 << 8) + (ch1 << 0);
		}

		/**
		 * 
		 * @throws EOFError
		 */
		public function seek( pos: int ): void
		{
			pos += _startOffset;
			isBack = false;
			arrayInPtr = pos;
		}

		public function get startOffset(): int
		{
			return _startOffset;
		}

		public function set startOffset( value: int ): void
		{
			_startOffset = value;
		}
		
		public function skip( n: uint ): uint
		{
			return skipBytes( n );
		}
		
		public function skipBytes( n: int ): int
		{
			if (n <= 0) 
			{
				return 0;
			}
			
			var adj: int = 0;
			if( isBack )
			{
				isBack = false;
				if (n == 1) {
					return 1;
				} else {
					--n;
					adj = 1;
				}
			}
			
			var pos: int;
			var len: int;
			var newpos: int;
			
			pos = getFilePointer();
			len = length;
			newpos = pos + n;
			
			if (newpos > len) {
				newpos = len;
			}
			seek( newpos );
			return newpos - pos + adj;
		}

		public static function fromFile( file: RandomAccessFileOrArray ): RandomAccessFileOrArray
		{
			var result: RandomAccessFileOrArray = new RandomAccessFileOrArray( file.arrayIn );
			result.startOffset = file.startOffset;
			return result;
		}
	}
}