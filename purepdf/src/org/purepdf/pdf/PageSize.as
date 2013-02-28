/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PageSize.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PageSize.as $
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
	import flash.utils.describeType;
	
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.elements.ReadOnlyRectangle;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.utils.StringUtils;

	public class PageSize extends ObjectHash
	{
		public static const A0: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 2384, 3370 );
		public static const A1: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1684, 2384 );
		public static const A10: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 73, 105 );
		public static const A2: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1191, 1684 );
		public static const A3: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 842, 1191 );
		public static const A4: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 595, 842 );
		public static const A5: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 420, 595 );
		public static const A6: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 297, 420 );
		public static const A7: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 210, 297 );
		public static const A8: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 148, 210 );
		public static const A9: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 105, 148 );
		public static const ARCH_A: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 648, 864 );
		public static const ARCH_B: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 864, 1296 );
		public static const ARCH_C: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1296, 1728 );
		public static const ARCH_D: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1728, 2592 );
		public static const ARCH_E: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 2592, 3456 );
		public static const B0: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 2834, 4008 );
		public static const B1: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 2004, 2834 );
		public static const B10: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 87, 124 );
		public static const B2: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1417, 2004 );
		public static const B3: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1000, 1417 );
		public static const B4: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 708, 1000 );
		public static const B5: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 498, 708 );
		public static const B6: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 354, 498 );
		public static const B7: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 249, 354 );
		public static const B8: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 175, 249 );
		public static const B9: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 124, 175 );
		public static const CROWN_OCTAVO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 348, 527 );
		public static const CROWN_QUARTO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 535, 697 );
		public static const DEMY_OCTAVO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 391, 612 );
		public static const DEMY_QUARTO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 620, 782 );
		public static const FLSA: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 612, 936 );
		public static const FLSE: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 648, 936 );
		public static const HALFLETTER: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 396, 612 );
		public static const ID_1: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 242.65, 153 );
		public static const ID_2: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 297, 210 );
		public static const ID_3: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 354, 249 );
		public static const LARGE_CROWN_OCTAVO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 365, 561 );
		public static const LARGE_CROWN_QUARTO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 569, 731 );
		public static const LEDGER: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 1224, 792 );
		public static const LETTER: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 612, 792 );
		public static const PENGUIN_LARGE_PAPERBACK: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 365, 561 );
		public static const PENGUIN_SMALL_PAPERBACK: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 314, 513 );
		public static const ROYAL_OCTAVO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 442, 663 );
		public static const ROYAL_QUARTO: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 671, 884 );
		public static const SMALL_PAPERBACK: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 314, 504 );
		public static const _11X17: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 792, 1224 );
		public static const POSTCARD: ReadOnlyRectangle = new ReadOnlyRectangle( 0, 0, 283, 416 );

		/**
		 * Try to return a RectangleElement base on a passed String.
		 * Possible values are the page names: "A4", "LETTER".. 
		 * or value like "800 600"
		 * 
		 */
		public static function getRectangle( name: String ): RectangleElement
		{
			name = StringUtils.trim( name );
			var pos: int = name.indexOf(" ");
			if( pos == -1 )
			{
				var obj: XML = describeType( PageSize );
				if( obj.constant.(@name == name ) )
				{
					return PageSize[name];
				}
			} else {
				var w: String = name.substr( 0, pos );
				var h: String = name.substr( pos + 1 );
				return new RectangleElement( 0, 0, parseFloat( w ), parseFloat( h ) );
			}
			
			return null;
		}
		
		
		
		
		
		
		
		public static function create( pixelsw: int, pixelsh: int ): RectangleElement
		{
			return new ReadOnlyRectangle( 0, 0, pixelsw, pixelsh );
		}
	}
}