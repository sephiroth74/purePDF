/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Bytes.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/utils/Bytes.as $
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
package org.purepdf.utils
{
	import flash.utils.ByteArray;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import org.purepdf.pdf.ByteBuffer;

	/**
	 * Implementation of a byte[] buffer
	 * which members can be only of primitive type 'byte'
	 *
	 *
	 */
	public class Bytes extends Proxy
	{
		private var buf: ByteArray;

		/**
		 * Construct a new Bytes instance
		 * 
		 * @param value	Possible values are: Number, Array, ByteArray
		 */
		public function Bytes( value: Object=null )
		{
			super();
			buf = new ByteArray();

			if ( value != null )
			{
				if ( value is Number )
				{
					buf.length = value as Number;
				}
				else if ( value is Array )
				{
					for ( var k: int = 0; k < value.length; k++ )
						this[ k ] = value[ k ];
				}
				else if( value is ByteArray )
				{
					buf = ByteArray( value );
				}
			}
		}

		public function get buffer(): ByteArray
		{
			return buf;
		}

		public function set buffer( value: ByteArray ): void
		{
			buf = value;
		}

		public function get length(): uint
		{
			return buf.length;
		}

		public function set length( value: uint ): void
		{
			buf.length = value;
		}

		public function get position(): uint
		{
			return buf.position;
		}

		public function set position( value: uint ): void
		{
			buf.position = value;
		}

		public function readAsString( offset: int=0, len: int=0 ): String
		{
			if ( len == 0 )
				len = length;
			var str: String = "";

			for ( var k: int = 0; k < ( len - offset ); k++ )
			{
				str += String.fromCharCode( this[ k + offset ] );
			}
			trace( "readAsString:", str );
			return str;
		}

		public function toString(): String
		{
			var s: String = "";
			for( var k: int = 0; k < length; ++k )
			{
				s += String.fromCharCode( this[k] );
			}
			return s;
		}

		public function toVector( offset: uint = 0, len: uint = 0 ): Vector.<int>
		{
			if( offset == 0 && len == 0 )
				len = this.length;
			
			var r: Vector.<int> = new Vector.<int>( len );
			
			for ( var k: int = 0; k < len; k++ )
				r[ k ] = this[ k + offset ];
			return r;
		}

		public function writeBytes( buffer: Bytes, offset: uint=0, len: uint=0 ): void
		{
			buf.writeBytes( buffer.buf, offset, len );
		}
		
		public function readIntAtPosition( key: uint ): int
		{
			var current_position: uint = position;
			position = key;
			var value: int = buf.readByte();
			position = current_position;
			return value;
		}
		
		public function writeIntAtPosition( key: uint, value: int ): void
		{
			buf[ key ] = value;
		}

		flash_proxy override function getProperty( key: * ): *
		{
			var current_position: uint = position;
			position = uint( key );
			var value: int = buf.readByte();
			position = current_position;
			return value;
		}

		flash_proxy override function setProperty( name: *, value: * ): void
		{
			buf[ uint( name ) ] = value;
		}
		
		public static function intToByte( value: int ): int
		{
			return ByteBuffer.intToByte( value );
		}
	}
}