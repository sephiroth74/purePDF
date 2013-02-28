/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: TIFFEncoder.as 251 2010-02-02 19:31:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 251 $ $LastChangedDate: 2010-02-02 14:31:26 -0500 (Tue, 02 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/codecs/TIFFEncoder.as $
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
package org.purepdf.codecs
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class TIFFEncoder
	{
		public static const DATA_OFFSET: uint = 180;
		
		public function TIFFEncoder()
		{
		}

		public static function encode( bmp: BitmapData ): ByteArray
		{
			var header: ByteArray = new ByteArray();
			var img: ByteArray = new ByteArray();
			var ifd: ByteArray = new ByteArray();
			var picture: ByteArray = new ByteArray();
			var blue: Number = 0;
			var green: Number = 0;
			var pixel: Number = 0;
			var red: Number = 0;
			header.endian = Endian.LITTLE_ENDIAN;
			header.writeByte( 73 );
			header.writeByte( 73 );
			header.writeShort( 42 );
			header.writeInt( 8 );
			ifd.endian = Endian.LITTLE_ENDIAN;
			ifd.writeShort( 12 );
			ifd.writeShort( 256 );
			ifd.writeShort( 3 );
			ifd.writeInt( 1 );
			ifd.writeInt( bmp.width );
			ifd.writeShort( 257 );
			ifd.writeShort( 3 );
			ifd.writeInt( 1 );
			ifd.writeInt( bmp.height );
			ifd.writeShort( 258 );
			ifd.writeShort( 3 );
			ifd.writeInt( 3 );
			ifd.writeInt( 158 );
			ifd.writeShort( 259 );
			ifd.writeShort( 3 );
			ifd.writeInt( 1 );
			ifd.writeInt( 1 );
			ifd.writeShort( 262 );
			ifd.writeShort( 3 );
			ifd.writeInt( 1 );
			ifd.writeInt( 2 );
			ifd.writeShort( 273 );
			ifd.writeShort( 4 );
			ifd.writeInt( 1 );
			ifd.writeInt( 180 );
			ifd.writeShort( 277 );
			ifd.writeShort( 4 );
			ifd.writeInt( 1 );
			ifd.writeInt( 3 );
			ifd.writeShort( 278 );
			ifd.writeShort( 3 );
			ifd.writeInt( 1 );
			ifd.writeInt( bmp.height );
			ifd.writeShort( 279 );
			ifd.writeShort( 4 );
			ifd.writeInt( 1 );
			ifd.writeInt( bmp.width * bmp.height * 3 );
			ifd.writeShort( 282 );
			ifd.writeShort( 5 );
			ifd.writeInt( 1 );
			ifd.writeInt( 164 );
			ifd.writeShort( 283 );
			ifd.writeShort( 5 );
			ifd.writeInt( 1 );
			ifd.writeInt( 172 );
			ifd.writeShort( 296 );
			ifd.writeShort( 3 );
			ifd.writeInt( 1 );
			ifd.writeInt( 2 );
			ifd.writeInt( 0 );
			ifd.writeShort( 8 );
			ifd.writeShort( 8 );
			ifd.writeShort( 8 );
			ifd.writeInt( 720000 );
			ifd.writeInt( 10000 );
			ifd.writeInt( 720000 );
			ifd.writeInt( 10000 );

			for ( var h: Number = 0; h < bmp.height; h++ )
			{
				for ( var w: Number = 0; w < bmp.width; w++ )
				{
					pixel = bmp.getPixel( w, h );
					red = ( pixel & 0xFF0000 ) >>> 16;
					green = ( pixel & 0x00FF00 ) >>> 8;
					blue = pixel & 0x0000FF;
					picture.writeByte( red );
					picture.writeByte( green );
					picture.writeByte( blue );
				}
			}
			img.writeBytes( header );
			img.writeBytes( ifd );
			img.writeBytes( picture );
			return img;
		}
	}
}