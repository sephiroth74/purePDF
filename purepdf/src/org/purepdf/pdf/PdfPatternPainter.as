/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPatternPainter.as 313 2010-02-09 23:55:49Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 313 $ $LastChangedDate: 2010-02-09 18:55:49 -0500 (Tue, 09 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPatternPainter.as $
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
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.RuntimeError;
	

	public class PdfPatternPainter extends PdfTemplate
	{
		private var _xstep: Number;
		private var _ystep: Number;
		private var _stencil: Boolean = false;
		private var _defaultColor: RGBColor;
		
		public function PdfPatternPainter( $writer: PdfWriter = null, color: RGBColor = null )
		{
			super($writer);
			_type = TYPE_PATTERN;
			
			if( color != null )
			{
				_stencil = true;
				_defaultColor = color;
			}
		}
		
		public function get defaultColor():RGBColor
		{
			return _defaultColor;
		}
		
		/**
		 * Get the vertical interval of this pattern.
		 */
		public function get ystep():Number
		{
			return _ystep;
		}

		/**
		 * Sets the vertical interval of this pattern.
		 */
		public function set ystep(value:Number):void
		{
			_ystep = value;
		}

		/**
		 * Set the horizontal interval of this pattern
		 */
		public function get xstep():Number
		{
			return _xstep;
		}

		/**
		 * Get the horizontal interval of this pattern.
		 */
		public function set xstep(value:Number):void
		{
			_xstep = value;
		}
		
		/**
		 * Tells you if this pattern is colored/uncolored
		 */
		public function get is_stencil(): Boolean
		{
			return _stencil;
		}
		
		/**
		 * Get the stream for this pattern
		 */
		public function getPattern( compressionLvl: int = 0 /* PdfStream.NO_COMPRESSION */ ): PdfPattern
		{
			return new PdfPattern( this, compressionLvl );
		}
		
		override public function duplicate(): PdfContentByte
		{
			var tpl: PdfPatternPainter = new PdfPatternPainter();
			tpl.writer = writer;
			tpl.pdf = pdf;
			tpl.thisReference = thisReference;
			tpl._pageResources = _pageResources;
			tpl.bBox = bBox;
			tpl.xstep = xstep;
			tpl.ystep = ystep;
			tpl._matrix = _matrix;
			tpl._stencil = _stencil;
			tpl._defaultColor = _defaultColor;
			return tpl;
		}
		
		override public function setGrayFill(gray:Number) : void
		{
			checkNoColor();
			super.setGrayFill( gray );
		}
		
		override public function resetFill() : void
		{
			checkNoColor();
			super.resetFill();
		}
		
		override public function resetStroke() : void
		{
			checkNoColor();
			super.resetStroke();
		}
		
		override public function setGrayStroke(gray:Number) : void
		{
			checkNoColor();
			super.setGrayStroke( gray );
		}
		
		override public function setRGBFillColor(red:int, green:int, blue:int) : void
		{
			checkNoColor();
			super.setRGBFillColor( red, green, blue );
		}
		
		override public function setRGBStrokeColor(red:int, green:int, blue:int) : void
		{
			checkNoColor();
			super.setRGBStrokeColor( red, green, blue );
		}
		
		override public function setCMYKFillColor(cyan:Number, magenta:Number, yellow:Number, black:Number) : void
		{
			checkNoColor();
			super.setCMYKFillColor( cyan, magenta, yellow, black );
		}
		
		override public function setCMYKStrokeColor(cyan:Number, magenta:Number, yellow:Number, black:Number) : void
		{
			checkNoColor();
			super.setCMYKStrokeColor( cyan, magenta, yellow, black );
		}
		
		override public function setColorStroke(color:RGBColor) : void
		{
			checkNoColor();
			super.setColorStroke( color );
		}
		
		override public function setColorFill(color:RGBColor) : void
		{
			checkNoColor();
			super.setColorFill( color );
		}
		
		override public function setPatternStroke(p:PdfPatternPainter) : void
		{
			checkNoColor();
			super.setPatternStroke(p);
		}
		
		override public function setPatternStroke2(p:PdfPatternPainter, color:RGBColor) : void
		{
			checkNoColor();
			super.setPatternStroke2( p, color );
		}
		
		override public function setPatternStroke3(p:PdfPatternPainter, color:RGBColor, tint:Number) : void
		{
			checkNoColor();
			super.setPatternStroke3( p, color, tint );
		}
		
		override public function setPatternFill(p:PdfPatternPainter) : void
		{
			checkNoColor();
			super.setPatternFill( p );
		}
		
		override public function setPatternFill2(p:PdfPatternPainter, color:RGBColor) : void
		{
			checkNoColor();
			super.setPatternFill2( p, color );
		}
		
		override public function setPatternFill3(p:PdfPatternPainter, color:RGBColor, tint:Number) : void
		{
			checkNoColor();
			super.setPatternFill3( p, color, tint );
		}
		
		override public function addImage2(image:ImageElement, width:Number, b:Number, c:Number, height:Number, x:Number, y:Number, inlineImage:Boolean) : void
		{
			if( _stencil && !image.isMask )
			{
				checkNoColor();
			}
			super.addImage2( image, width, b, c, height, x, y, inlineImage );
		}
			
		
		public function checkNoColor(): void
		{
			if (_stencil)
				throw new RuntimeError("colors not allowed in uncolored tile pattern");
		}

	}
}