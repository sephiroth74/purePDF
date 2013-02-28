/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfDestination.as 249 2010-02-02 06:59:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 249 $ $LastChangedDate: 2010-02-02 01:59:26 -0500 (Tue, 02 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfDestination.as $
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
	

	public class PdfDestination extends PdfArray
	{
		public static const XYZ: int = 0;
		public static const FIT: int = 1;
		public static const FITH: int = 2;
		public static const FITV: int = 3;
		public static const FITR: int = 4;
		public static const FITB: int = 5;
		public static const FITBH: int = 6;
		public static const FITBV: int = 7;

		private var _status: Boolean = false;
		
		public function PdfDestination(object:Object=null)
		{
			super(object);
		}
		
		public function addPage( page: PdfIndirectReference ): Boolean
		{
			if (!_status)
			{
				addFirst( page );
				_status = true;
				return true;
			}
			return false;
		}
		
		public function get hasPage(): Boolean
		{
			return _status;
		}
		
		/** 
		 * Constructs a new <code>PdfDestination</code>.
		 * Display the page, with the coordinates (left, top) positioned
		 * at the top-left corner of the window and the contents of the page magnified
		 * by the factor zoom. A negative value for any of the parameters left or top, or a
		 * zoom value of 0 specifies that the current value of that parameter is to be retained unchanged.
		 * 
		 * @param left the left value. Negative to place a null
		 * @param top the top value. Negative to place a null
		 * @param zoom The zoom factor. A value of 0 keeps the current value
		 */
		static public function create2( left: Number, top: Number, zoom: Number ): PdfDestination
		{
			var dest: PdfDestination = new PdfDestination( PdfName.XYZ );
			if (left < 0)
				dest.add( PdfNull.PDFNULL );
			else
				dest.add( new PdfNumber(left) );
			if (top < 0)
				dest.add(PdfNull.PDFNULL);
			else
				dest.add(new PdfNumber(top));
			dest.add(new PdfNumber(zoom));
			return dest;
		}
		
		public static function create( type: int, parameter: Number ): PdfDestination
		{
			var result: PdfDestination = new PdfDestination( new PdfNumber( parameter ) );
			
			switch( type )
			{
				case FITV:
					result.addFirst(PdfName.FITV);
					break;
				
				case FITBH:
					result.addFirst(PdfName.FITBH);
					break;
				
				case FITBV:
					result.addFirst(PdfName.FITBV);
					break;

				default:
					result.addFirst( PdfName.FITH );
					break;
			}
			
			return result;
		}
	}
}