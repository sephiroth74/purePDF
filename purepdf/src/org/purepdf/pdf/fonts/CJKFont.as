/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: CJKFont.as 323 2010-02-10 18:16:22Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 323 $ $LastChangedDate: 2010-02-10 13:16:22 -0500 (Wed, 10 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/CJKFont.as $
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
	import it.sephiroth.utils.IntHashMap;
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
	import org.purepdf.pdf.PdfStream;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.cmaps.CJKFontResourceFactory;
	import org.purepdf.pdf.fonts.cmaps.CMapResourceFactory;
	import org.purepdf.resources.ICMap;
	import org.purepdf.utils.IProperties;
	import org.purepdf.utils.StringTokenizer;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.pdf_core;

	public class CJKFont extends BaseFont
	{
		use namespace pdf_core;
		
		public static const CJK_ENCODING: String = "UnicodeBigUnmarked";
		public static const cjkEncodings: Object = { "UniJIS-UCS2-H": "UniJIS-UCS2-H",
							"UniJIS-UCS2-V": "UniJIS-UCS2-H UniJIS-UCS2-V", "UniJIS-UCS2-HW-H": "UniJIS-UCS2-H UniJIS-UCS2-HW-H",
							"UniJIS-UCS2-HW-V": "UniJIS-UCS2-H UniJIS-UCS2-HW-V", "UniGB-UCS2-H": "UniGB-UCS2-H",
							"UniGB-UCS2-V": "UniGB-UCS2-H UniGB-UCS2-V", "UniCNS-UCS2-H": "UniCNS-UCS2-H",
							"UniCNS-UCS2-V": "UniCNS-UCS2-H UniCNS-UCS2-V", "UniKS-UCS2-H": "UniKS-UCS2-H",
							"UniKS-UCS2-V": "UniKS-UCS2-H UniKS-UCS2-V" }
		public static const cjkFonts: Object =
						{ "HeiseiMin-W3": "Adobe-Japan1-UCS2_UniJIS-UCS2-H_UniJIS-UCS2-V_UniJIS-UCS2-HW-H_UniJIS-UCS2-HW-V_",
							"HeiseiKakuGo-W5": "Adobe-Japan1-UCS2_UniJIS-UCS2-H_UniJIS-UCS2-V_UniJIS-UCS2-HW-H_UniJIS-UCS2-HW-V_",
							"KozMinPro-Regular": "Adobe-Japan1-UCS2_UniJIS-UCS2-H_UniJIS-UCS2-V_UniJIS-UCS2-HW-H_UniJIS-UCS2-HW-V_",
							"STSong-Light": "Adobe-GB1-UCS2_UniGB-UCS2-H_UniGB-UCS2-V_",
							"STSongStd-Light": "Adobe-GB1-UCS2_UniGB-UCS2-H_UniGB-UCS2-V_",
							"MHei-Medium": "Adobe-CNS1-UCS2_UniCNS-UCS2-H_UniCNS-UCS2-V_",
							"MSung-Light": "Adobe-CNS1-UCS2_UniCNS-UCS2-H_UniCNS-UCS2-V_",
							"MSungStd-Light": "Adobe-CNS1-UCS2_UniCNS-UCS2-H_UniCNS-UCS2-V_",
							"HYGoThic-Medium": "Adobe-Korea1-UCS2_UniKS-UCS2-H_UniKS-UCS2-V_",
							"HYSMyeongJo-Medium": "Adobe-Korea1-UCS2_UniKS-UCS2-H_UniKS-UCS2-V_",
							"HYSMyeongJoStd-Medium": "Adobe-Korea1-UCS2_UniKS-UCS2-H_UniKS-UCS2-V_" }
		private static const BRACKET: int = 1;
		private static const FIRST: int = 0;
		private static const SERIAL: int = 2;
		private static const V1Y: int = 880;
		private static var allCMaps: Object = new Object();
		private static var allFonts: Object = new Object();
		private static var propertiesLoaded: Boolean = false;
		private var CMap: String;
		private var cidDirect: Boolean = false;
		private var fontDesc: HashMap;
		private var fontName: String;
		private var hMetrics: Object;
		private var style: String = "";
		private var translationMap: Vector.<int>;
		private var vMetrics: Object;
		private var vertical: Boolean = false;

		public function CJKFont()
		{
			super();
		}

		override public function charExists( c: int ): Boolean
		{
			return translationMap[c] != 0;
		}

		public function getAllNameEntries(): Vector.<Vector.<String>>
		{
			return Vector.<Vector.<String>>( [Vector.<String>( ["4", "", "", fontName] )] );
		}

		override public function getCharBBox( c: int ): Vector.<int>
		{
			return null;
		}

		public function getCidCode( c: int ): int
		{
			if ( cidDirect )
				return c;
			return translationMap[c];
		}

		override public function getFamilyFontName(): Vector.<Vector.<String>>
		{
			return getFullFontName();
		}

		override public function getFontDescriptor( key: int, fontSize: Number ): Number
		{
			switch ( key )
			{
				case AWT_ASCENT:
				case ASCENT:
					return getDescNumber( "Ascent" ) * fontSize / 1000;
				case CAPHEIGHT:
					return getDescNumber( "CapHeight" ) * fontSize / 1000;
				case AWT_DESCENT:
				case DESCENT:
					return getDescNumber( "Descent" ) * fontSize / 1000;
				case ITALICANGLE:
					return getDescNumber( "ItalicAngle" );
				case BBOXLLX:
					return fontSize * getBBox( 0 ) / 1000;
				case BBOXLLY:
					return fontSize * getBBox( 1 ) / 1000;
				case BBOXURX:
					return fontSize * getBBox( 2 ) / 1000;
				case BBOXURY:
					return fontSize * getBBox( 3 ) / 1000;
				case AWT_LEADING:
					return 0;
				case AWT_MAXADVANCE:
					return fontSize * ( getBBox( 2 ) - getBBox( 0 ) ) / 1000;
			}
			return 0;
		}

		public function getFullFontName(): Vector.<Vector.<String>>
		{
			return Vector.<Vector.<String>>( [Vector.<String>( ["", "", fontName] )] );
		}

		override public function getKerning( char1: int, char2: int ): int
		{
			return 0;
		}

		override public function getPostscriptFontName(): String
		{
			return fontName;
		}

		override public function getUnicodeEquivalent( c: int ): int
		{
			if ( cidDirect )
				return translationMap[c];
			return c;
		}

		override public function hasKernPairs(): Boolean
		{
			return false;
		}

		public function init( name: String, enc: String, emb: Boolean ): void
		{
			_fontType = FONT_TYPE_CJK;
			var nameBase: String = getBaseName( name );
			var s: String;
			var c: Vector.<int>;

			if ( !isCJKFont( nameBase, enc ) )
				throw new DocumentError( "font " + name + " with " + enc + " is not a CJK valid font" );

			if ( nameBase.length < name.length )
			{
				style = fontName.substring( nameBase.length );
				name = nameBase;
			}
			fontName = name;
			_encoding = CJK_ENCODING;
			vertical = StringUtils.endsWith( enc, "V" );
			CMap = enc;

			if ( StringUtils.startsWith( enc, "Identity-" ) )
			{
				cidDirect = true;
				s = cjkFonts[fontName];
				s = s.substring( 0, s.indexOf( '_' ) );
				c = allCMaps[s] as Vector.<int>;
				
				if ( c == null )
				{
					c = readCMap( s );

					if ( c == null )
						throw new DocumentError( "cmap " + s + " does not exists as a resource" );
					c['\U7fff'.charCodeAt(0)] = 10;
					allCMaps[s] = c;
				}
				translationMap = c;
			} else
			{
				c = allCMaps[enc] as Vector.<int>;

				if ( c == null )
				{
					s = cjkEncodings[enc];

					if ( s == null )
						throw new DocumentError( "the resource cjkencodings does not contain the encoding " + enc );
					var tk: StringTokenizer = new StringTokenizer( s );
					var nt: String = tk.nextToken();
					c = allCMaps[nt] as Vector.<int>;

					if ( c == null )
					{
						c = readCMap( nt );
						allCMaps[nt] = c;
					}

					if ( tk.hasMoreTokens() )
					{
						var nt2: String = tk.nextToken();
						var m2: Vector.<int> = readCMap( nt2 );

						for ( var k: int = 0; k < 0x10000; ++k )
						{
							if ( m2[k] == 0 )
								m2[k] = c[k];
						}
						allCMaps[enc] = m2;
						c = m2;
					}
				}
				translationMap = c;
			}
			fontDesc = allFonts[fontName] as HashMap;

			if ( fontDesc == null )
			{
				fontDesc = readFontProperties( name );
				allFonts[fontName] = fontDesc;
			}
			hMetrics = fontDesc.getValue( "W" );
			vMetrics = fontDesc.getValue( "W2" );
		}

		override public function setKerning( char1: int, char2: int, kern: int ): Boolean
		{
			return false;
		}

		public function setPostscriptFontName( value: String ): void
		{
			fontName = value;
		}
		
		private function _getFontDescriptor(): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary(PdfName.FONTDESCRIPTOR);
			dic.put(PdfName.ASCENT, new PdfLiteral( String(fontDesc.getValue("Ascent"))) );
			dic.put(PdfName.CAPHEIGHT, new PdfLiteral( String(fontDesc.getValue("CapHeight"))) );
			dic.put(PdfName.DESCENT, new PdfLiteral( String(fontDesc.getValue("Descent"))));
			dic.put(PdfName.FLAGS, new PdfLiteral( String(fontDesc.getValue("Flags"))));
			dic.put(PdfName.FONTBBOX, new PdfLiteral( String(fontDesc.getValue("FontBBox"))));
			dic.put(PdfName.FONTNAME, new PdfName(fontName + style));
			dic.put(PdfName.ITALICANGLE, new PdfLiteral( String(fontDesc.getValue("ItalicAngle"))));
			dic.put(PdfName.STEMV, new PdfLiteral( String(fontDesc.getValue("StemV"))));
			var pdic: PdfDictionary = new PdfDictionary();
			pdic.put(PdfName.PANOSE, new PdfString( String(fontDesc.getValue("Panose")), null));
			dic.put(PdfName.STYLE, pdic);
			return dic;
		}

		override internal function writeFont(writer:PdfWriter, ref:PdfIndirectReference, params:Vector.<Object>) : void
		{
			var cjkTag: IntHashMap = params[0] as IntHashMap;
			var ind_font: PdfIndirectReference = null;
			var pobj: PdfObject = null;
			var obj: PdfIndirectObject = null;
			
			pobj = _getFontDescriptor();
			if (pobj != null){
				obj = writer.addToBody(pobj);
				ind_font = obj.indirectReference;
			}
			pobj = getCIDFont(ind_font, cjkTag);
			if (pobj != null){
				obj = writer.addToBody(pobj);
				ind_font = obj.indirectReference;
			}
			
			pobj = getFontBaseType(ind_font);
			writer.addToBody1(pobj, ref);			
		}
		
		override protected function _getWidthI( code: int ): int
		{
			var c: int = code;

			if ( !cidDirect )
				c = translationMap[c];
			var v: int;

			if ( vertical )
				v = vMetrics[c];
			else
				v = hMetrics[c];

			if ( v > 0 )
				return v;
			else
				return 1000;
		}

		override protected function _getWidthS( text: String ): int
		{
			var total: int = 0;
			var v: int;
			var c: int;

			for ( var k: int = 0; k < text.length; ++k )
			{
				c = text.charCodeAt( k );

				if ( !cidDirect )
					c = translationMap[c];

				if ( vertical )
					v = vMetrics[c];
				else
					v = hMetrics[c];

				if ( v > 0 )
					total += v;
				else
					total += 1000;
			}
			return total;
		}

		override protected function getRawCharBBox( c: int, name: String ): Vector.<int>
		{
			return null;
		}

		override protected function getRawWidth( c: int, name: String ): int
		{
			return 0;
		}

		private function getBBox( idx: int ): Number
		{
			var s: String = fontDesc.getValue( "FontBBox" ) as String;
			var tk: StringTokenizer = new StringTokenizer( s, /[ \[\]\r\n\t\f]+/g );
			var ret: String = tk.nextToken();

			for ( var k: int = 0; k < idx; ++k )
				ret = tk.nextToken();
			return parseInt( ret );
		}

		private function getCIDFont( fontDescriptor: PdfIndirectReference, cjkTag: IntHashMap ): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary( PdfName.FONT );
			dic.put( PdfName.SUBTYPE, PdfName.CIDFONTTYPE0 );
			dic.put( PdfName.BASEFONT, new PdfName( fontName + style ) );
			dic.put( PdfName.FONTDESCRIPTOR, fontDescriptor );
			
			var keys: Vector.<int> = cjkTag.toOrderedKeys();
			
			var w: String = convertToHCIDMetrics( keys, hMetrics );

			if ( w != null )
				dic.put( PdfName.W, new PdfLiteral( w ) );

			if ( vertical )
			{
				w = convertToVCIDMetrics(keys, vMetrics, hMetrics);
				if (w != null)
					dic.put(PdfName.W2, new PdfLiteral(w));
			} else
			{
				dic.put( PdfName.DW, new PdfNumber( 1000 ) );
			}
			var cdic: PdfDictionary = new PdfDictionary();
			cdic.put( PdfName.REGISTRY, new PdfString( String( fontDesc.getValue( "Registry" ) ), null ) );
			cdic.put( PdfName.ORDERING, new PdfString( String( fontDesc.getValue( "Ordering" ) ), null ) );
			cdic.put( PdfName.SUPPLEMENT, new PdfLiteral( String( fontDesc.getValue( "Supplement" ) ) ) );
			dic.put( PdfName.CIDSYSTEMINFO, cdic );
			return dic;
		}

		private function getDescNumber( name: String ): Number
		{
			return parseInt( String( fontDesc.getValue( name ) ) );
		}

		private function getFontBaseType( CIDFont: PdfIndirectReference ): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary( PdfName.FONT );
			dic.put( PdfName.SUBTYPE, PdfName.TYPE0 );
			var name: String = fontName;

			if ( style.length > 0 )
				name += "-" + style.substring( 1 );
			name += "-" + CMap;
			dic.put( PdfName.BASEFONT, new PdfName( name ) );
			dic.put( PdfName.ENCODING, new PdfName( CMap ) );
			dic.put( PdfName.DESCENDANTFONTS, new PdfArray( CIDFont ) );
			return dic;
		}

		override internal function getFullFontStream(): PdfStream
		{
			return null;
		}

		static public function isCJKFont( fontName: String, enc: String ): Boolean
		{
			var encodings: String = cjkFonts[fontName];
			return ( encodings != null && ( enc == BaseFont.IDENTITY_H || enc == BaseFont.IDENTITY_V || encodings.indexOf( "_" +
							enc + "_" ) >= 0 ) );
		}

		static private function convertToHCIDMetrics( keys: Vector.<int>, h: Object ): String
		{
			if ( keys.length == 0 )
				return null;
			var lastCid: int = 0;
			var lastValue: int = 0;
			var start: int;
			var k: int;

			for ( start = 0; start < keys.length; ++start )
			{
				lastCid = keys[start];
				lastValue = h[lastCid];

				if ( lastValue != 0 )
				{
					++start;
					break;
				}
			}

			if ( lastValue == 0 )
				return null;
			var buf: String = "";
			buf += "[";
			buf += lastCid;
			var state: int = FIRST;

			for ( k = start; k < keys.length; ++k )
			{
				var cid: int = keys[k];
				var value: int = h[cid];

				if ( value == 0 )
					continue;

				switch ( state )
				{
					case FIRST:
						if ( cid == lastCid + 1 && value == lastValue )
						{
							state = SERIAL;
						} else if ( cid == lastCid + 1 )
						{
							state = BRACKET;
							buf += '[' + lastValue;
						} else
						{
							buf += '[' + lastValue + ']' + cid;
						}
						break;
					case BRACKET:
						if ( cid == lastCid + 1 && value == lastValue )
						{
							state = SERIAL;
							buf += ']' + lastCid;
						} else if ( cid == lastCid + 1 )
						{
							buf += ' ' + lastValue;
						} else
						{
							state = FIRST;
							buf += ' ' + lastValue + ']' + cid;
						}
						break;
					case SERIAL:
						if ( cid != lastCid + 1 || value != lastValue )
						{
							buf += ' ' + lastCid + ' ' + lastValue + ' ' + cid;
							state = FIRST;
						}
						break;
				}
				lastValue = value;
				lastCid = cid;
			}

			switch ( state )
			{
				case FIRST:
					buf += '[' + lastValue + "]]";
					break;
				case BRACKET:
					buf += ' ' + lastValue + "]]";
					break;
				case SERIAL:
					buf += ' ' + lastCid + ' ' + lastValue + ']';
					break;
			}
			return buf;
		}

		static private function createMetric( s: String ): Object
		{
			var h: Object = new Object();
			var tk: StringTokenizer = new StringTokenizer( s );

			while ( tk.hasMoreTokens() )
			{
				var n1: int = parseInt( tk.nextToken() );
				h[n1] = parseInt( tk.nextToken() );
			}
			return h;
		}

		static private function readCMap( name: String ): Vector.<int>
		{
			try
			{
				name = name + ".cmap";
				var cmap: ICMap = CMapResourceFactory.getInstance().getCMap( name );
				if( cmap == null )
					trace("could not load " + name  );
				return cmap.chars;
			} catch ( e: Error )
			{
				// empty on purpose
			}
			return null;
		}

		static private function readFontProperties( name: String ): HashMap
		{
			try
			{
				name += ".properties";
				var p: IProperties = CJKFontResourceFactory.getInstance().getProperty( name );
				
				if( p == null )
					trace("could not load " + name );
					
				var W: Object = createMetric( p.getProperty( "W" ) );
				p.remove( "W" );
				var W2: Object;

				if ( p.hasProperty( "W2" ) )
				{
					W2 = createMetric( p.getProperty( "W2" ) );
					p.remove( "W2" );
				}
				var map: HashMap = new HashMap();

				for ( var i: Iterator = p.keys.iterator(); i.hasNext();  )
				{
					var obj: Object = i.next();
					map.put( obj, p.getProperty( String( obj ) ) );
				}
				map.put( "W", W );

				if ( W2 != null )
					map.put( "W2", W2 );
				return map;
			} catch ( e: Error )
			{
				// empty on purpose
				//throw e;
			}
			return null;
		}
		
		
		internal static function convertToVCIDMetrics(keys: Vector.<int>, v: Object, h: Object ): String
		{
			if (keys.length == 0)
				return null;
			var lastCid: int = 0;
			var lastValue: int = 0;
			var lastHValue: int = 0;
			var start: int;
			for (start = 0; start < keys.length; ++start) 
			{
				lastCid = keys[start];
				lastValue = v[lastCid];
				if (lastValue != 0) {
					++start;
					break;
				}
				else
					lastHValue = h[lastCid];
			}
			if (lastValue == 0)
				return null;
			if (lastHValue == 0)
				lastHValue = 1000;
			var buf: String = "";
			buf += '[';
			buf += lastCid;
			var state: int = FIRST;
			var cid: int;
			var value: int;
			var hValue: int;
			for ( var k: int = start; k < keys.length; ++k) 
			{
				cid = keys[k];
				value = v[cid];
				if (value == 0)
					continue;
				hValue = h[lastCid];
				if (hValue == 0)
					hValue = 1000;
				switch (state) {
					case FIRST: {
						if (cid == lastCid + 1 && value == lastValue && hValue == lastHValue) {
							state = SERIAL;
						}
						else {
							buf += ' ' + lastCid + ' ' + -lastValue + ' ' + (lastHValue / 2) + ' ' + V1Y + ' ' + cid;
						}
						break;
					}
					case SERIAL: {
						if (cid != lastCid + 1 || value != lastValue || hValue != lastHValue) {
							buf += ' ' + lastCid + ' ' + (-lastValue) + ' '+ (lastHValue / 2) + ' ' + V1Y + ' ' + cid;
							state = FIRST;
						}
						break;
					}
				}
				lastValue = value;
				lastCid = cid;
				lastHValue = hValue;
			}
			buf += ' ' + lastCid + ' ' + (-lastValue) + ' ' + (lastHValue / 2) + ' ' + V1Y + " ]";
			return buf;
		}
		
	}
}