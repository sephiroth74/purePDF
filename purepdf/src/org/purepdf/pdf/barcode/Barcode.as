/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Barcode.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/barcode/Barcode.as $
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
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.pdf_core;

	[Abstract]
	public class Barcode
	{
		public static const EAN13: int = 1;
		public static const EAN8: int = 2;
		public static const UPCA: int = 3;
		public static const UPCE: int = 4;
		public static const SUPP2: int = 5;
		public static const SUPP5: int = 6;
		public static const POSTNET: int = 7;
		public static const PLANET: int = 8;
		public static const CODE128: int = 9;
		public static const CODE128_UCC: int = 10;
		public static const CODE128_RAW: int = 11;
		public static const CODABAR: int = 12;
		public static const CODE39: int = 13;
		
		protected var _x: Number;    
		protected var _n: Number;
		protected var _font: BaseFont;
		protected var _size: Number;
		protected var _baseline: Number;
		protected var _barHeight: Number;
		protected var _textAlignment: int;
		protected var _generateChecksum: Boolean;
		protected var _checksumText: Boolean;
		protected var _startStopText: Boolean;
		protected var _extended: Boolean;
		protected var _code: String = "";
		protected var _guardBars: Boolean;
		protected var _codeType: int;
		protected var _inkSpreading: Number = 0;
		protected var _altText: String;
		
		use namespace pdf_core;
		
		[Abstract]
		public function getBarcodeSize(): RectangleElement
		{
			throw new NonImplementatioError();
		}
		
		[Abstract]
		public function placeBarcode( cb: PdfContentByte, barColor: RGBColor, textColor: RGBColor ): RectangleElement
		{
			throw new NonImplementatioError();
		}
		
		public function createTemplateWithBarcode( cb: PdfContentByte, barColor: RGBColor, textColor: RGBColor ): PdfTemplate
		{
			var tp: PdfTemplate = cb.createTemplate( 0, 0 );
			var rect: RectangleElement = placeBarcode( tp, barColor, textColor );
			tp.boundingBox = rect;
			return tp;
		}
		
		public function createImageWithBarcode( cb: PdfContentByte, barColor: RGBColor, textColor: RGBColor ): ImageElement
		{
			try 
			{
				return ImageElement.getTemplateInstance( createTemplateWithBarcode( cb, barColor, textColor ) );
			}
			catch( e: Error ) {
				trace( e.getStackTrace() );
				throw new ConversionError( e );
			}
			return null;
		}

		public function get altText():String
		{
			return _altText;
		}

		public function set altText(value:String):void
		{
			_altText = value;
		}

		public function get inkSpreading():Number
		{
			return _inkSpreading;
		}

		public function set inkSpreading(value:Number):void
		{
			_inkSpreading = value;
		}

		public function get codeType():int
		{
			return _codeType;
		}

		public function set codeType(value:int):void
		{
			_codeType = value;
		}

		public function get guardBars():Boolean
		{
			return _guardBars;
		}

		public function set guardBars(value:Boolean):void
		{
			_guardBars = value;
		}

		public function get code():String
		{
			return _code;
		}

		public function set code(value:String):void
		{
			_code = value;
		}

		public function get extended():Boolean
		{
			return _extended;
		}

		public function set extended(value:Boolean):void
		{
			_extended = value;
		}

		public function get startStopText():Boolean
		{
			return _startStopText;
		}

		public function set startStopText(value:Boolean):void
		{
			_startStopText = value;
		}

		public function get checksumText():Boolean
		{
			return _checksumText;
		}

		public function set checksumText(value:Boolean):void
		{
			_checksumText = value;
		}

		public function get generateChecksum():Boolean
		{
			return _generateChecksum;
		}

		public function set generateChecksum(value:Boolean):void
		{
			_generateChecksum = value;
		}

		public function get textAlignment():int
		{
			return _textAlignment;
		}

		public function set textAlignment(value:int):void
		{
			_textAlignment = value;
		}

		public function get barHeight():Number
		{
			return _barHeight;
		}

		public function set barHeight(value:Number):void
		{
			_barHeight = value;
		}

		public function get baseline():Number
		{
			return _baseline;
		}

		public function set baseline(value:Number):void
		{
			_baseline = value;
		}

		public function get size():Number
		{
			return _size;
		}

		public function set size(value:Number):void
		{
			_size = value;
		}

		public function get font():BaseFont
		{
			return _font;
		}

		public function set font(value:BaseFont):void
		{
			_font = value;
		}

		public function get n():Number
		{
			return _n;
		}

		public function set n(value:Number):void
		{
			_n = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

	}
}