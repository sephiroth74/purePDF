/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BarcodeEANSUPP.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/barcode/BarcodeEANSUPP.as $
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
package org.purepdf.pdf.barcode
{
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;

	public class BarcodeEANSUPP extends Barcode
	{
		protected var ean: Barcode;
		protected var supp: Barcode;
		
		public function BarcodeEANSUPP( $ean: Barcode, $supp: Barcode )
		{
			super();
			n = 8;
			ean = $ean;
			supp = $supp;
		}
		
		override public function getBarcodeSize(): RectangleElement
		{
			var rect: RectangleElement = ean.getBarcodeSize();
			rect.setRight( rect.width + supp.getBarcodeSize().width + n );
			return rect;
		}
		
		override public function placeBarcode(cb:PdfContentByte, barColor:RGBColor, textColor:RGBColor):RectangleElement
		{
			if( supp.font != null)
				supp.barHeight = ean.barHeight + supp.baseline - supp.font.getFontDescriptor(BaseFont.CAPHEIGHT, supp.size);
			else
				supp.barHeight = ean.barHeight;
			
			var eanR: RectangleElement = ean.getBarcodeSize();
			cb.saveState();
			ean.placeBarcode(cb, barColor, textColor);
			cb.restoreState();
			cb.saveState();
			cb.concatCTM( 1, 0, 0, 1, eanR.width + n, eanR.height - ean.barHeight );
			supp.placeBarcode(cb, barColor, textColor);
			cb.restoreState();
			return getBarcodeSize();
		}
	}
}