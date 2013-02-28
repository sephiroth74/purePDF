/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfSpotColor.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfSpotColor.as $
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
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.colors.ExtendedColor;
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.errors.RuntimeError;

	/**
	 * A PdfSpotColor defines a ColorSpace
	 */
	public class PdfSpotColor extends ObjectHash
	{
		public var altcs: RGBColor;
		public var name: PdfName;

		public function PdfSpotColor( color_name: String, alternate_cs: RGBColor )
		{
			name = new PdfName( color_name );
			altcs = alternate_cs;
		}

		/**
		 * @return the alternative colorspace
		 */
		public function get alternativeCS(): RGBColor
		{
			return altcs;
		}

		internal function getSpotObject( writer: PdfWriter ): PdfObject
		{
			var array: PdfArray = new PdfArray( PdfName.SEPARATION );
			array.add( name );
			var func: PdfFunction = null;

			if ( altcs is ExtendedColor )
			{
				var type: int = ExtendedColor( altcs ).type;

				switch ( type )
				{
					case ExtendedColor.TYPE_GRAY:
						array.add( PdfName.DEVICEGRAY );
						func = PdfFunction.type2( writer, Vector.<Number>( [ 0, 1 ] ), null, Vector.<Number>( [ 0 ] ), Vector.<Number>( [ GrayColor( altcs )
							.gray ] ), 1 );
						break;

					case ExtendedColor.TYPE_CMYK:
						array.add( PdfName.DEVICECMYK );
						var cmyk: CMYKColor = CMYKColor( altcs );
						func = PdfFunction.type2( writer, Vector.<Number>( [ 0, 1 ] ), null, Vector.<Number>( [ 0, 0, 0, 0 ] ), Vector
							.<Number>( [ cmyk.cyan, cmyk.magenta, cmyk.yellow, cmyk.black ] ), 1 );
						break;

					default:
						throw new RuntimeError( "only rgb and cmyk are supported" );
				}
			}
			else
			{
				array.add( PdfName.DEVICERGB );
				func = PdfFunction.type2( writer, Vector.<Number>( [ 0, 1 ] ), null, Vector.<Number>( [ 1, 1, 1 ] ), Vector.<Number>( [ Number( altcs
					.red ) / 255, Number( altcs.green ) / 255, Number( altcs.blue ) / 255 ] ), 1 );
			}
			array.add( func.reference );
			return array;
		}
	}
}