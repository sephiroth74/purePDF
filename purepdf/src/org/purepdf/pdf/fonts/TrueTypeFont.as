/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: TrueTypeFont.as 249 2010-02-02 06:59:26Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 249 $ $LastChangedDate: 2010-02-02 01:59:26 -0500 (Tue, 02 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/TrueTypeFont.as $
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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import it.sephiroth.utils.Entry;
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.collections.iterators.Iterator;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfEncodings;
	import org.purepdf.pdf.PdfIndirectObject;
	import org.purepdf.pdf.PdfIndirectReference;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfObject;
	import org.purepdf.pdf.PdfRectangle;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.utils.ByteArrayUtils;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.pdf_core;

	public class TrueTypeFont extends BaseFont
	{

		use namespace pdf_core;

		private static const codePages: Vector.<String> = Vector.<String>( [ "1252 Latin 1", "1250 Latin 2: Eastern Europe", "1251 Cyrillic", "1253 Greek",
				"1254 Turkish", "1255 Hebrew", "1256 Arabic", "1257 Windows Baltic", "1258 Vietnamese", null, null, null, null, null, null, null, "874 Thai",
				"932 JIS/Japan", "936 Chinese: Simplified chars--PRC and Singapore", "949 Korean Wansung", "950 Chinese: Traditional chars--Taiwan and Hong Kong",
				"1361 Korean Johab", null, null, null, null, null, null, null, "Macintosh Character Set (US Roman)", "OEM Character Set", "Symbol Character Set",
				null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, "869 IBM Greek", "866 MS-DOS Russian",
				"865 MS-DOS Nordic", "864 Arabic", "863 MS-DOS Canadian French", "862 Hebrew", "861 MS-DOS Icelandic", "860 MS-DOS Portuguese", "857 IBM Turkish",
				"855 IBM Cyrillic; primarily Russian", "852 Latin 2", "775 MS-DOS Baltic", "737 Greek; former 437 G", "708 Arabic; ASMO 708", "850 WE/Latin 1",
				"437 US" ] );

		protected var GlyphWidths: Vector.<int>;
		protected var allNameEntries: Vector.<Vector.<String>>;
		protected var bboxes: Vector.<Vector.<int>>;
		protected var cff: Boolean = false;
		protected var cffLength: int = 0;
		protected var cffOffset: int = 0;
		protected var cmap10: HashMap;
		protected var cmap31: HashMap;
		protected var cmapExt: HashMap;
		protected var directoryOffset: int = 0;
		protected var familyName: Vector.<Vector.<String>>;
		protected var fileName: String;
		protected var fontName: String;
		protected var fullName: Vector.<Vector.<String>>;
		protected var head: FontHeader = new FontHeader();
		protected var hhea: HorizontalHeader = new HorizontalHeader();
		protected var isFixedPitch: Boolean = false;
		protected var italicAngle: Number = 0;
		protected var justNames: Boolean = false;
		protected var kerning: Dictionary = new Dictionary();
		protected var kerning_size: int = 0;
		protected var os_2: WindowsMetrics = new WindowsMetrics();
		protected var rf: ByteArray;
		protected var style: String = "";
		protected var tables: HashMap;
		protected var ttcIndex: String = "";
		protected var underlinePosition: int = 0;
		protected var underlineThickness: int = 0;

		public function TrueTypeFont()
		{
			super();
		}

		override public function getFamilyFontName(): Vector.<Vector.<String>>
		{
			return familyName;
		}


		/** Gets the font parameter identified by <CODE>key</CODE>. Valid values
		 * for <CODE>key</CODE> are <CODE>ASCENT</CODE>, <CODE>CAPHEIGHT</CODE>, <CODE>DESCENT</CODE>
		 * and <CODE>ITALICANGLE</CODE>.
		 * @param key the parameter to be extracted
		 * @param fontSize the font size in points
		 * @return the parameter in points
		 */
		override public function getFontDescriptor( key: int, fontSize: Number ): Number
		{
			switch ( key )
			{
				case ASCENT:
					return os_2.sTypoAscender * fontSize / head.unitsPerEm;
				case CAPHEIGHT:
					return os_2.sCapHeight * fontSize / head.unitsPerEm;
				case DESCENT:
					return os_2.sTypoDescender * fontSize / head.unitsPerEm;
				case ITALICANGLE:
					return italicAngle;
				case BBOXLLX:
					return fontSize * head.xMin / head.unitsPerEm;
				case BBOXLLY:
					return fontSize * head.yMin / head.unitsPerEm;
				case BBOXURX:
					return fontSize * head.xMax / head.unitsPerEm;
				case BBOXURY:
					return fontSize * head.yMax / head.unitsPerEm;
				case AWT_ASCENT:
					return fontSize * hhea.Ascender / head.unitsPerEm;
				case AWT_DESCENT:
					return fontSize * hhea.Descender / head.unitsPerEm;
				case AWT_LEADING:
					return fontSize * hhea.LineGap / head.unitsPerEm;
				case AWT_MAXADVANCE:
					return fontSize * hhea.advanceWidthMax / head.unitsPerEm;
				case UNDERLINE_POSITION:
					return ( underlinePosition - underlineThickness / 2 ) * fontSize / head.unitsPerEm;
				case UNDERLINE_THICKNESS:
					return underlineThickness * fontSize / head.unitsPerEm;
				case STRIKETHROUGH_POSITION:
					return os_2.yStrikeoutPosition * fontSize / head.unitsPerEm;
				case STRIKETHROUGH_THICKNESS:
					return os_2.yStrikeoutSize * fontSize / head.unitsPerEm;
				case SUBSCRIPT_SIZE:
					return os_2.ySubscriptYSize * fontSize / head.unitsPerEm;
				case SUBSCRIPT_OFFSET:
					return -os_2.ySubscriptYOffset * fontSize / head.unitsPerEm;
				case SUPERSCRIPT_SIZE:
					return os_2.ySuperscriptYSize * fontSize / head.unitsPerEm;
				case SUPERSCRIPT_OFFSET:
					return os_2.ySuperscriptYOffset * fontSize / head.unitsPerEm;
			}
			return 0;
		}

		/**
		 * Gets the glyph index and metrics for a character.
		 */
		public function getMetricsTT( c: int ): Vector.<int>
		{
			if ( cmapExt != null )
				return cmapExt.getValue( c ) as Vector.<int>;

			if ( !_fontSpecific && cmap31 != null )
				return cmap31.getValue( c ) as Vector.<int>;

			if ( _fontSpecific && cmap10 != null )
				return cmap10.getValue( c ) as Vector.<int>;

			if ( cmap31 != null )
				return cmap31.getValue( c ) as Vector.<int>;

			if ( cmap10 != null )
				return cmap10.getValue( c ) as Vector.<int>;
			return null;
		}

		override public function hasKernPairs(): Boolean
		{
			return kerning_size > 0;
		}

		/** Creates a new TrueType font.
		 * @param enc the encoding to be applied to this font
		 * @param emb true if the font is to be embedded in the PDF
		 * @param ttfAfm
		 * @throws DocumentError
		 * @throws IOError
		 */
		public function init( $ttFile: String, $enc: String, $emb: Boolean, $ttfAfm: Vector.<int>, $justNames: Boolean, $forceRead: Boolean ): void
		{
			justNames = $justNames;
			var nameBase: String = getBaseName( $ttFile );
			var ttcName: String = getTTCName( nameBase );

			if ( nameBase.length < $ttFile.length )
				style = $ttFile.substring( nameBase.length );

			_encoding = $enc;
			embedded = $emb;
			fileName = ttcName;
			_fontType = FONT_TYPE_TT;
			ttcIndex = "";

			if ( ttcName.length < nameBase.length )
				ttcIndex = nameBase.substring( ttcName.length + 1 );

			if ( StringUtils.endsWith( fileName.toLowerCase(), ".ttf" ) || StringUtils.endsWith( fileName.toLowerCase(), ".otf" ) || StringUtils.endsWith( fileName.
					toLowerCase(), ".ttc" ) )
			{
				rf = FontsResourceFactory.getInstance().getFontFile( fileName );
				rf.position = 0;
				process( $forceRead );

				if ( !justNames && embedded && os_2.fsType == 2 )
					throw new DocumentError( fileName + " cannot be embedded due to licensing restrictions" );
			} else
				throw new DocumentError( fileName + " is not a ttf otf or ttc font file" );

			if ( !StringUtils.startsWith( encoding, "#" ) )
				PdfEncodings.convertToBytes( " ", $enc ); // check if the encoding exists
			createEncoding();
		}

		override public function setKerning( char1: int, char2: int, kern: int ): Boolean
		{
			var metrics: Vector.<int> = getMetricsTT( char1 );

			if ( metrics == null )
				return false;
			var c1: int = metrics[0];
			metrics = getMetricsTT( char2 );

			if ( metrics == null )
				return false;
			var c2: int = metrics[0];
			kerning[( c1 << 16 ) + c2] = kern;
			kerning_size++;
			return true;
		}

		protected function addRangeUni( longTag: HashMap, includeMetrics: Boolean, subsetp: Boolean ): void
		{
			if ( !subsetp && ( subsetRanges != null || directoryOffset > 0 ) )
			{
				var rg: Vector.<int> = ( subsetRanges == null && directoryOffset > 0 ) ? Vector.<int>( [ 0, 0xffff ] ) : compactRanges( subsetRanges );
				var usemap: HashMap;

				if ( !_fontSpecific && cmap31 != null )
					usemap = cmap31;
				else if ( _fontSpecific && cmap10 != null )
					usemap = cmap10;
				else if ( cmap31 != null )
					usemap = cmap31;
				else
					usemap = cmap10;

				var v: Vector.<int>;
				var gi: int;
				var c: int;
				var k: int;

				for ( var it: Iterator = usemap.entrySet().iterator(); it.hasNext();  )
				{
					var e: Entry = Entry( it.next() );
					v = e.getValue() as Vector.<int>;
					gi = v[0];

					if ( longTag.containsKey( gi ) )
						continue;

					c = int( e.getKey() );
					var skip: Boolean = true;

					for ( k = 0; k < rg.length; k += 2 )
					{
						if ( c >= rg[k] && c <= rg[k + 1] )
						{
							skip = false;
							break;
						}
					}

					if ( !skip )
						longTag.put( gi, includeMetrics ? Vector.<int>( [ v[0], v[1], c ] ) : null );
				}
			}
		}

		/**
		 * Generates the font dictionary for this font.
		 * @return the PdfDictionary containing the font dictionary
		 */
		protected function getFontBaseType( fontDescriptor: PdfIndirectReference, subsetPrefix: String, firstChar: int, lastChar: int, shortTag: Vector.<int> ): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary( PdfName.FONT );
			var k: int;

			if ( cff )
			{
				dic.put( PdfName.SUBTYPE, PdfName.TYPE1 );
				dic.put( PdfName.BASEFONT, new PdfName( fontName + style ) );
			} else
			{
				dic.put( PdfName.SUBTYPE, PdfName.TRUETYPE );
				dic.put( PdfName.BASEFONT, new PdfName( subsetPrefix + fontName + style ) );
			}
			dic.put( PdfName.BASEFONT, new PdfName( subsetPrefix + fontName + style ) );

			if ( !_fontSpecific )
			{
				for ( k = firstChar; k <= lastChar; ++k )
				{
					if ( !differences[k] == notdef )
					{
						firstChar = k;
						break;
					}
				}

				if ( encoding == "Cp1252" || encoding == "MacRoman" )
					dic.put( PdfName.ENCODING, encoding == "Cp1252" ? PdfName.WIN_ANSI_ENCODING : PdfName.MAC_ROMAN_ENCODING );
				else
				{
					var enc: PdfDictionary = new PdfDictionary( PdfName.ENCODING );
					var dif: PdfArray = new PdfArray();
					var gap: Boolean = true;

					for ( k = firstChar; k <= lastChar; ++k )
					{
						if ( shortTag[k] != 0 )
						{
							if ( gap )
							{
								dif.add( new PdfNumber( k ) );
								gap = false;
							}
							dif.add( new PdfName( differences[k] ) );
						} else
							gap = true;
					}
					enc.put( PdfName.DIFFERENCES, dif );
					dic.put( PdfName.ENCODING, enc );
				}
			}
			dic.put( PdfName.FIRSTCHAR, new PdfNumber( firstChar ) );
			dic.put( PdfName.LASTCHAR, new PdfNumber( lastChar ) );
			var wd: PdfArray = new PdfArray();

			for ( k = firstChar; k <= lastChar; ++k )
			{
				if ( shortTag[k] == 0 )
					wd.add( new PdfNumber( 0 ) );
				else
					wd.add( new PdfNumber( widths[k] ) );
			}
			dic.put( PdfName.WIDTHS, wd );

			if ( fontDescriptor != null )
				dic.put( PdfName.FONTDESCRIPTOR, fontDescriptor );
			return dic;
		}

		/**
		 * Generates the font descriptor for this font.
		 */
		protected function getFontDescriptorRef( fontStream: PdfIndirectReference, subsetPrefix: String, cidset: PdfIndirectReference ): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary( PdfName.FONTDESCRIPTOR );
			dic.put( PdfName.ASCENT, new PdfNumber( os_2.sTypoAscender * 1000 / head.unitsPerEm ) );
			dic.put( PdfName.CAPHEIGHT, new PdfNumber( os_2.sCapHeight * 1000 / head.unitsPerEm ) );
			dic.put( PdfName.DESCENT, new PdfNumber( os_2.sTypoDescender * 1000 / head.unitsPerEm ) );
			dic.put( PdfName.FONTBBOX, new PdfRectangle( head.xMin * 1000 / head.unitsPerEm, head.yMin * 1000 / head.unitsPerEm, head.xMax * 1000 / head.
					unitsPerEm, head.yMax * 1000 / head.unitsPerEm ) );

			if ( cidset != null )
				dic.put( PdfName.CIDSET, cidset );

			if ( cff )
			{
				if ( StringUtils.startsWith( encoding, "Identity-" ) )
					dic.put( PdfName.FONTNAME, new PdfName( subsetPrefix + fontName + "-" + encoding ) );
				else
					dic.put( PdfName.FONTNAME, new PdfName( subsetPrefix + fontName + style ) );
			} else
				dic.put( PdfName.FONTNAME, new PdfName( subsetPrefix + fontName + style ) );
			dic.put( PdfName.ITALICANGLE, new PdfNumber( italicAngle ) );
			dic.put( PdfName.STEMV, new PdfNumber( 80 ) );

			if ( fontStream != null )
			{
				if ( cff )
					dic.put( PdfName.FONTFILE3, fontStream );
				else
					dic.put( PdfName.FONTFILE2, fontStream );
			}
			var flags: int = 0;

			if ( isFixedPitch )
				flags |= 1;
			flags |= _fontSpecific ? 4 : 32;

			if ( ( head.macStyle & 2 ) != 0 )
				flags |= 64;

			if ( ( head.macStyle & 1 ) != 0 )
				flags |= 262144;
			dic.put( PdfName.FLAGS, new PdfNumber( flags ) );

			return dic;
		}

		/**
		 *
		 * @throws EOFError
		 */
		protected function getFullFont(): Bytes
		{
			var rf2: ByteArray;

			try
			{
				rf2 = new ByteArray();
				rf2.writeBytes( rf, 0, rf.length );
				rf2.position = 0;
				var b: Bytes = new Bytes( rf2.length );
				rf2.readBytes( b.buffer, 0, b.length );
				return b;
			} finally
			{
			}
			return null;
		}

		/**
		 * Gets width of a glyph
		 */
		protected function getGlyphWidth( glyph: int ): int
		{
			if ( glyph >= GlyphWidths.length )
				glyph = GlyphWidths.length - 1;
			return GlyphWidths[glyph];
		}

		override protected function getRawCharBBox( c: int, name: String ): Vector.<int>
		{
			var map: HashMap = null;

			if ( name == null || cmap31 == null )
				map = cmap10;
			else
				map = cmap31;

			if ( map == null )
				return null;

			var metric: Vector.<int> = map.getValue( c ) as Vector.<int>;

			if ( metric == null || bboxes == null )
				return null;
			return bboxes[metric[0]];
		}

		override protected function getRawWidth( c: int, name: String ): int
		{
			var metric: Vector.<int> = getMetricsTT( c );

			if ( metric == null )
				return 0;
			return metric[1];
		}

		/**
		 * Read the font data
		 *
		 * @throws DocumentError
		 * @throws IOError
		 */
		protected function process( preload: Boolean ): void
		{
			tables = new HashMap();

			try
			{
				if ( ttcIndex.length > 0 )
				{
					var dirIdx: int = parseInt( ttcIndex );

					if ( dirIdx < 0 )
						throw new DocumentError( "the font index must be positive" );
					var mainTag: String = readStandardString( 4 );

					if ( !mainTag == "ttcf" )
						throw new DocumentError( fileName + " is not a valid ttc file" );

					rf.position += 4;
					var dirCount: int = rf.readInt();

					if ( dirIdx >= dirCount )
						throw new DocumentError( "the font index must be between " + ( dirCount - 1 ) + " and " + dirIdx );
					rf.position += dirIdx * 4;
					directoryOffset = rf.readInt();
				}

				rf.position = directoryOffset;
				var ttId: int = rf.readInt();

				if ( ttId != 0x00010000 && ttId != 0x4F54544F )
					throw new DocumentError( fileName + "is not a valid ttf or otf file" );
				var num_tables: int = rf.readUnsignedShort();
				rf.position += 6;

				for ( var k: int = 0; k < num_tables; ++k )
				{
					var tag: String = readStandardString( 4 );
					rf.position += 4;
					var table_location: Vector.<int> = new Vector.<int>( 2, true );
					table_location[0] = rf.readInt();
					table_location[1] = rf.readInt();
					tables.put( tag, table_location );
				}

				checkCff();
				fontName = getBaseFont();
				fullName = getNames( 4 ); //full name
				familyName = getNames( 1 ); //family name
				allNameEntries = getAllNames();

				if ( !justNames )
				{
					fillTables();
					readGlyphWidths();
					readCMaps();
					readKerning();
					readBbox();
					GlyphWidths = null;
				}
			} finally
			{
				if ( rf != null )
				{
					if ( !embedded )
						rf = null;
				}
			}
		}

		protected function readCffFont(): Bytes
		{
			var rf2: ByteArray = new ByteArray();
			rf2.writeBytes( rf, 0, rf.length );

			var b: Bytes = new Bytes( cffLength );

			try
			{
				rf2.position = cffOffset;
				rf2.readBytes( b.buffer, 0, b.length );
			} finally
			{
			}
			return b;
		}

		/**
		 * Reads the glyphs widths. The widths are extracted from the table 'hmtx'.
		 * The glyphs are normalized to 1000 units.
		 * @throws DocumentError
		 * @throws EOFError
		 */
		protected function readGlyphWidths(): void
		{
			var table_location: Vector.<int>;
			table_location = tables.getValue( "hmtx" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table hmtx does not exist in " + ( fileName + style ) );
			rf.position = table_location[0];
			GlyphWidths = new Vector.<int>( hhea.numberOfHMetrics, true );

			for ( var k: int = 0; k < hhea.numberOfHMetrics; ++k )
			{
				GlyphWidths[k] = ( rf.readUnsignedShort() * 1000 ) / head.unitsPerEm;
				rf.readUnsignedShort();
			}
		}

		/**
		 * Reads a String from the font file as bytes using the Cp1252 encoding
		 * @throws IOError
		 */
		protected function readStandardString( length: int ): String
		{
			var buf: String = rf.readUTFBytes( length );
			return buf;
		}

		/**
		 * @throws EOFError
		 */
		protected function readUnicodeString( length: int ): String
		{
			var buf: String = "";
			length /= 2;

			for ( var k: int = 0; k < length; ++k )
			{
				buf += String.fromCharCode( ByteArrayUtils.readChar( rf ) );
			}
			return buf;
		}

		override internal function writeFont( writer: PdfWriter, ref: PdfIndirectReference, params: Vector.<Object> ): void
		{
			var firstChar: int = int( params[0] );
			var lastChar: int = int( params[1] );
			var shortTag: Vector.<int> = Vector.<int>( params[2] );
			var subsetp: Boolean = ( params[3] as Boolean ) && _subset;
			var k: int;

			if ( !subsetp )
			{
				firstChar = 0;
				lastChar = shortTag.length - 1;

				for ( k = 0; k < shortTag.length; ++k )
					shortTag[k] = 1;
			}
			var ind_font: PdfIndirectReference = null;
			var pobj: PdfObject = null;
			var obj: PdfIndirectObject = null;
			var subsetPrefix: String = "";

			if ( embedded )
			{
				if ( cff )
				{
					pobj = StreamFont.create2( readCffFont(), "Type1C", compressionLevel );
					obj = writer.addToBody( pobj );
					ind_font = obj.indirectReference;
				} else
				{
					if ( subsetp )
						subsetPrefix = createSubsetPrefix();
					var glyphs: HashMap = new HashMap( 255 );

					for ( k = firstChar; k <= lastChar; ++k )
					{
						if ( shortTag[k] != 0 )
						{
							var metrics: Vector.<int> = null;

							if ( specialMap != null )
							{
								var cd: Vector.<int> = GlyphList.name2unicode( differences[k] );

								if ( cd != null )
									metrics = getMetricsTT( cd[0] );
							} else
							{
								if ( _fontSpecific )
									metrics = getMetricsTT( k );
								else
									metrics = getMetricsTT( unicodeDifferences[k] );
							}

							if ( metrics != null )
								glyphs.put( metrics[0], null );
						}
					}

					addRangeUni( glyphs, false, subsetp );
					var b: Bytes = null;

					if ( subsetp || directoryOffset != 0 || subsetRanges != null )
					{
						var sb: TrueTypeFontSubSet = new TrueTypeFontSubSet( fileName, rf, glyphs, directoryOffset, true, !subsetp );
						b = sb.process();
					} else
					{
						throw new NonImplementatioError();
						b = getFullFont();
					}

					var lengths: Vector.<int> = Vector.<int>( [ b.length ] );
					pobj = StreamFont.create( b, lengths, compressionLevel );
					obj = writer.addToBody( pobj );
					ind_font = obj.indirectReference;
				}
			}

			pobj = getFontDescriptorRef( ind_font, subsetPrefix, null );

			if ( pobj != null )
			{
				obj = writer.addToBody( pobj );
				ind_font = obj.indirectReference;
			}

			pobj = getFontBaseType( ind_font, subsetPrefix, firstChar, lastChar, shortTag );
			writer.addToBody1( pobj, ref );
		}


		private function checkCff(): void
		{
			var table_location: Vector.<int>;
			table_location = tables.getValue( "CFF " ) as Vector.<int>;

			if ( table_location != null )
			{
				cff = true;
				cffOffset = table_location[0];
				cffLength = table_location[1];
			}
		}

		/**
		 * Reads the tables 'head', 'hhea', 'OS/2' and 'post' filling several variables.
		 * @throws DocumentError
		 * @throws EOFError
		 */
		private function fillTables(): void
		{
			var table_location: Vector.<int>;
			table_location = tables.getValue( "head" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table head does not exist in " + ( fileName + style ) );
			rf.position = table_location[0] + 16;
			head.flags = rf.readUnsignedShort();
			head.unitsPerEm = rf.readUnsignedShort();
			rf.position += 16;
			head.xMin = rf.readShort();
			head.yMin = rf.readShort();
			head.xMax = rf.readShort();
			head.yMax = rf.readShort();
			head.macStyle = rf.readUnsignedShort();

			table_location = tables.getValue( "hhea" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table hhea does not exist in " + ( fileName + style ) );
			rf.position = table_location[0] + 4;
			hhea.Ascender = rf.readShort();
			hhea.Descender = rf.readShort();
			hhea.LineGap = rf.readShort();
			hhea.advanceWidthMax = rf.readUnsignedShort();
			hhea.minLeftSideBearing = rf.readShort();
			hhea.minRightSideBearing = rf.readShort();
			hhea.xMaxExtent = rf.readShort();
			hhea.caretSlopeRise = rf.readShort();
			hhea.caretSlopeRun = rf.readShort();
			rf.position += 12;
			hhea.numberOfHMetrics = rf.readUnsignedShort();

			table_location = tables.getValue( "OS/2" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table OS/2 does not exist in " + ( fileName + style ) );
			rf.position = table_location[0];
			var version: int = rf.readUnsignedShort();
			os_2.xAvgCharWidth = rf.readShort();
			os_2.usWeightClass = rf.readUnsignedShort();
			os_2.usWidthClass = rf.readUnsignedShort();
			os_2.fsType = rf.readShort();
			os_2.ySubscriptXSize = rf.readShort();
			os_2.ySubscriptYSize = rf.readShort();
			os_2.ySubscriptXOffset = rf.readShort();
			os_2.ySubscriptYOffset = rf.readShort();
			os_2.ySuperscriptXSize = rf.readShort();
			os_2.ySuperscriptYSize = rf.readShort();
			os_2.ySuperscriptXOffset = rf.readShort();
			os_2.ySuperscriptYOffset = rf.readShort();
			os_2.yStrikeoutSize = rf.readShort();
			os_2.yStrikeoutPosition = rf.readShort();
			os_2.sFamilyClass = rf.readShort();
			rf.readBytes( os_2.panose.buffer, 0, os_2.panose.length );
			rf.position += 16;
			rf.readBytes( os_2.achVendID.buffer, 0, os_2.achVendID.length );
			os_2.fsSelection = rf.readUnsignedShort();
			os_2.usFirstCharIndex = rf.readUnsignedShort();
			os_2.usLastCharIndex = rf.readUnsignedShort();
			os_2.sTypoAscender = rf.readShort();
			os_2.sTypoDescender = rf.readShort();

			if ( os_2.sTypoDescender > 0 )
				os_2.sTypoDescender = -os_2.sTypoDescender;
			os_2.sTypoLineGap = rf.readShort();
			os_2.usWinAscent = rf.readUnsignedShort();
			os_2.usWinDescent = rf.readUnsignedShort();
			os_2.ulCodePageRange1 = 0;
			os_2.ulCodePageRange2 = 0;

			if ( version > 0 )
			{
				os_2.ulCodePageRange1 = rf.readInt();
				os_2.ulCodePageRange2 = rf.readInt();
			}

			if ( version > 1 )
			{
				rf.position += 2;
				os_2.sCapHeight = rf.readShort();
			} else
				os_2.sCapHeight = int( 0.7 * head.unitsPerEm );

			table_location = tables.getValue( "post" ) as Vector.<int>;

			if ( table_location == null )
			{
				italicAngle = -Math.atan2( hhea.caretSlopeRun, hhea.caretSlopeRise ) * 180 / Math.PI;
				return;
			}
			rf.position = table_location[0] + 4;
			var mantissa: int = rf.readShort();
			var fraction: int = rf.readUnsignedShort();
			italicAngle = mantissa + fraction / 16384.0;
			underlinePosition = rf.readShort();
			underlineThickness = rf.readShort();
			isFixedPitch = rf.readInt() != 0;
		}

		/**
		 * Extracts all the names of the names table
		 * @throws DocumentError
		 * @throws IOError
		 * @throws EOFError
		 */
		private function getAllNames(): Vector.<Vector.<String>>
		{
			var k: int;
			var table_location: Vector.<int>;
			table_location = tables.getValue( "name" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table name does not exists in " + ( fileName + style ) );
			rf.position = table_location[0] + 2;
			var numRecords: int = rf.readUnsignedShort();
			var startOfStorage: int = rf.readUnsignedShort();
			var names: Vector.<Vector.<String>> = new Vector.<Vector.<String>>();

			for ( k = 0; k < numRecords; ++k )
			{
				var platformID: int = rf.readUnsignedShort();
				var platformEncodingID: int = rf.readUnsignedShort();
				var languageID: int = rf.readUnsignedShort();
				var nameID: int = rf.readUnsignedShort();
				var length: int = rf.readUnsignedShort();
				var offset: int = rf.readUnsignedShort();
				var pos: int = rf.position;
				rf.position = ( table_location[0] + startOfStorage + offset );
				var name: String;

				if ( platformID == 0 || platformID == 3 || ( platformID == 2 && platformEncodingID == 1 ) )
					name = readUnicodeString( length );
				else
					name = readStandardString( length );

				names.push( Vector.<String>( [ nameID.toString(), platformID.toString(), platformEncodingID.toString(), languageID.toString(), name ] ) );
				rf.position = pos;
			}
			var thisName: Vector.<Vector.<String>> = new Vector.<Vector.<String>>( names.length, true );

			for ( k = 0; k < names.length; ++k )
				thisName[k] = names[k];
			return thisName;
		}

		/**
		 * Gets the Postscript font name.
		 * @throws DocumentError
		 * @throws IOError
		 */
		private function getBaseFont(): String
		{
			var table_location: Vector.<int>;
			table_location = tables.getValue( "name" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table does not exist in " + ( fileName + style ) );
			rf.position = table_location[0] + 2;
			var numRecords: int = rf.readUnsignedShort();
			var startOfStorage: int = rf.readUnsignedShort();

			for ( var k: int = 0; k < numRecords; ++k )
			{
				var platformID: int = rf.readUnsignedShort();
				var platformEncodingID: int = rf.readUnsignedShort();
				var languageID: int = rf.readUnsignedShort();
				var nameID: int = rf.readUnsignedShort();
				var length: int = rf.readUnsignedShort();
				var offset: int = rf.readUnsignedShort();

				if ( nameID == 6 )
				{
					rf.position = table_location[0] + startOfStorage + offset;

					if ( platformID == 0 || platformID == 3 )
						return readUnicodeString( length );
					else
						return readStandardString( length );
				}
			}

			return fileName.replace( / /g, '-' );
		}

		/**
		 * Extracts the names of the font in all the languages available.
		 * @param id the name id to retrieve
		 * @throws DocumentException on error
		 * @throws EOFError
		 * @throws IOError
		 */
		private function getNames( id: int ): Vector.<Vector.<String>>
		{
			var k: int;
			var table_location: Vector.<int>;
			table_location = tables.getValue( "name" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table name does not exists in " + fileName );
			rf.position = table_location[0] + 2;
			var numRecords: int = rf.readUnsignedShort();
			var startOfStorage: int = rf.readUnsignedShort();
			var names: Vector.<Vector.<String>> = new Vector.<Vector.<String>>();

			for ( k = 0; k < numRecords; ++k )
			{
				var platformID: int = rf.readUnsignedShort();
				var platformEncodingID: int = rf.readUnsignedShort();
				var languageID: int = rf.readUnsignedShort();
				var nameID: int = rf.readUnsignedShort();
				var length: int = rf.readUnsignedShort();
				var offset: int = rf.readUnsignedShort();

				if ( nameID == id )
				{
					var pos: int = rf.position;
					rf.position = ( table_location[0] + startOfStorage + offset );
					var name: String;

					if ( platformID == 0 || platformID == 3 || ( platformID == 2 && platformEncodingID == 1 ) )
						name = readUnicodeString( length );
					else
						name = readStandardString( length );
					names.push( Vector.<String>( [ platformID.toString(), platformEncodingID.toString(), languageID.toString(), name ] ) );
					rf.position = pos;
				}
			}
			var thisName: Vector.<Vector.<String>> = new Vector.<Vector.<String>>( names.length, true );

			for ( k = 0; k < names.length; ++k )
				thisName[k] = names[k];
			return thisName;
		}

		/**
		 *
		 * @throws DocumentError
		 * @throws EOFError
		 */
		private function readBbox(): void
		{
			var tableLocation: Vector.<int>;
			tableLocation = tables.getValue( "head" ) as Vector.<int>;

			if ( tableLocation == null )
				throw new DocumentError( "table head does not exist in " + ( fileName + style ) );
			rf.position = ( tableLocation[0] + TrueTypeFontSubSet.HEAD_LOCA_FORMAT_OFFSET );
			var locaShortTable: Boolean = ( rf.readUnsignedShort() == 0 );

			tableLocation = tables.getValue( "loca" ) as Vector.<int>;

			if ( tableLocation == null )
				return;

			rf.position = tableLocation[0];
			var k: int;
			var entries: int;
			var locaTable: Vector.<int>;

			if ( locaShortTable )
			{
				entries = tableLocation[1] / 2;
				locaTable = new Vector.<int>( entries, true );

				for ( k = 0; k < entries; ++k )
					locaTable[k] = rf.readUnsignedShort() * 2;
			} else
			{
				entries = tableLocation[1] / 4;
				locaTable = new Vector.<int>( entries, true );

				for ( k = 0; k < entries; ++k )
					locaTable[k] = rf.readInt();
			}
			tableLocation = tables.getValue( "glyf" ) as Vector.<int>;

			if ( tableLocation == null )
				throw new DocumentError( "table glyf does not exist in " + ( fileName + style ) );
			var tableGlyphOffset: int = tableLocation[0];
			bboxes = new Vector.<Vector.<int>>( locaTable.length - 1, true );

			for ( var glyph: int = 0; glyph < locaTable.length - 1; ++glyph )
			{
				var start: int = locaTable[glyph];

				if ( start != locaTable[glyph + 1] )
				{
					rf.position = tableGlyphOffset + start + 2;
					bboxes[glyph] = Vector.<int>( [ ( rf.readShort() * 1000 ) / head.unitsPerEm, ( rf.readShort() * 1000 ) / head.unitsPerEm, ( rf.readShort() *
							1000 ) / head.unitsPerEm, ( rf.readShort() * 1000 ) / head.unitsPerEm ] );
				}
			}
		}

		/**
		 * Reads the several maps from the table 'cmap'. The maps of interest are 1.0 for symbolic
		 * fonts and 3.1 for all others. A symbolic font is defined as having the map 3.0.
		 * @throws DocumentError
		 * @throws EOFError
		 */
		private function readCMaps(): void
		{
			var table_location: Vector.<int>;
			table_location = tables.getValue( "cmap" ) as Vector.<int>;

			if ( table_location == null )
				throw new DocumentError( "table cmap does not exist in " + ( fileName + style ) );
			rf.position = table_location[0];
			rf.position += 2;
			var num_tables: int = rf.readUnsignedShort();
			_fontSpecific = false;
			var map10: int = 0;
			var map31: int = 0;
			var map30: int = 0;
			var mapExt: int = 0;
			var k: int;

			for ( k = 0; k < num_tables; ++k )
			{
				var platId: int = rf.readUnsignedShort();
				var platSpecId: int = rf.readUnsignedShort();
				var offset: int = rf.readInt();

				if ( platId == 3 && platSpecId == 0 )
				{
					_fontSpecific = true;
					map30 = offset;
				} else if ( platId == 3 && platSpecId == 1 )
				{
					map31 = offset;
				} else if ( platId == 3 && platSpecId == 10 )
				{
					mapExt = offset;
				}

				if ( platId == 1 && platSpecId == 0 )
					map10 = offset;
			}
			var format: int;

			if ( map10 > 0 )
			{
				rf.position = ( table_location[0] + map10 );
				format = rf.readUnsignedShort();

				switch ( format )
				{
					case 0:
						cmap10 = readFormat0();
						break;
					case 4:
						cmap10 = readFormat4();
						break;
					case 6:
						cmap10 = readFormat6();
						break;
				}
			}


			if ( map31 > 0 )
			{
				rf.position = ( table_location[0] + map31 );
				format = rf.readUnsignedShort();

				if ( format == 4 )
					cmap31 = readFormat4();
			}

			if ( map30 > 0 )
			{
				rf.position = ( table_location[0] + map30 );
				format = rf.readUnsignedShort();

				if ( format == 4 )
					cmap10 = readFormat4();
			}

			if ( mapExt > 0 )
			{
				rf.position = ( table_location[0] + mapExt );
				format = rf.readUnsignedShort();

				switch ( format )
				{
					case 0:
						cmapExt = readFormat0();
						break;
					case 4:
						cmapExt = readFormat4();
						break;
					case 6:
						cmapExt = readFormat6();
						break;
					case 12:
						cmapExt = readFormat12();
						break;
				}
			}
		}

		/**
		 * The information in the maps of the table 'cmap' is coded in several formats.
		 * Format 0 is the Apple standard character to glyph index mapping table.
		 * @throws EOFError
		 */
		private function readFormat0(): HashMap
		{
			var h: HashMap = new HashMap();
			rf.position += 4;

			for ( var k: int = 0; k < 256; ++k )
			{
				var r: Vector.<int> = new Vector.<int>( 2, true );
				r[0] = rf.readUnsignedByte();
				r[1] = getGlyphWidth( r[0] );
				h.put( k, r );
			}
			return h;
		}

		/**
		 *
		 * @throws EOFError
		 */
		private function readFormat12(): HashMap
		{
			var h: HashMap = new HashMap();
			rf.position += 2;
			var table_lenght: int = rf.readInt();
			rf.position += 4;
			var nGroups: int = rf.readInt();
			var startCharCode: int;
			var endCharCode: int;
			var startGlyphID: int;
			var i: int;
			var r: Vector.<int>;

			for ( var k: int = 0; k < nGroups; k++ )
			{
				startCharCode = rf.readInt();
				endCharCode = rf.readInt();
				startGlyphID = rf.readInt();

				for ( i = startCharCode; i <= endCharCode; i++ )
				{
					r = new Vector.<int>( 2, true );
					r[0] = startGlyphID;
					r[1] = getGlyphWidth( r[0] );
					h.put( i, r );
					startGlyphID++;
				}
			}
			return h;
		}

		/**
		 * The information in the maps of the table 'cmap' is coded in several formats.
		 * Format 4 is the Microsoft standard character to glyph index mapping table.
		 * @throws EOFError
		 */
		private function readFormat4(): HashMap
		{
			var h: HashMap = new HashMap();
			var table_lenght: int = rf.readUnsignedShort();
			rf.position += 2;
			var segCount: int = rf.readUnsignedShort() / 2;
			rf.position += 6;
			var endCount: Vector.<int> = new Vector.<int>( segCount, true );
			var k: int;

			for ( k = 0; k < segCount; ++k )
				endCount[k] = rf.readUnsignedShort();

			rf.position += 2;
			var startCount: Vector.<int> = new Vector.<int>( segCount, true );

			for ( k = 0; k < segCount; ++k )
				startCount[k] = rf.readUnsignedShort();

			var idDelta: Vector.<int> = new Vector.<int>( segCount, true );

			for ( k = 0; k < segCount; ++k )
				idDelta[k] = rf.readUnsignedShort();

			var idRO: Vector.<int> = new Vector.<int>( segCount, true );

			for ( k = 0; k < segCount; ++k )
				idRO[k] = rf.readUnsignedShort();

			var glyphId: Vector.<int> = new Vector.<int>( table_lenght / 2 - 8 - segCount * 4, true );

			for ( k = 0; k < glyphId.length; ++k )
				glyphId[k] = rf.readUnsignedShort();

			for ( k = 0; k < segCount; ++k )
			{
				var glyph: int;
				var r: Vector.<int>;
				var idx: int;

				for ( var j: int = startCount[k]; j <= endCount[k] && j != 0xFFFF; ++j )
				{
					if ( idRO[k] == 0 )
					{
						glyph = ( j + idDelta[k] ) & 0xFFFF;
					} else
					{
						idx = k + idRO[k] / 2 - segCount + j - startCount[k];

						if ( idx >= glyphId.length )
							continue;
						glyph = ( glyphId[idx] + idDelta[k] ) & 0xFFFF;
					}
					r = new Vector.<int>( 2, true );
					r[0] = glyph;
					r[1] = getGlyphWidth( r[0] );
					h.put( ( _fontSpecific ? ( ( j & 0xff00 ) == 0xf000 ? j & 0xff : j ) : j ), r );
				}
			}
			return h;
		}

		/**
		 * The information in the maps of the table 'cmap' is coded in several formats.
		 * Format 6 is a trimmed table mapping. It is similar to format 0 but can have
		 * less than 256 entries.
		 * @throws EOFError
		 */
		private function readFormat6(): HashMap
		{
			var h: HashMap = new HashMap();
			rf.position += 4;
			var start_code: int = rf.readUnsignedShort();
			var code_count: int = rf.readUnsignedShort();
			var r: Vector.<int>;

			for ( var k: int = 0; k < code_count; ++k )
			{
				r = new Vector.<int>( 2, true );
				r[0] = rf.readUnsignedShort();
				r[1] = getGlyphWidth( r[0] );
				h.put( ( k + start_code ), r );
			}
			return h;
		}

		/**
		 * Reads the kerning information from the 'kern' table.
		 * @throws EOFError
		 */
		private function readKerning(): void
		{
			var table_location: Vector.<int>;
			table_location = tables.getValue( "kern" ) as Vector.<int>;

			if ( table_location == null )
				return;

			rf.position = ( table_location[0] + 2 );
			var nTables: int = rf.readUnsignedShort();
			var checkpoint: int = table_location[0] + 4;
			var length: int = 0;
			var j: int;

			for ( var k: int = 0; k < nTables; ++k )
			{
				checkpoint += length;
				rf.position = ( checkpoint );
				rf.position += 2;
				length = rf.readUnsignedShort();
				var coverage: int = rf.readUnsignedShort();

				if ( ( coverage & 0xfff7 ) == 0x0001 )
				{
					var nPairs: int = rf.readUnsignedShort();
					rf.position += 6;

					for ( j = 0; j < nPairs; ++j )
					{
						var pair: int = rf.readInt();
						var value: int = rf.readShort() * 1000 / head.unitsPerEm;
						kerning[pair] = value;
						kerning_size++;
					}
				}
			}
		}

		protected static function compactRanges( ranges: Vector.<Vector.<int>> ): Vector.<int>
		{
			var simp: Vector.<Vector.<int>> = new Vector.<Vector.<int>>();

			var k: int;
			var k1: int;
			var k2: int;
			var r: Vector.<int>;
			var j: int;
			var r1: Vector.<int>;
			var r2: Vector.<int>;
			var s: Vector.<int>;

			for ( k = 0; k < ranges.length; ++k )
			{
				r = ranges[k];

				for ( j = 0; j < r.length; j += 2 )
				{
					simp.push( Vector.<int>( [ Math.max( 0, Math.min( r[j], r[j + 1] ) ), Math.min( 0xffff, Math.max( r[j], r[j + 1] ) ) ] ) );
				}
			}

			for ( k1 = 0; k1 < simp.length - 1; ++k1 )
			{
				for ( k2 = k1 + 1; k2 < simp.length; ++k2 )
				{
					r1 = simp[k1];
					r2 = simp[k2];

					if ( ( r1[0] >= r2[0] && r1[0] <= r2[1] ) || ( r1[1] >= r2[0] && r1[0] <= r2[1] ) )
					{
						r1[0] = Math.min( r1[0], r2[0] );
						r1[1] = Math.max( r1[1], r2[1] );
						simp.splice( k2, 1 );
						--k2;
					}
				}
			}
			s = new Vector.<int>( simp.length * 2, true );

			for ( k = 0; k < simp.length; ++k )
			{
				r = simp[k];
				s[k * 2] = r[0];
				s[k * 2 + 1] = r[1];
			}
			return s;
		}

		/**
		 * Gets the name from a composed TTC file name.
		 */
		protected static function getTTCName( name: String ): String
		{
			var idx: int = name.toLowerCase().indexOf( ".ttc," );

			if ( idx < 0 )
				return name;
			else
				return name.substring( 0, idx + 4 );
		}
	}
}

/**
 * Support classes
 */

import org.purepdf.utils.Bytes;

class FontHeader
{
	public var flags: int;
	public var macStyle: int;
	public var unitsPerEm: int;
	public var xMax: int; // short
	public var xMin: int; // short
	public var yMax: int; // short
	public var yMin: int; // short
}

class HorizontalHeader
{
	public var Ascender: int; // short
	public var Descender: int; // short
	public var LineGap: int; // short
	public var advanceWidthMax: int; // int
	public var caretSlopeRise: int; // short
	public var caretSlopeRun: int; // short
	public var minLeftSideBearing: int; // short
	public var minRightSideBearing: int; // short
	public var numberOfHMetrics: int; // int
	public var xMaxExtent: int; // short
}

class WindowsMetrics
{
	public var achVendID: Bytes = new Bytes( 4 );
	public var fsSelection: int; // int
	public var fsType: int; // short
	public var panose: Bytes = new Bytes( 10 );
	public var sCapHeight: int; // int
	public var sFamilyClass: int; // short
	public var sTypoAscender: int; // short
	public var sTypoDescender: int; // short
	public var sTypoLineGap: int; // short
	public var ulCodePageRange1: int; // int
	public var ulCodePageRange2: int; // int
	public var usFirstCharIndex: int; // int
	public var usLastCharIndex: int; // int
	public var usWeightClass: int; // int
	public var usWidthClass: int; // int
	public var usWinAscent: int; // int
	public var usWinDescent: int; // int
	public var xAvgCharWidth: int; // short
	public var yStrikeoutPosition: int; // short
	public var yStrikeoutSize: int; // short
	public var ySubscriptXOffset: int; // short
	public var ySubscriptXSize: int; // short
	public var ySubscriptYOffset: int; // short
	public var ySubscriptYSize: int; // short
	public var ySuperscriptXOffset: int; // short
	public var ySuperscriptXSize: int; // short
	public var ySuperscriptYOffset: int; // short
	public var ySuperscriptYSize: int; // short
}