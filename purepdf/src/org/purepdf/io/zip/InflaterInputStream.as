/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: InflaterInputStream.as 386 2011-01-12 14:05:20Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 386 $ $LastChangedDate: 2011-01-12 09:05:20 -0500 (Wed, 12 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/io/zip/InflaterInputStream.as $
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
package org.purepdf.io.zip
{
	import com.wizhelp.fzlib.FZlib;
	import com.wizhelp.fzlib.ZStream;
	
	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	
	import org.purepdf.errors.IndexOutOfBoundsError;
	import org.purepdf.errors.NullPointerError;
	import org.purepdf.io.FilterInputStream;
	import org.purepdf.io.InputStream;
	import org.purepdf.utils.Bytes;

	public class InflaterInputStream extends FilterInputStream
	{
		// track the current input index
		// this fixed the bug with transparent PNG images
		private var next_index: int;
		
		protected var buf: Bytes;
		protected var c_stream: ZStream;
		protected var len: int;
		private var closed: Boolean = false;
		private var reachEOF: Boolean = false;
		private var singleByteBuf: Bytes = new Bytes();
		private var usesDefaultInflater: Boolean = false;

		public function InflaterInputStream( stream: InputStream )
		{
			super( stream );
			singleByteBuf.length = 1;
			init( stream, stream.size );
		}
		
		private function init( stream: InputStream, size: int ): void
		{
			if ( stream == null )
				throw new NullPointerError();
			else if ( size <= 0 )
				throw new IllegalOperationError( "buffer size <= 0" );
			
			next_index = 0;
			buf = new Bytes( size );
			stream.readBytes( buf.buffer, 0, size );
			
			c_stream = new ZStream();
			c_stream.next_in = buf.buffer;
			c_stream.next_in_index = 0;
			c_stream.next_out = new Bytes();
			c_stream.next_out_index = 0;
			var err: int = c_stream.inflateInit();
			CHECK_ERR( c_stream, err, "inflateInit" );
		}

		override public function readBytes( b: ByteArray, off: int, len: int ): int
		{
			ensureOpen();
			if ( b == null )
				throw new NullPointerError();
			else if ( off < 0 || len < 0 || len > b.length - off )
				throw new IndexOutOfBoundsError();
			else if ( len == 0 )
				return 0;
			
			c_stream.avail_in = buf.length;
			c_stream.avail_out = len;
			c_stream.next_in_index = next_index;
			c_stream.next_out_index = 0;
			c_stream.next_out = b;
			
			var err: int = c_stream.inflate( FZlib.Z_NO_FLUSH );
			next_index = c_stream.next_in_index;
			CHECK_ERR( c_stream, err, c_stream.msg );
			
			return c_stream.total_out;
		}

		override public function readUnsignedByte(): int
		{
			ensureOpen();
			
			c_stream.avail_in = buf.length;
			c_stream.avail_out = 1;
			c_stream.next_in_index = next_index;
			c_stream.next_out_index = 0;
			c_stream.next_out = singleByteBuf;
			var err: int = c_stream.inflate( FZlib.Z_NO_FLUSH );
			CHECK_ERR( c_stream, err, c_stream.msg );
			next_index = c_stream.next_in_index;
			
			return c_stream.total_out == 0 ? -1 : singleByteBuf[ 0 ] & 0xFF;
		}

		private function ensureOpen(): void
		{
			if ( closed )
				throw new IOError( "stream closed" );
		}
		
		static protected function CHECK_ERR( z: ZStream, err: int, msg: String ): void
		{
		}
	}
}