/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfRectangle.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfRectangle.as $
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
	import org.purepdf.elements.RectangleElement;
	

	public class PdfRectangle extends PdfArray
	{
		private var llx: Number = 0;
		private var lly: Number = 0;
		private var urx: Number = 0;
		private var ury: Number = 0;
		
		public function PdfRectangle( $llx: Number, $lly: Number, $urx: Number, $ury: Number, rotation: int = 0 )
		{
			super();
			
			if( rotation == 90 || rotation == 270 )
			{
				llx = $lly;
				lly = $llx;
				urx = $ury;
				ury = $urx;
			} else 
			{
				llx = $llx;
				lly = $lly;
				urx = $urx;
				ury = $ury;
			}
			
			super.add( new PdfNumber( llx ) );
			super.add( new PdfNumber( lly ) );
			super.add( new PdfNumber( urx ) );
			super.add( new PdfNumber( ury ) );
		}
		
		public static function createFromRectangle( rect: RectangleElement ): PdfRectangle
		{
			return new PdfRectangle( rect.getLeft(), rect.getBottom(), rect.getRight(), rect.getTop(), 0 );
		}
		
		override public function toString(): String
		{
			return "[" + llx + ", " + lly + ", " + urx + ", " + ury + "]";
		}
		
		public function getRectangle(): RectangleElement
		{
			return new RectangleElement( left, bottom, right, top );
		}
		
		override public function add(object:PdfObject) : uint
		{
			return 0;
		}
		
		public function get left(): Number
		{
			return llx;
		}
		
		public function get right(): Number
		{
			return urx;
		}
		
		public function get top(): Number
		{
			return ury;
		}
		
		public function get bottom(): Number
		{
			return lly;
		}
		
		public function get width(): Number
		{
			return urx - llx;
		}
		
		public function get height(): Number
		{
			return ury - lly;
		}
		
		public function rotate(): PdfRectangle 
		{
			return new PdfRectangle( lly, llx, ury, urx, 0 );
		}
		
		public static function create( rectangle: RectangleElement, rotation: int = 0 ): PdfRectangle
		{
			return new PdfRectangle( rectangle.getLeft(), rectangle.getBottom(), rectangle.getRight(), rectangle.getTop(), rotation );
		}
		
		
	}
}