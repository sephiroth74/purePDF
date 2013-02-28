/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: CMap.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/resources/CMap.as $
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
package org.purepdf.resources
{
	import flash.utils.ByteArray;

	public class CMap implements ICMap
	{
		[Embed(source="cmaps/Adobe-CNS1-UCS2.cmap", mimeType="application/octet-stream")] 
		public static var Adobe_CNS1_UCS2: Class;
		
		[Embed(source="cmaps/Adobe-GB1-UCS2.cmap", mimeType="application/octet-stream")] 
		public static var Adobe_GB1_UCS2: Class;
		
		[Embed(source="cmaps/Adobe-Japan1-UCS2.cmap", mimeType="application/octet-stream")] 
		public static var Adobe_Japan1_UCS2: Class;
		
		[Embed(source="cmaps/Adobe-Korea1-UCS2.cmap", mimeType="application/octet-stream")] 
		public static var Adobe_Korea1_UCS2: Class;
		
		[Embed(source="cmaps/UniCNS-UCS2-H.cmap", mimeType="application/octet-stream")] 
		public static var UniCNS_UCS2_H: Class;
		
		[Embed(source="cmaps/UniCNS-UCS2-V.cmap", mimeType="application/octet-stream")] 
		public static var UniCNS_UCS2_V: Class;
		
		[Embed(source="cmaps/UniGB-UCS2-H.cmap", mimeType="application/octet-stream")] 
		public static var UniGB_UCS2_H: Class;
		
		[Embed(source="cmaps/UniGB-UCS2-V.cmap", mimeType="application/octet-stream")] 
		public static var UniGB_UCS2_V: Class;
		
		[Embed(source="cmaps/UniJIS-UCS2-H.cmap", mimeType="application/octet-stream")] 
		public static var UniJIS_UCS2_H: Class;
		
		[Embed(source="cmaps/UniJIS-UCS2-HW-H.cmap", mimeType="application/octet-stream")] 
		public static var UniJIS_UCS2_HW_H: Class;
		
		[Embed(source="cmaps/UniJIS-UCS2-V.cmap", mimeType="application/octet-stream")] 
		public static var UniJIS_UCS2_V: Class;
		
		[Embed(source="cmaps/UniKS-UCS2-H.cmap", mimeType="application/octet-stream")] 
		public static var UniKS_UCS2_H: Class;
		
		[Embed(source="cmaps/UniKS-UCS2-V.cmap", mimeType="application/octet-stream")] 
		public static var UniKS_UCS2_V: Class;
		
		private var _chars: Vector.<int>
		
		public function CMap( bytes: ByteArray )
		{
			load( bytes );
		}
		
		public function get chars(): Vector.<int>
		{
			return _chars;
		}
		
		public function load( b: ByteArray ): void
		{
			_chars = new Vector.<int>( 0x10000, true );
			for( var k: int = 0; k < 0x10000; ++k )
				_chars[k] = ( ( b.readUnsignedByte() << 8) + b.readUnsignedByte() );
		}
	}
}