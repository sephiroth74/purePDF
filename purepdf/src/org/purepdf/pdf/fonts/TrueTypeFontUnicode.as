/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: TrueTypeFontUnicode.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/TrueTypeFontUnicode.as $
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
package org.purepdf.pdf.fonts
{
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfIndirectObject;
	import org.purepdf.pdf.PdfIndirectReference;
	import org.purepdf.pdf.PdfLiteral;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfObject;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.Utilities;
	import org.purepdf.utils.pdf_core;

	public class TrueTypeFontUnicode extends TrueTypeFont
	{
		use namespace pdf_core;
		
		private var vertical: Boolean = false;

		public function TrueTypeFontUnicode()
		{
			super();
		}
		
		override public function init( $ttFile: String, $enc: String, $emb: Boolean, $ttfAfm: Vector.<int>, $justNames: Boolean, $forceRead: Boolean ): void
		{
			var nameBase: String = getBaseName( $ttFile );
			var ttcName: String = getTTCName( nameBase );

			if ( nameBase.length < $ttFile.length )
			{
				style = $ttFile.substring( nameBase.length );
			}
			
			_encoding = $enc;
			embedded = $emb;
			fileName = ttcName;
			ttcIndex = "";

			if ( ttcName.length < nameBase.length )
				ttcIndex = nameBase.substring( ttcName.length + 1 );
			_fontType = FONT_TYPE_TTUNI;

			if ( ( StringUtils.endsWith( fileName.toLowerCase(), ".ttf" ) || StringUtils.endsWith( fileName.toLowerCase(),
							".otf" ) || StringUtils.endsWith( fileName.toLowerCase(), ".ttc" ) ) && ( ( $enc == IDENTITY_H || $enc ==
							IDENTITY_V ) && $emb ) )
			{
				
				rf = FontsResourceFactory.getInstance().getFontFile( fileName );
				rf.position = 0;
				
				process( $forceRead );

				if ( os_2.fsType == 2 )
					throw new DocumentError( fileName + " cannot be embedded due to licensing restrictions" );

				if ( ( cmap31 == null && !_fontSpecific ) || ( cmap10 == null && _fontSpecific ) )
					directTextToByte = true;

				if ( _fontSpecific )
				{
					_fontSpecific = false;
					var tempEncoding: String = encoding;
					_encoding = "";
					createEncoding();
					_encoding = tempEncoding;
					_fontSpecific = true;
				}
			} else
			{
				throw new DocumentError( fileName + " is not a ttf font file" );
			}
			vertical = StringUtils.endsWith( $enc, "V" );
		}
		
		override internal function convertToByte(char1:int) : Bytes
		{
			return null;
		}
		
		override internal function convertToBytes(char1:String) : Bytes
		{
			return null;
		}
		
		override public function getMetricsTT(c:int) : Vector.<int>
		{
			if( cmapExt != null )
				return cmapExt.getValue(c) as Vector.<int>;
			
			var map: HashMap = null;
			
			if (_fontSpecific)
				map = cmap10;
			else
				map = cmap31;
			
			if (map == null)
				return null;
			
			if( _fontSpecific )
			{
				if ((c & 0xffffff00) == 0 || (c & 0xffffff00) == 0xf000)
					return map.getValue(c & 0xff) as Vector.<int>;
				else
					return null;
			} else
			{
				return map.getValue( c ) as Vector.<int>;
			}
			return null;
		}
		
		override public function charExists(c:int) : Boolean
		{
			return getMetricsTT(c) != null;
		}
		
		
		override protected function _getWidthI( code: int ): int
		{
			if ( vertical )
				return 1000;

			if ( _fontSpecific )
			{
				if ( ( code & 0xFF00 ) == 0 || ( code & 0xFF00 ) == 0xF000 )
					return getRawWidth( code & 0xFF, null );
				else
					return 0;
			} else
			{
				return getRawWidth( code, encoding );
			}
		}

		override protected function _getWidthS( text: String ): int
		{
			if ( vertical )
				return text.length * 1000;
			var total: int = 0;
			var k: int;
			var c: int;
			var len: int;

			if ( _fontSpecific )
			{
				var cc: Vector.<int> = StringUtils.toCharArray( text );
				len = cc.length;

				for ( k = 0; k < len; ++k )
				{
					c = cc[k];

					if ( ( c & 0xff00 ) == 0 || ( c & 0xff00 ) == 0xf000 )
						total += getRawWidth( c & 0xff, null );
				}
			} else
			{
				len = text.length;

				for ( k = 0; k < len; ++k )
				{
					if ( Utilities.isSurrogatePair2( text, k ) )
					{
						total += getRawWidth( Utilities.convertToUtf32_2( text, k ), encoding );
						++k;
					} else
					{
						total += getRawWidth( text.charCodeAt( k ), encoding );
					}
				}
			}
			return total;
		}
		
		/** 
		 * Generates the CIDFontTyte2 dictionary.
		 * 
		 * @param fontDescriptor the indirect reference to the font descriptor
		 * @param subsetPrefix the subset prefix
		 * @param metrics the horizontal width metrics
		 * @return a stream
		 */    
		private function getCIDFontType2( fontDescriptor: PdfIndirectReference, subsetPrefix: String, metrics: Vector.<Object> ): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary( PdfName.FONT );
			
			if (cff) {
				throw new NonImplementatioError();
			} else 
			{
				dic.put( PdfName.SUBTYPE, PdfName.CIDFONTTYPE2 );
				dic.put( PdfName.BASEFONT, new PdfName(subsetPrefix + fontName) );
			}
			dic.put( PdfName.FONTDESCRIPTOR, fontDescriptor );
			
			if (!cff)
				dic.put(PdfName.CIDTOGIDMAP,PdfName.IDENTITY);
			
			var cdic: PdfDictionary = new PdfDictionary();
			cdic.put(PdfName.REGISTRY, new PdfString("Adobe"));
			cdic.put(PdfName.ORDERING, new PdfString("Identity"));
			cdic.put(PdfName.SUPPLEMENT, new PdfNumber(0));
			dic.put(PdfName.CIDSYSTEMINFO, cdic);
			
			if (!vertical) {
				dic.put(PdfName.DW, new PdfNumber(1000));
				var buf: String = "[";
				var lastNumber: int = -10;
				var firstTime: Boolean = true;
				
				for( var k: int = 0; k < metrics.length; ++k )
				{
					var metric: Vector.<int> = metrics[k] as Vector.<int>;
					if (metric[1] == 1000)
						continue;
					var m: int = metric[0];
					if (m == lastNumber + 1) {
						buf += ' ' + metric[1];
					} else 
					{
						if (!firstTime)
						{
							buf += ']';
						}
						firstTime = false;
						buf += m + '[' + metric[1];
					}
					lastNumber = m;
				}
				if (buf.length > 1) 
				{
					buf += "]]";
					dic.put(PdfName.W, new PdfLiteral(buf));
				}
			}
			return dic;
		}
		
		/** 
		 * Generates the font dictionary.
		 * 
		 * @param descendant the descendant dictionary
		 * @param subsetPrefix the subset prefix
		 * @param toUnicode the ToUnicode stream
		 * @return the stream
		 */    
		private function getFontBaseType2( descendant: PdfIndirectReference, subsetPrefix: String, toUnicode: PdfIndirectReference ): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary(PdfName.FONT);
			dic.put(PdfName.SUBTYPE, PdfName.TYPE0);
			if (cff)
				dic.put(PdfName.BASEFONT, new PdfName(subsetPrefix+fontName+"-"+encoding));
			else
				dic.put(PdfName.BASEFONT, new PdfName(subsetPrefix + fontName));
			dic.put(PdfName.ENCODING, new PdfName(encoding));
			dic.put(PdfName.DESCENDANTFONTS, new PdfArray(descendant));
			if (toUnicode != null)
				dic.put(PdfName.TOUNICODE, toUnicode);  
			return dic;
		}

		private function compareInts( a: Vector.<int>, b: Vector.<int> ): Number
		{
			var m1: int = a[0];
			var m2: int = b[0];
			return m1-m2;
		}
		
		
		override internal function writeFont(writer:PdfWriter, ref:PdfIndirectReference, params:Vector.<Object>) : void
		{
			var longTag: HashMap = HashMap(params[0]);
			addRangeUni(longTag, true, subset);
			
			var metrics: Vector.<Object> = new Vector.<Object>();
			for( var i: Iterator = longTag.values().iterator(); i.hasNext(); )
				metrics.push( i.next() );
			
			metrics.sort( compareInts );
			
			var ind_font: PdfIndirectReference = null;
			var pobj: PdfObject = null;
			var obj: PdfIndirectObject = null;
			var cidset: PdfIndirectReference = null;
			
			trace("need to check PDFXConformance");
			
			// sivan: cff
			if( cff ) 
			{
				throw new NonImplementatioError("write font with cff font not yet supported");
			} else
			{
				var b: Bytes;
				if (subset || directoryOffset != 0) 
				{
					var sb: TrueTypeFontSubSet = new TrueTypeFontSubSet(fileName, rf, longTag, directoryOffset, false, false);
					b = sb.process();
				}
				else {
					b = getFullFont();
				}
				var lengths: Vector.<int> = Vector.<int>([ b.length]);
				pobj = StreamFont.create( b, lengths, compressionLevel );
				obj = writer.addToBody(pobj);
				ind_font = obj.indirectReference;
			}
			var subsetPrefix: String = "";
			if (subset)
				subsetPrefix = createSubsetPrefix();
			var dic: PdfDictionary = getFontDescriptorRef(ind_font, subsetPrefix, cidset);
			obj = writer.addToBody(dic);
			ind_font = obj.indirectReference;
			
			pobj = getCIDFontType2(ind_font, subsetPrefix, metrics);
			obj = writer.addToBody(pobj);
			ind_font = obj.indirectReference;
			
			pobj = null; //getToUnicode(metrics);
			var toUnicodeRef: PdfIndirectReference = null;
			
			if (pobj != null) {
				obj = writer.addToBody(pobj);
				toUnicodeRef = obj.indirectReference;
			}
			
			pobj = getFontBaseType2(ind_font, subsetPrefix, toUnicodeRef);
			writer.addToBody1(pobj, ref);	
		}
	}
}