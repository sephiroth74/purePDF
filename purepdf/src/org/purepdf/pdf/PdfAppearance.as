/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfAppearance.as 313 2010-02-09 23:55:49Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 313 $ $LastChangedDate: 2010-02-09 18:55:49 -0500 (Tue, 09 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfAppearance.as $
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
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.pdf_core;

	public class PdfAppearance extends PdfTemplate
	{
		use namespace pdf_core;
		
		public static var _stdFieldFontNames: HashMap;
		
		public static function get stdFieldFontNames(): HashMap
		{
			if( _stdFieldFontNames == null )
				initFieldFontNames();
			return _stdFieldFontNames;
		}
		
		private static function initFieldFontNames(): void
		{
			_stdFieldFontNames = new HashMap();
			_stdFieldFontNames.put("Courier-BoldOblique", new PdfName("CoBO"));
			_stdFieldFontNames.put("Courier-Bold", new PdfName("CoBo"));
			_stdFieldFontNames.put("Courier-Oblique", new PdfName("CoOb"));
			_stdFieldFontNames.put("Courier", new PdfName("Cour"));
			_stdFieldFontNames.put("Helvetica-BoldOblique", new PdfName("HeBO"));
			_stdFieldFontNames.put("Helvetica-Bold", new PdfName("HeBo"));
			_stdFieldFontNames.put("Helvetica-Oblique", new PdfName("HeOb"));
			_stdFieldFontNames.put("Helvetica", PdfName.HELV);
			_stdFieldFontNames.put("Symbol", new PdfName("Symb"));
			_stdFieldFontNames.put("Times-BoldItalic", new PdfName("TiBI"));
			_stdFieldFontNames.put("Times-Bold", new PdfName("TiBo"));
			_stdFieldFontNames.put("Times-Italic", new PdfName("TiIt"));
			_stdFieldFontNames.put("Times-Roman", new PdfName("TiRo"));
			_stdFieldFontNames.put("ZapfDingbats", PdfName.ZADB);
			_stdFieldFontNames.put("HYSMyeongJo-Medium", new PdfName("HySm"));
			_stdFieldFontNames.put("HYGoThic-Medium", new PdfName("HyGo"));
			_stdFieldFontNames.put("HeiseiKakuGo-W5", new PdfName("KaGo"));
			_stdFieldFontNames.put("HeiseiMin-W3", new PdfName("KaMi"));
			_stdFieldFontNames.put("MHei-Medium", new PdfName("MHei"));
			_stdFieldFontNames.put("MSung-Light", new PdfName("MSun"));
			_stdFieldFontNames.put("STSong-Light", new PdfName("STSo"));
			_stdFieldFontNames.put("MSungStd-Light", new PdfName("MSun"));
			_stdFieldFontNames.put("STSongStd-Light", new PdfName("STSo"));
			_stdFieldFontNames.put("HYSMyeongJoStd-Medium", new PdfName("HySm"));
			_stdFieldFontNames.put("KozMinPro-Regular", new PdfName("KaMi"));
		}
		
		public function PdfAppearance($writer:PdfWriter=null)
		{
			super($writer);
			separator = 32;
		}
		
		override public function setFontAndSize( bf: BaseFont, size: Number): void
		{
			checkWriter();
			state.size = size;
			if (bf.fontType == BaseFont.FONT_TYPE_DOCUMENT) {
				throw new NonImplementatioError("Document font not yet supported");
			} else
			{
				state.fontDetails = writer.addSimpleFont(bf);
			}
			var psn: PdfName = stdFieldFontNames.getValue( bf.getPostscriptFontName() ) as PdfName;
			if (psn == null) 
			{
				if ( bf.subset && bf.fontType == BaseFont.FONT_TYPE_TTUNI )
					psn = state.fontDetails.fontName;
				else {
					psn = new PdfName( bf.getPostscriptFontName() );
					state.fontDetails.subset = false;
				}
			}
			var prs: PageResources = pageResources;
			prs.addFont(psn, state.fontDetails.indirectReference);
			content.append_bytes(psn.getBytes()).append_char(' ').append_number(size).append_string(" Tf").append_separator();
		}
		
		override public function duplicate(): PdfContentByte 
		{
			var tpl: PdfAppearance = new PdfAppearance( writer );
			tpl.pdf = pdf;
			tpl.thisReference = thisReference;
			tpl.pageResources = pageResources;
			tpl.bBox = RectangleElement.clone(bBox);
			tpl.group = group;
			tpl.layer = layer;
			if (_matrix != null) {
				tpl._matrix = new PdfArray(_matrix);
			}
			tpl.separator = separator;
			return tpl;
		}
		
		public static function createAppearance( writer: PdfWriter,  width: Number,  height: Number ): PdfAppearance
		{
			return _createAppearance( writer, width, height, null );
		}
		
		private static function _createAppearance(writer: PdfWriter, width: Number, height: Number, forcedName: PdfName ): PdfAppearance
		{
			var template: PdfAppearance = new PdfAppearance(writer);
			template.width = width;
			template.height = height;
			writer.addDirectTemplateSimple( template, forcedName );
			return template;
		}
	}
}