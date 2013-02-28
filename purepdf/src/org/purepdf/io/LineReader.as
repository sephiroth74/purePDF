/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: LineReader.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/io/LineReader.as $
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
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	public class LineReader implements IDataInput
	{
		private var data: ByteArray;
		
		public function LineReader( input: ByteArray )
		{
			data = input;
		}
		
		public function readLine(): String
		{
			var input: String = "";
			var c: int = -1;
			var eol: Boolean = false;
			
			while( !eol )
			{
				switch( c = read() )
				{
					case -1:
					case 10:
						eol = true;
						break;
					
					case 13:
						eol = true;
						var cur: uint = data.position;
						if( read() != 10 )
							data.position = cur;
						break;
					
					default:
						input += String.fromCharCode( c );
						break;
				}
			}
			
			if( c == -1 && input.length == 0 )
				return null;
			
			return input;
		}
		
		public function read(): int
		{
			if( data.bytesAvailable )
				return data[ data.position++ ] & 0xFF;
			return -1;
		}
		
		public function readBytes(bytes:ByteArray, offset:uint=0, length:uint=0):void
		{
			data.readBytes( bytes, offset, length );
		}
		
		public function readBoolean():Boolean
		{
			return data.readBoolean();
		}
		
		public function readByte():int
		{
			return data.readByte();
		}
		
		public function readUnsignedByte():uint
		{
			return data.readUnsignedByte();
		}
		
		public function readShort():int
		{
			return data.readShort();
		}
		
		public function readUnsignedShort():uint
		{
			return data.readUnsignedShort();
		}
		
		public function readInt():int
		{
			return data.readInt();
		}
		
		public function readUnsignedInt():uint
		{
			return data.readUnsignedInt();
		}
		
		public function readFloat():Number
		{
			return data.readFloat();
		}
		
		public function readDouble():Number
		{
			return data.readDouble();
		}
		
		public function readMultiByte(length:uint, charSet:String):String
		{
			return data.readMultiByte( length, charSet );
		}
		
		public function readUTF():String
		{
			return data.readUTF();
		}
		
		public function readUTFBytes(length:uint):String
		{
			return data.readUTFBytes( length );
		}
		
		public function get bytesAvailable():uint
		{
			return data.bytesAvailable;
		}
		
		public function readObject():*
		{
			return data.readObject();
		}
		
		public function get objectEncoding():uint
		{
			return data.objectEncoding;
		}
		
		public function set objectEncoding(version:uint):void
		{
			data.objectEncoding = version;
		}
		
		public function get endian():String
		{
			return data.endian;
		}
		
		public function set endian(type:String):void
		{
			data.endian = type;
		}
	}
}