/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfFont.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfFont.as $
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
	
	import org.purepdf.IComparable;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.fonts.BaseFont;

	public class PdfFont extends ObjectHash implements IComparable
	{
		private var _font: BaseFont;
		private var _hScale: Number = 1;
		private var _image: ImageElement;
		private var _size: Number;

		public function PdfFont( $bf: BaseFont, $size: Number )
		{
			super();
			_size = $size;
			_font = $bf;
		}

		public function compareTo( o: Object ): int
		{
			if ( _image != null )
				return 0;

			if ( o == null )
				return -1;

			var pdfFont: PdfFont;

			try
			{
				pdfFont = PdfFont( o );
				if ( _font != pdfFont.font )
					return 1;

				if ( size != pdfFont.size )
					return 2;

				return 0;
			}
			catch ( cce: Error )
			{
				return -2;
			}

			return -2;
		}

		public function get font(): BaseFont
		{
			return _font;
		}

		/**
		 * @param char. Possible values are int, String
		 */
		public function getWidth( char: Object = 32 ): Number
		{
			if ( _image == null )
				return font.getWidthPoint( char, _size ) * _hScale;
			return _image.scaledWidth;
		}
		
		public function get width(): Number
		{
			return getWidth();
		}

		public function set image( value: ImageElement ): void
		{
			_image = value;
		}

		public function get size(): Number
		{
			if ( _image == null )
				return _size;
			return _image.scaledHeight;
		}

		internal function set horizontalScaling( value: Number ): void
		{
			_hScale = value;
		}

		internal static function getDefaultFont(): PdfFont
		{
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false );
			return new PdfFont( bf, 12 );
		}
	}
}