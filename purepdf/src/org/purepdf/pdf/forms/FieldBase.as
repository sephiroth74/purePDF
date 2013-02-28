/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FieldBase.as 313 2010-02-09 23:55:49Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 313 $ $LastChangedDate: 2010-02-09 18:55:49 -0500 (Tue, 09 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/forms/FieldBase.as $
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
package org.purepdf.pdf.forms
{
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.NullPointerError;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfBorderDictionary;
	import org.purepdf.pdf.PdfCopyFieldsImp;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;

	[Abstract]
	public class FieldBase
	{
		public static const BORDER_WIDTH_MEDIUM: Number = 2;
		public static const BORDER_WIDTH_THICK: Number = 3;
		public static const BORDER_WIDTH_THIN: Number = 1;
		public static const COMB: int = PdfFormField.FF_COMB;
		public static const DO_NOT_SCROLL: int = PdfFormField.FF_DONOTSCROLL;
		public static const DO_NOT_SPELL_CHECK: int = PdfFormField.FF_DONOTSPELLCHECK;
		public static const EDIT: int = PdfFormField.FF_EDIT;
		public static const FILE_SELECTION: int = PdfFormField.FF_FILESELECT;
		public static const HIDDEN: int = 1;
		public static const HIDDEN_BUT_PRINTABLE: int = 3;
		public static const MULTILINE: int = PdfFormField.FF_MULTILINE;
		public static const MULTISELECT: int = PdfFormField.FF_MULTISELECT;
		public static const PASSWORD: int = PdfFormField.FF_PASSWORD;
		public static const READ_ONLY: int = PdfFormField.FF_READ_ONLY;
		public static const REQUIRED: int = PdfFormField.FF_REQUIRED;
		public static const VISIBLE: int = 0;
		public static const VISIBLE_BUT_DOES_NOT_PRINT: int = 2;
		private static var _fieldKeys: HashMap;
		protected var _alignment: int = Element.ALIGN_LEFT;
		protected var _backgroundColor: RGBColor;
		protected var _borderColor: RGBColor;
		protected var _borderStyle: int = PdfBorderDictionary.STYLE_SOLID;
		protected var _borderWidth: Number = BORDER_WIDTH_THIN;
		protected var box: RectangleElement;
		protected var fieldName: String;
		protected var _font: BaseFont;
		protected var _fontSize: Number = 0;
		protected var maxCharacterLength: int;
		protected var options: int;
		protected var rotation: int = 0;
		protected var _text: String = "";
		protected var _textColor: RGBColor;
		protected var visibility: int = 0;
		protected var writer: PdfWriter;

		public function FieldBase( $writer: PdfWriter, $box: RectangleElement, $fieldName: String )
		{
			writer = $writer;
			box = $box;
			fieldName = $fieldName;
		}
		
		public function get borderWidth():Number
		{
			return _borderWidth;
		}

		public function set borderWidth(value:Number):void
		{
			_borderWidth = value;
		}

		public function get borderStyle():int
		{
			return _borderStyle;
		}

		public function set borderStyle(value:int):void
		{
			_borderStyle = value;
		}

		public function get borderColor():RGBColor
		{
			return _borderColor;
		}

		public function set borderColor(value:RGBColor):void
		{
			_borderColor = value;
		}

		public function get backgroundColor():RGBColor
		{
			return _backgroundColor;
		}

		public function set backgroundColor(value:RGBColor):void
		{
			_backgroundColor = value;
		}

		public function get alignment():int
		{
			return _alignment;
		}

		public function set alignment(value:int):void
		{
			_alignment = value;
		}

		public function get textColor():RGBColor
		{
			return _textColor;
		}

		public function set textColor(value:RGBColor):void
		{
			_textColor = value;
		}

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;
		}

		public function get font():BaseFont
		{
			return _font;
		}

		public function set font(value:BaseFont):void
		{
			_font = value;
		}

		public function get fontSize():Number
		{
			return _fontSize;
		}

		public function set fontSize(value:Number):void
		{
			_fontSize = value;
		}

		/**
		 * 
		 * @throws DocumentError
		 */
		protected function getRealFont(): BaseFont
		{
			if (_font == null)
				return BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false);
			else
				return _font;
		}

		
		protected function getBorderAppearance(): PdfAppearance
		{
			var app: PdfAppearance = PdfAppearance.createAppearance( writer, box.width, box.height );
			switch (rotation) {
				case 90:
					app.setMatrixValues(0, 1, -1, 0, box.height, 0);
					break;
				case 180:
					app.setMatrixValues(-1, 0, 0, -1, box.width, box.height);
					break;
				case 270:
					app.setMatrixValues(0, -1, 1, 0, 0, box.width);
					break;
			}
			app.saveState();
			
			if (_backgroundColor != null) {
				app.setColorFill(_backgroundColor);
				app.rectangle(0, 0, box.width, box.height);
				app.fill();
			}
			
			if (_borderStyle == PdfBorderDictionary.STYLE_UNDERLINE) {
				if (_borderWidth != 0 && _borderColor != null) {
					app.setColorStroke(_borderColor);
					app.setLineWidth(_borderWidth);
					app.moveTo(0, _borderWidth / 2);
					app.lineTo(box.width, _borderWidth / 2);
					app.stroke();
				}
			}
			else if (_borderStyle == PdfBorderDictionary.STYLE_BEVELED) {
				if (_borderWidth != 0 && _borderColor != null) {
					app.setColorStroke(_borderColor);
					app.setLineWidth(_borderWidth);
					app.rectangle(_borderWidth / 2, _borderWidth / 2, box.width - _borderWidth, box.height - _borderWidth);
					app.stroke();
				}
				// beveled
				var actual: RGBColor = _backgroundColor;
				if (actual == null)
					actual = RGBColor.WHITE;
				app.setGrayFill(1);
				drawTopFrame(app);
				app.setColorFill(actual.darker());
				drawBottomFrame(app);
			}
			else if (_borderStyle == PdfBorderDictionary.STYLE_INSET) {
				if (_borderWidth != 0 && _borderColor != null) {
					app.setColorStroke(_borderColor);
					app.setLineWidth(_borderWidth);
					app.rectangle(_borderWidth / 2, _borderWidth / 2, box.width - _borderWidth, box.height - _borderWidth);
					app.stroke();
				}
				
				app.setGrayFill(0.5);
				drawTopFrame(app);
				app.setGrayFill(0.75);
				drawBottomFrame(app);
			}
			else {
				if (_borderWidth != 0 && _borderColor != null) {
					if (_borderStyle == PdfBorderDictionary.STYLE_DASHED)
						app.setLineDash2(3, 0);
					app.setColorStroke(_borderColor);
					app.setLineWidth(_borderWidth);
					app.rectangle(_borderWidth / 2, _borderWidth / 2, box.width - _borderWidth, box.height - _borderWidth);
					app.stroke();
					if ((options & COMB) != 0 && maxCharacterLength > 1) {
						var step: Number = box.width / maxCharacterLength;
						var yb: Number = _borderWidth / 2;
						var yt: Number = box.height - _borderWidth / 2;
						for (var k: int = 1; k < maxCharacterLength; ++k) {
							var x: Number = step * k;
							app.moveTo(x, yb);
							app.lineTo(x, yt);
						}
						app.stroke();
					}
				}
			}
			app.restoreState();
			return app;
		}
		
		private function drawTopFrame( app: PdfAppearance ): void
		{
			app.moveTo(_borderWidth, _borderWidth);
			app.lineTo(_borderWidth, box.height - _borderWidth);
			app.lineTo(box.width - _borderWidth, box.height - _borderWidth);
			app.lineTo(box.width - 2 * _borderWidth, box.height - 2 * _borderWidth);
			app.lineTo(2 * _borderWidth, box.height - 2 * _borderWidth);
			app.lineTo(2 * _borderWidth, 2 * _borderWidth);
			app.lineTo(_borderWidth, _borderWidth);
			app.fill();
		}
		
		private function drawBottomFrame( app: PdfAppearance ): void
		{
			app.moveTo(_borderWidth, _borderWidth);
			app.lineTo(box.width - _borderWidth, _borderWidth);
			app.lineTo(box.width - _borderWidth, box.height - _borderWidth);
			app.lineTo(box.width - 2 * _borderWidth, box.height - 2 * _borderWidth);
			app.lineTo(box.width - 2 * _borderWidth, 2 * _borderWidth);
			app.lineTo(2 * _borderWidth, 2 * _borderWidth);
			app.lineTo(_borderWidth, _borderWidth);
			app.fill();
		}

		static private function get fieldKeys(): HashMap
		{
			if ( _fieldKeys == null )
				initFieldKeys();
			return _fieldKeys;
		}

		static private function initFieldKeys(): void
		{
			_fieldKeys = new HashMap();
			_fieldKeys.putAll( PdfCopyFieldsImp.fieldKeys );
			_fieldKeys.put( PdfName.T, 1 );
		}
	}
}