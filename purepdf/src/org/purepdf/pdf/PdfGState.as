/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfGState.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfGState.as $
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

	/**
	 * Graphic state dictionary
	 *
	 */
	public class PdfGState extends PdfDictionary
	{
		/**
		 * The alpha source flag specifying whether the current soft mask
		 * and alpha constant are to be interpreted as shape values (true)
		 * or opacity values (false).
		 *
		 * @param v
		 */
		public function setAlphaIsShape( v: Boolean ): void
		{
			put( PdfName.AIS, v ? PdfBoolean.PDF_TRUE : PdfBoolean.PDF_FALSE );
		}

		/**
		 * The current blend mode to be used in the transparent imaging model.
		 * 
		 * @param bm
		 * 			Blend Mode
		 * 
		 * @see	prg.purepdf.pdf.PdfBlendMode
		 */
		public function setBlendMode( bm: PdfName ): void
		{
			put( PdfName.BM, bm );
		}

		/**
		 * Sets the current fill opacity
		 *
		 * @param n
		 * 			Number value between 0 and 1
		 */
		public function setFillOpacity( n: Number ): void
		{
			put( PdfName.ca, new PdfNumber( n ) );
		}

		/**
		 * Sets the flag whether to toggle knockout behavior for overprinted objects.
		 * @param ov - accepts 0 or 1
		 */
		public function setOverPrintMode( ov: int ): void
		{
			put( PdfName.OPM, new PdfNumber( ov == 0 ? 0 : 1 ) );
		}

		/**
		 * Sets the flag whether to apply overprint for non stroking painting operations.
		 * @param ov
		 */
		public function setOverPrintNonStroking( ov: Boolean ): void
		{
			put( PdfName.op, ov ? PdfBoolean.PDF_TRUE : PdfBoolean.PDF_FALSE );
		}

		/**
		 * Sets the flag whether to apply overprint for stroking.
		 * @param ov
		 */
		public function setOverPrintStroking( ov: Boolean ): void
		{
			put( PdfName.OP, ov ? PdfBoolean.PDF_TRUE : PdfBoolean.PDF_FALSE );
		}

		/**
		 * Sets the current stroking alpha
		 *
		 * @param n
		 * 			Float value between 0 and 1
		 */
		public function setStrokeOpacity( n: Number ): void
		{
			put( PdfName.CA, new PdfNumber( n ) );
		}

		/**
		 * Determines the behavior of overlapping glyphs within a text object
		 * in the transparent imaging model.
		 * @param v
		 */
		public function setTextKnockout( v: Boolean ): void
		{
			put( PdfName.TK, v ? PdfBoolean.PDF_TRUE : PdfBoolean.PDF_FALSE );
		}
	}
}