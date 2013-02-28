/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FieldText.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/forms/FieldText.as $
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
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.Font;
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.FontSelector;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfBorderDictionary;
	import org.purepdf.pdf.PdfDashPattern;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.StringUtils;

	public class FieldText extends FieldBase
	{
		private var _choicesExport: Vector.<String>;
		private var choiceSelections: Vector.<int> = new Vector.<int>();
		private var _choices: Vector.<String>;
		private var defaultText: String;
		private var extraMarginLeft: Number = 0;
		private var extraMarginTop: Number = 0;
		private var topFirst: int;
		private var extensionFont: BaseFont;
		private var substitutionFonts: Vector.<BaseFont>;

		public function FieldText( $writer: PdfWriter, $box: RectangleElement, $fieldName: String )
		{
			super( $writer, $box, $fieldName );
		}
		
		/**
		 * 
		 * @throws DocumentError
		 */
		public function getListField(): PdfFormField
		{
			return _getChoiceField(true);
		}
		
		/**
		 * Returns a combo field
		 * @throws DocumentError
		 */
		public function getComboField(): PdfFormField
		{
			return _getChoiceField(false);
		}
		
		private function getTopChoice(): int
		{
			if (choiceSelections == null || choiceSelections.length ==0) {
				return 0;
			}
			
			var firstValue: int = choiceSelections[0];
			
			var topChoice: int = 0;
			if (choices != null) {
				topChoice = firstValue;
				topChoice = Math.min( topChoice, _choices.length );
				topChoice = Math.max( 0, topChoice);
			}
			return topChoice;
		}
		
		/**
		 * 
		 * @throws DocumentError
		 */
		protected function _getChoiceField( isList: Boolean): PdfFormField
		{
			options &= (~MULTILINE) & (~COMB);
			var uchoices: Vector.<String> = choices;
			if (uchoices == null)
				uchoices = new Vector.<String>();
			
			var topChoice: int = getTopChoice();
			
			if (_text == null)
				_text = "";
			
			if (topChoice >= 0)
				_text = uchoices[topChoice];
			
			var field: PdfFormField = null;
			var mix: Vector.<Vector.<String>> = null;
			var k: int;
			
			if ( _choicesExport == null) {
				if (isList)
					field = PdfFormField.createList(writer, uchoices, topChoice);
				else
					field = PdfFormField.createCombo(writer, (options & EDIT) != 0, uchoices, topChoice);
			}
			else {
				mix = new Vector.<Vector.<String>>(uchoices.length,true);
				for ( k = 0; k < mix.length; ++k)
				{
					mix[k] = new Vector.<String>(2,true);
					mix[k][0] = mix[k][1] = uchoices[k];
				}
				var top: int = Math.min(uchoices.length, _choicesExport.length);
				for ( k = 0; k < top; ++k) {
					if (_choicesExport[k] != null)
						mix[k][0] = _choicesExport[k];
				}
				if (isList)
					field = PdfFormField.createLists(writer, mix, topChoice);
				else
					field = PdfFormField.createCombos(writer, (options & EDIT) != 0, mix, topChoice);
			}
			field.setWidget( box, PdfAnnotation.HIGHLIGHT_INVERT );
			if (rotation != 0)
				field.mkRotation = rotation;
			if (fieldName != null) {
				field.fieldName = fieldName;
				if (uchoices.length > 0) {
					if (mix != null) {
						if (choiceSelections.length < 2) {
							field.valueAsString = mix[topChoice][0];
							field.defaultValueAsString = mix[topChoice][0];
						} else {
							writeMultipleValues( field, mix);
						}
					} else {
						if (choiceSelections.length < 2) {
							field.valueAsString = _text;
							field.defaultValueAsString = _text;
						} else {
							writeMultipleValues( field, null );
						}
					}
				}
				if ((options & READ_ONLY) != 0)
					field.fieldFlags = PdfFormField.FF_READ_ONLY;
				if ((options & REQUIRED) != 0)
					field.fieldFlags = PdfFormField.FF_REQUIRED;
				if ((options & DO_NOT_SPELL_CHECK) != 0)
					field.fieldFlags = PdfFormField.FF_DONOTSPELLCHECK;
				if ((options & MULTISELECT) != 0) {
					field.fieldFlags = PdfFormField.FF_MULTISELECT;
				}
			}
			
			field.borderStyle = new PdfBorderDictionary(_borderWidth, _borderStyle, new PdfDashPattern(3));
			var tp: PdfAppearance;
			if (isList) {
				tp = getListAppearance();
				if (topFirst > 0)
					field.put(PdfName.TI, new PdfNumber(topFirst));
			}
			else
				tp = getAppearance();
			field.setAppearance(PdfAnnotation.APPEARANCE_NORMAL, tp);
			var da: PdfAppearance = tp.duplicate() as PdfAppearance;
			da.setFontAndSize(getRealFont(), fontSize);
			if (_textColor == null)
				da.setGrayFill(0);
			else
				da.setColorFill(_textColor);
			field.defaultAppearanceString = da;
			if (_borderColor != null)
				field.mkBorderColor = _borderColor;
			if (_backgroundColor != null)
				field.mkBackgroundColor = _backgroundColor;
			switch (visibility) {
				case HIDDEN:
					field.flags = PdfAnnotation.FLAGS_PRINT | PdfAnnotation.FLAGS_HIDDEN;
					break;
				case VISIBLE_BUT_DOES_NOT_PRINT:
					break;
				case HIDDEN_BUT_PRINTABLE:
					field.flags = PdfAnnotation.FLAGS_PRINT | PdfAnnotation.FLAGS_NOVIEW;
					break;
				default:
					field.flags = PdfAnnotation.FLAGS_PRINT;
					break;
			}
			return field;
		}
		
		/**
		 * 
		 * @throws DocumentError
		 */
		private function getListAppearance(): PdfAppearance
		{
			var app: PdfAppearance = getBorderAppearance();
			if (choices == null || choices.length == 0) {
				return app;
			}
			app.beginVariableText();
			
			var topChoice: int = getTopChoice();
			
			var ufont: BaseFont = getRealFont();
			var usize: Number = fontSize;
			if (usize == 0)
				usize = 12;
			
			var borderExtra: Boolean = _borderStyle == PdfBorderDictionary.STYLE_BEVELED || _borderStyle == PdfBorderDictionary.STYLE_INSET;
			var h: Number = box.height - _borderWidth * 2;
			var offsetX: Number = _borderWidth;
			if (borderExtra) {
				h -= _borderWidth * 2;
				offsetX *= 2;
			}
			
			var leading: Number = ufont.getFontDescriptor(BaseFont.BBOXURY, usize) - ufont.getFontDescriptor(BaseFont.BBOXLLY, usize);
			var maxFit: int = (h / leading) + 1;
			var first: int = 0;
			var last: int = 0;
			first = topChoice;
			last = first + maxFit;
			if (last > choices.length)
				last = choices.length;
			topFirst = first;
			app.saveState();
			app.rectangle( offsetX, offsetX, box.width - 2 * offsetX, box.height - 2 * offsetX);
			app.clip();
			app.newPath();
			var fcolor: RGBColor = (_textColor == null) ? GrayColor.GRAYBLACK : _textColor;
			
			
			app.setColorFill(new RGBColor(10, 36, 106));
			for (var curVal: int = 0; curVal < choiceSelections.length; ++curVal) {
				var curChoice: int = choiceSelections[curVal]; 
				if (curChoice >= first && curChoice <= last) {
					app.rectangle(offsetX, offsetX + h - (curChoice - first + 1) * leading, box.width - 2 * offsetX, leading);
					app.fill();
				}
			}
			var xp: Number = offsetX * 2;
			var yp: Number = offsetX + h - ufont.getFontDescriptor(BaseFont.BBOXURY, usize);
			for ( var idx: int = first; idx < last; ++idx, yp -= leading) 
			{
				var ptext: String = choices[idx];
				var rtl: int = checkRTL(ptext) ? PdfWriter.RUN_DIRECTION_LTR : PdfWriter.RUN_DIRECTION_NO_BIDI;
				ptext = removeCRLF(ptext);
				var textCol: RGBColor = (choiceSelections.indexOf( idx ) > -1 ) ? GrayColor.GRAYWHITE : fcolor;
				var phrase: Phrase = composePhrase(ptext, ufont, textCol, usize);
				ColumnText.showTextAligned(app, Element.ALIGN_LEFT, phrase, xp, yp, 0, rtl, 0);
			}
			app.restoreState();
			app.endVariableText();
			return app;
		}
		
		private function writeMultipleValues( field: PdfFormField, mix: Vector.<Vector.<String>> ): void
		{
			var indexes: PdfArray = new PdfArray();
			var values: PdfArray = new PdfArray();
			for( var i: int = 0; i < choiceSelections.length; ++i)
			{
				var idx: int = choiceSelections[i];
				indexes.add( new PdfNumber( idx ) );
				
				if (mix != null)
					values.add( new PdfString( mix[idx][0] ) );
				else if (choices != null)
					values.add( new PdfString( choices[ idx ] ) );
			}
			
			field.put( PdfName.V, values );
			field.put( PdfName.I, indexes );
			
		}

		public function get choices():Vector.<String>
		{
			return _choices;
		}

		public function set choices(value:Vector.<String>):void
		{
			_choices = value;
		}

		public function get choicesExport():Vector.<String>
		{
			return _choicesExport;
		}

		public function set choicesExport(value:Vector.<String>):void
		{
			_choicesExport = value;
		}

		/**
		 * Return a new FieldText
		 * @throws DocumentError
		 */
		public function getTextField(): PdfFormField
		{
			if (maxCharacterLength <= 0)
				options &= ~COMB;
			if ((options & COMB) != 0)
				options &= ~MULTILINE;
			var field: PdfFormField = PdfFormField.createTextField( writer, false, false, maxCharacterLength );
			field.setWidget( box, PdfAnnotation.HIGHLIGHT_INVERT );
			switch (_alignment) {
				case Element.ALIGN_CENTER:
					field.quadding = PdfFormField.Q_CENTER;
					break;
				case Element.ALIGN_RIGHT:
					field.quadding = PdfFormField.Q_RIGHT;
					break;
			}
			if (rotation != 0)
				field.mkRotation = rotation;
			if (fieldName != null) {
				field.fieldName = fieldName;
				if ( _text != "" )
					field.valueAsString = _text;
				if (defaultText != null)
					field.defaultValueAsString = defaultText;
				if ((options & READ_ONLY) != 0)
					field.fieldFlags = PdfFormField.FF_READ_ONLY;
				if ((options & REQUIRED) != 0)
					field.fieldFlags = PdfFormField.FF_REQUIRED;
				if ((options & MULTILINE) != 0)
					field.fieldFlags = PdfFormField.FF_MULTILINE;
				if ((options & DO_NOT_SCROLL) != 0)
					field.fieldFlags = PdfFormField.FF_DONOTSCROLL;
				if ((options & PASSWORD) != 0)
					field.fieldFlags = PdfFormField.FF_PASSWORD;
				if ((options & FILE_SELECTION) != 0)
					field.fieldFlags = PdfFormField.FF_FILESELECT;
				if ((options & DO_NOT_SPELL_CHECK) != 0)
					field.fieldFlags = PdfFormField.FF_DONOTSPELLCHECK;
				if ((options & COMB) != 0)
					field.fieldFlags = PdfFormField.FF_COMB;
			}
			
			field.borderStyle = new PdfBorderDictionary( _borderWidth, _borderStyle, new PdfDashPattern(3) );
			var tp: PdfAppearance = getAppearance();
			field.setAppearance( PdfAnnotation.APPEARANCE_NORMAL, tp);
			var da: PdfAppearance = tp.duplicate() as PdfAppearance;
			da.setFontAndSize(getRealFont(), fontSize);
			if (_textColor == null)
				da.setGrayFill(0);
			else
				da.setColorFill(_textColor);
			field.defaultAppearanceString = da;
			if (_borderColor != null)
				field.mkBorderColor = _borderColor;
			if (_backgroundColor != null)
				field.mkBackgroundColor = _backgroundColor;
			switch (visibility) {
				case HIDDEN:
					field.flags = PdfAnnotation.FLAGS_PRINT | PdfAnnotation.FLAGS_HIDDEN;
					break;
				case VISIBLE_BUT_DOES_NOT_PRINT:
					break;
				case HIDDEN_BUT_PRINTABLE:
					field.flags = PdfAnnotation.FLAGS_PRINT | PdfAnnotation.FLAGS_NOVIEW;
					break;
				default:
					field.flags = PdfAnnotation.FLAGS_PRINT;
					break;
			}
			return field;
		}
		
		/**
		 * 
		 * @throws DocumentError
		 */
		public function getAppearance(): PdfAppearance
		{
			var app: PdfAppearance = getBorderAppearance();
			app.beginVariableText();
			if (_text == null || _text.length == 0) {
				app.endVariableText();
				return app;
			}
			
			var borderExtra: Boolean = _borderStyle == PdfBorderDictionary.STYLE_BEVELED || _borderStyle == PdfBorderDictionary.STYLE_INSET;
			var h: Number = box.height - _borderWidth * 2 - extraMarginTop;
			var bw2: Number = _borderWidth;
			
			if (borderExtra) {
				h -= _borderWidth * 2;
				bw2 *= 2;
			}
			
			var wd: Number;
			var step: Number;
			var offsetY: Number;
			var offsetX: Number = Math.max(bw2, 1);
			var offX: Number = Math.min(bw2, offsetX);
			
			app.saveState();
			app.rectangle(offX, offX, box.width - 2 * offX, box.height - 2 * offX);
			app.clip();
			app.newPath();
			var ptext: String;
			if ((options & PASSWORD) != 0)
				ptext = obfuscatePassword(_text);
			else if ((options & MULTILINE) == 0)
				ptext = removeCRLF(_text);
			else
				ptext = _text; //fixed by Kazuya Ujihara (ujihara.jp)
			var ufont: BaseFont = getRealFont();
			var fcolor: RGBColor = (_textColor == null) ? GrayColor.GRAYBLACK : _textColor;
			var rtl: int = checkRTL(ptext) ? PdfWriter.RUN_DIRECTION_LTR : PdfWriter.RUN_DIRECTION_NO_BIDI;
			var usize: Number = _fontSize;
			var phrase: Phrase = composePhrase(ptext, ufont, fcolor, usize);
			if ((options & MULTILINE) != 0) {
				var width: Number = box.width - 4 * offsetX - extraMarginLeft;
				var factor: Number = ufont.getFontDescriptor(BaseFont.BBOXURY, 1) - ufont.getFontDescriptor(BaseFont.BBOXLLY, 1);
				var ct: ColumnText = new ColumnText(null);
				if (usize == 0) {
					usize = h / factor;
					if (usize > 4) {
						if (usize > 12)
							usize = 12;
						step = Math.max((usize - 4) / 10, 0.2);
						ct.setSimpleColumn(0, -h, width, 0);
						ct.alignment = _alignment;
						ct.runDirection = rtl;
						for (; usize > 4; usize -= step) {
							ct.yLine = 0;
							changeFontSize(phrase, usize);
							ct.setText(phrase);
							ct.setLeading(factor * usize);
							var status: int = ct.go(true);
							if ((status & ColumnText.NO_MORE_COLUMN) == 0)
								break;
						}
					}
					if (usize < 4)
						usize = 4;
				}
				changeFontSize(phrase, usize);
				ct.canvas = app;
				var leading: Number = usize * factor;
				offsetY = offsetX + h - ufont.getFontDescriptor(BaseFont.BBOXURY, usize);
				ct.setSimpleColumn(extraMarginLeft + 2 * offsetX, -20000, box.width - 2 * offsetX, offsetY + leading);
				ct.setLeading(leading);
				ct.alignment = _alignment;
				ct.runDirection = rtl;
				ct.setText(phrase);
				ct.go();
			}
			else {
				if (usize == 0) {
					var maxCalculatedSize: Number = h / (ufont.getFontDescriptor(BaseFont.BBOXURX, 1) - ufont.getFontDescriptor(BaseFont.BBOXLLY, 1));
					changeFontSize(phrase, 1);
					wd = ColumnText.getWidth(phrase, rtl, 0);
					if (wd == 0)
						usize = maxCalculatedSize;
					else
						usize = Math.min(maxCalculatedSize, (box.width - extraMarginLeft - 4 * offsetX) / wd);
					if (usize < 4)
						usize = 4;
				}
				changeFontSize(phrase, usize);
				offsetY = offX + ((box.height - 2*offX) - ufont.getFontDescriptor(BaseFont.ASCENT, usize)) / 2;
				if (offsetY < offX)
					offsetY = offX;
				if (offsetY - offX < -ufont.getFontDescriptor(BaseFont.DESCENT, usize)) {
					var ny: Number = -ufont.getFontDescriptor(BaseFont.DESCENT, usize) + offX;
					var dy: Number = box.height - offX - ufont.getFontDescriptor(BaseFont.ASCENT, usize);
					offsetY = Math.min(ny, Math.max(offsetY, dy));
				}
				if ((options & COMB) != 0 && maxCharacterLength > 0) {
					var textLen: int = Math.min(maxCharacterLength, ptext.length);
					var position: int = 0;
					if (_alignment == Element.ALIGN_RIGHT)
						position = maxCharacterLength - textLen;
					else if (_alignment == Element.ALIGN_CENTER)
						position = (maxCharacterLength - textLen) / 2;
					step = (box.width - extraMarginLeft) / maxCharacterLength;
					var start: Number = step / 2 + position * step;
					if (_textColor == null)
						app.setGrayFill(0);
					else
						app.setColorFill(_textColor);
					app.beginText();
					for ( var k: int = 0; k < phrase.size; ++k )
					{
						var ck: Chunk = Chunk( phrase.getValue(k) );
						var bf: BaseFont = ck.font.baseFont;
						app.setFontAndSize(bf, usize);
						var sb: String = ck.append("");
						for (var j: int = 0; j < sb.length; ++j) {
							var c: String = sb.substring(j, j + 1);
							wd = bf.getWidthPoint(c, usize);
							app.setTextMatrix(extraMarginLeft + start - wd / 2, offsetY - extraMarginTop);
							app.showText(c);
							start += step;
						}
					}
					app.endText();
				}
				else {
					var x: Number;
					switch (_alignment) {
						case Element.ALIGN_RIGHT:
							x = extraMarginLeft + box.width - (2 * offsetX);
							break;
						case Element.ALIGN_CENTER:
							x = extraMarginLeft + (box.width / 2);
							break;
						default:
							x = extraMarginLeft + (2 * offsetX);
					}
					ColumnText.showTextAligned( app, _alignment, phrase, x, offsetY - extraMarginTop, 0, rtl, 0);
				}
			}
			app.restoreState();
			app.endVariableText();
			return app;
		}
		
		public static function removeCRLF( text: String ): String
		{
			return text.replace(/(\r\n|\r|\n)/g, ' ');
		}
		
		public static function obfuscatePassword( text: String ): String
		{
			return text.replace(/.*/,'*');
		}
		
		private function composePhrase( text: String, ufont: BaseFont, color: RGBColor, fontSize: Number ): Phrase
		{
			var phrase: Phrase = null;
			if( extensionFont == null && (substitutionFonts == null || (substitutionFonts.length == 0)))
				phrase = Phrase.fromChunk( new Chunk( text, Font.fromBaseFont( ufont, fontSize, 0, color)));
			else {
				var fs: FontSelector = new FontSelector();
				fs.addFont( Font.fromBaseFont( ufont, fontSize, 0, color ) );
				if (extensionFont != null)
					fs.addFont( Font.fromBaseFont( extensionFont, fontSize, 0, color ) );
				if (substitutionFonts != null) {
					for (var k: int = 0; k < substitutionFonts.length; ++k)
						fs.addFont( Font.fromBaseFont( substitutionFonts[k], fontSize, 0, color));
				}
				phrase = fs.process(text);
			}
			return phrase;
		}

		static private function changeFontSize( p: Phrase, size: Number ): void
		{
			for ( var k: int = 0; k < p.size; ++k )
				Chunk( p.getValue( k ) ).font.size = size;
		}

		static private function checkRTL( text: String ): Boolean
		{
			if ( text == null || text.length == 0 )
				return false;
			var cc: Vector.<int> = StringUtils.toCharArray( text );

			for ( var k: int = 0; k < cc.length; ++k )
			{
				var c: int = cc[k];

				if ( c >= 0x590 && c < 0x0780 )
					return true;
			}
			return false;
		}
	}
}