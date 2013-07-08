/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
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
* https://github.com/sephiroth74/purePDF
*
*
*			CODE39: http://en.wikipedia.org/wiki/Code_39
*
*
*
*
*/
package org.purepdf.pdf.barcode
{
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;

	public class BarcodeCODE39 extends Barcode
	{
		private static const GUARD_EMPTY: Vector.<int> = new Vector.<int>(0);
	
		private static const GUARD_CODE39: Vector.<int> = Vector.<int>([0, 2, 28, 30, 56, 58]);
		
		private static const TEXTPOS_CODE39: Vector.<Number> = Vector.<Number>([6.5, 13.5, 20.5, 27.5, 34.5, 41.5, 53.5, 60.5, 67.5, 74.5, 81.5, 88.5]);
		

		public function BarcodeCODE39()
		{
			super();
			try 
			{
				x = 0.8;
				font = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED );
				size = 8;
				baseline = size;
				barHeight = size * 3;
				guardBars = true;
				codeType = CODE39;
				code = "";
			}
			catch( e: Error ) 
			{
				throw new ConversionError(e);
			}
		}
		
		public static function getBarsCODE39( _code: String ): Vector.<int>
		{
			
			
			
			/* http://en.wikipedia.org/wiki/Code_39
			
			W	B	Wide - Black
			N	b	Narrow - Black
			w	W	Wide - White
			n	w	Narrow - White
			
			
			each character is separated by narrow white ("w");
			
			*/
			
			var startChar:String = "NwNnWnWnN"; // code must START and STOP with this character
			
			var code_39_bars:Array = 
				new Array(
					"NnNwWnWnN",	// 0
					"WnNwNnNnW",	// 1
					"NnWwNnNnW",	// 2
					"WnWwNnNnN",	// 3
					"NnNwWnNnW",	// 4
					"WnNwWnNnN",	// 5
					"NnWwWnNnN",	// 6
					"NnNwNnWnW",	// 7
					"WnNwNnWnN",	// 8
					"NnWwNnWnN",	// 9
					"WnNnNwNnW",	// A
					"NnWnNwNnW",	// B
					"WnWnNwNnN",	// C
					"NnNnWwNnW",	// D
					"WnNnWwNnN",	// E
					"NnWnWwNnN",	// F
					"NnNnNwWnW",	// G
					"WnNnNwWnN",	// H
					"NnWnNwWnN",	// I
					"NnNnWwWnN",	// J
					"WnNnNnNwW",	// K 
					"NnWnNnNwW",	// L 
					"WnWnNnNwN",	// M 
					"NnNnWnNwW",	// N
					"WnNnWnNwN",	// O 
					"NnWnWnNwN",	//P 
					"NnNnNnWwW",	//Q
					"WnNnNnWwN",	//R
					"NnWnNnWwN",	//S
					"NnNnWnWwN",	//T
					"WwNnNnNnW",	//U
					"NwWnNnNnW",	//V
					"WwWnNnNnN",	//W
					"NwNnWnNnW",	//X
					"WwNnWnNnN",	//Y
					"NwWnWnNnN",	//Z
					"NwNnNnWnW",	//-
					"WwNnNnWnN",	//.
					"NwWnNnWnN",	// SPACE
					"NwNwNwNnN",	//$
					"NwNwNnNwN",	// /
					"NwNnNwNwN",	// +
					"NnNwNwNwN",//	 %
					"NwNnWnWnN" // *
				);
			
			
			var code: Vector.<int> = new Vector.<int>( _code.length, true );
			var k: int;
			var c: int;
			var stripes: Vector.<int>;
			
			for( k = 0; k < code.length; ++k )
			{
				code[k] = _code.charCodeAt(k) - 48;				
			}
 
			var total_bars:int = 20 + _code.length * 10; // 10 per char, plus start, stop
			var bars: Vector.<int> = new Vector.<int>(total_bars, true);
			var pb: int = 0;
			//bars[pb++] = 1;
			//bars[pb++] = 1;
			//bars[pb++] = 1;
			
			for( k = 0; k <= code.length +1; ++k )
			{
				var pattern:String; // get the pattern for this chracter
				
				if (k == 0)
				{
					// start character
					pattern = startChar;
				} else if (k == (code.length+1))
				{
					// stop character
					pattern = startChar;
				
				} else
				{
					c = code[k-1];	// -1 because we do START for zero
					pattern = code_39_bars[c];
				}
				
				// For every character of the pattern, add an appropriate bar
				for (var pk:int = 0; pk < pattern.length; pk++)
				{
					var pattern_char:String = pattern.charAt(pk);
				
					var bar_width:int = 0;
				
					if (pattern_char == "W" || pattern_char == "w")
					{
						bar_width = 3; // W = wide
					} else if (pattern_char == "N" || pattern_char == "n")
					{
						bar_width = 1; // N = narrow
					}
					bars[pb++]= bar_width;
				}
			
				bars[pb++] = 1; // spacer
			}
			return bars;
		}
		
	

		override public function getBarcodeSize(): RectangleElement
		{
			var width: Number = 0;
			var height: Number = barHeight;

			if ( font != null )
			{
				if ( baseline <= 0 )
					height += -baseline + size;
				else
					height += baseline - font.getFontDescriptor( BaseFont.DESCENT, size );
			}

			switch ( codeType )
			{
				
				case CODE39:
					width = x * ( 11 + 12 * 7 );
					if ( font != null )
					{
						width += font.getWidthPoint( code.charAt( 0 ), size );
					}
					break;
				
				default:
					throw new RuntimeError( "invalid code type" );
			}
			return new RectangleElement( 0, 0, width, height );
		}
		
		override public function placeBarcode( cb: PdfContentByte, barColor: RGBColor, textColor: RGBColor ): RectangleElement
		{
			var rect: RectangleElement = getBarcodeSize();
			var barStartX: Number = 0;
			var barStartY: Number = 0;
			var textStartY: Number = 0;
			
			var white:RGBColor = new RGBColor(0,0,0);
			
			if( font != null ) 
			{
				if (baseline <= 0)
					textStartY = barHeight - baseline;
				else {
					textStartY = -font.getFontDescriptor(BaseFont.DESCENT, size);
					barStartY = textStartY + baseline;
				}
			}
			switch (codeType) {
				case CODE39:
					if (font != null)
						barStartX += font.getWidthPoint(code.charAt(0), size);
					break;
			}
			var bars: Vector.<int> = null;
			var guard: Vector.<int> = GUARD_EMPTY;
			
			switch (codeType) 
			{
				case CODE39:
					 
					bars =  getBarsCODE39(code);
					guard = GUARD_CODE39;
					break;
			}
			
			var keepBarX: Number = barStartX;
			var print: Boolean = true;
			var gd: Number = 0;
			if (font != null && baseline > 0 && guardBars) {
				gd = baseline / 2;
			}
			
			
			var k: int;
			var c: String;
			var len: Number;
			var pX: Number;
			
			for( k = 0; k < bars.length; ++k )
			{
				var w: Number = bars[k] * x;
				
				if (barColor != null)
					
					if ((k%2) == 0)
					{
						// Every other bar is blank (white)
						// even is black, odd is white
						cb.setColorFill(barColor);
					} else
					{
						cb.setColorFill(white);
					}
						
				
				
				if (print) 
				{
					//if ( guard.indexOf(k) >= 0 )
						
					//	cb.rectangle(barStartX, barStartY - gd, w - inkSpreading, barHeight + gd);
					//else
						cb.rectangle(barStartX, barStartY, w - inkSpreading, barHeight);
				}
				print = !print;
				barStartX += w;
			}
			cb.fill();
			if (font != null) {
				if (textColor != null)
					cb.setColorFill(textColor);
				cb.beginText();
				cb.setFontAndSize(font, size);
				switch (codeType) {
					case CODE39:
						//cb.setTextMatrix( 1, 0, 0, 1, 0, textStartY );
						//cb.showText( code.substring(0, 1) );
						for( k = 0; k < 13; ++k )
						{
							//c = code.substring(k, k + 1);
							c = code.substring(k, k+1);
							len = font.getWidthPoint(c, size);
							pX = keepBarX + 26.5 + 7*k * x - len / 2;
							cb.setTextMatrix( 1, 0, 0, 1, pX, textStartY );
							cb.showText( c );
						}
						break;
					
				}
				cb.endText();
			}
			return rect;
		}
	}
}