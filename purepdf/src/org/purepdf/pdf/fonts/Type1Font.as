/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Type1Font.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/Type1Font.as $
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
	
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.io.LineReader;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfEncodings;
	import org.purepdf.pdf.PdfIndirectObject;
	import org.purepdf.pdf.PdfIndirectReference;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfObject;
	import org.purepdf.pdf.PdfRectangle;
	import org.purepdf.pdf.PdfStream;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.utils.StringTokenizer;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.pdf_core;

	public class Type1Font extends BaseFont
	{

		use namespace pdf_core;
		private static const PFB_TYPES: Vector.<int> = Vector.<int>( [ 1, 2, 1 ] );

		protected var pfb: Vector.<int>;
		private var Ascender: int = 800;
		private var CapHeight: int = 700;
		private var CharMetrics: HashMap = new HashMap();
		private var CharacterSet: String;
		private var Descender: int = -200;
		private var EncodingScheme: String = "FontSpecific";
		private var FamilyName: String;
		private var FontName: String;
		private var FullName: String;
		private var IsFixedPitch: Boolean = false;
		private var ItalicAngle: Number = 0.0;
		private var KernPairs: HashMap = new HashMap();
		private var StdHW: int;
		private var StdVW: int = 80;
		private var UnderlinePosition: int = -100;
		private var UnderlineThickness: int = 50;
		private var Weight: String = "";
		private var XHeight: int = 480;
		private var builtinFont: Boolean = false;
		private var fileName: String;
		private var llx: int = -50;
		private var lly: int = -200;
		private var urx: int = 1000;
		private var ury: int = 900;

		public function Type1Font( afmFile: String, enc: String, emb: Boolean, ttfAfm: Vector.<int>, pfb: Vector.<int>, forceRead: Boolean )
		{
			if ( emb && ttfAfm != null && pfb == null )
				throw new DocumentError( "two byte arrays are needed. if the type1 font is embedded" );

			if ( emb && ttfAfm != null )
				this.pfb = pfb;

			_encoding = enc;
			embedded = emb;
			fileName = afmFile;
			_fontType = FONT_TYPE_T1;

			if ( builtinFonts14.containsKey( afmFile ) || StringUtils.endsWith( afmFile, ".afm" ) )
			{
				embedded = false;
				builtinFont = true;

				var byte: ByteArray = FontsResourceFactory.getInstance().getFontFile( afmFile );

				if ( byte == null )
					throw new DocumentError( afmFile + " not found in resources" );

				process( new LineReader( byte ) );
			}
			else
			{
				throw new DocumentError( afmFile + " is not an amf or pfm recognized font file" );
			}

			EncodingScheme = StringUtils.trim( EncodingScheme );

			if ( EncodingScheme == "AdobeStandardEncoding" || EncodingScheme == "StandardEncoding" )
				_fontSpecific = false;

			if ( !StringUtils.startsWith( encoding, "#" ) )
				PdfEncodings.convertToBytes( " ", enc );
			createEncoding();
		}
		
		override public function getFamilyFontName() : Vector.<Vector.<String>>
		{
			var n: Vector.<String> = Vector.<String>(["", "", "", FamilyName]);
			var tmp: Vector.<Vector.<String>> = new Vector.<Vector.<String>>(1,true);
			tmp[0] = n;
			return tmp;
		}
		
		override public function getPostscriptFontName():String
		{
			return FontName;
		}


		override public function getFontDescriptor( key: int, fontSize: Number ): Number
		{
			switch ( key )
			{
				case AWT_ASCENT:
				case ASCENT:
					return Ascender * fontSize / 1000;
				case CAPHEIGHT:
					return CapHeight * fontSize / 1000;
				case AWT_DESCENT:
				case DESCENT:
					return Descender * fontSize / 1000;
				case ITALICANGLE:
					return ItalicAngle;
				case BBOXLLX:
					return llx * fontSize / 1000;
				case BBOXLLY:
					return lly * fontSize / 1000;
				case BBOXURX:
					return urx * fontSize / 1000;
				case BBOXURY:
					return ury * fontSize / 1000;
				case AWT_LEADING:
					return 0;
				case AWT_MAXADVANCE:
					return ( urx - llx ) * fontSize / 1000;
				case UNDERLINE_POSITION:
					return UnderlinePosition * fontSize / 1000;
				case UNDERLINE_THICKNESS:
					return UnderlineThickness * fontSize / 1000;
			}
			return 0;
		}

		override public function getKerning( char1: int, char2: int ): int
		{
			var first: String = GlyphList.unicode2name( char1 );

			if ( first == null )
				return 0;

			var second: String = GlyphList.unicode2name( char2 );

			if ( second == null )
				return 0;

			var obj: Vector.<Object> = Vector.<Object>( KernPairs.getValue( first ) );

			if ( obj == null )
				return 0;

			for ( var k: int = 0; k < obj.length; k += 2 )
			{
				if ( second == obj[ k ] )
					return obj[ k + 1 ] as int;
			}
			return 0;
		}

		override public function hasKernPairs(): Boolean
		{
			return !KernPairs.isEmpty();
		}

		override protected function getRawCharBBox( c: int, name: String ): Vector.<int>
		{
			var metrics: Vector.<Object>;

			if ( name == null )
			{
				metrics = CharMetrics.getValue( c ) as Vector.<Object>;
			}
			else
			{
				if ( name == notdef )
					return null;
				metrics = CharMetrics.getValue( name ) as Vector.<Object>;
			}

			if ( metrics != null )
				return metrics[ 3 ] as Vector.<int>;
			return null;
		}

		override protected function getRawWidth( c: int, name: String ): int
		{
			var metrics: Vector.<Object>;

			if ( name == null )
			{
				metrics = CharMetrics.getValue( c ) as Vector.<Object>;
			}
			else
			{
				if ( name == notdef )
					return 0;
				metrics = CharMetrics.getValue( name ) as Vector.<Object>;
			}

			if ( metrics != null )
				return metrics[ 1 ] as int;
			return 0;
		}

		override internal function getFullFontStream(): PdfStream
		{
			if ( builtinFont || !embedded )
				return null;

			throw new NonImplementatioError();
		}

		override internal function writeFont( writer: PdfWriter, ref: PdfIndirectReference, params: Vector.<Object> ): void
		{
			var firstChar: int = params[ 0 ] as int;
			var lastChar: int = params[ 1 ] as int;
			var shortTag: Vector.<int> = Vector.<int>( params[ 2 ] );
			var subsetp: Boolean = params[ 3 ] && _subset;
			var k: int;

			if ( !subsetp )
			{
				firstChar = 0;
				lastChar = shortTag.length - 1;

				for ( k = 0; k < shortTag.length; ++k )
					shortTag[ k ] = 1;
			}

			var ind_font: PdfIndirectReference = null;
			var pobj: PdfObject = null;
			var obj: PdfIndirectObject = null;

			pobj = getFullFontStream();

			if ( pobj != null )
			{
				obj = writer.addToBody( pobj );
				ind_font = obj.indirectReference;
			}

			pobj = getFontDescriptorRef( ind_font );

			if ( pobj != null )
			{
				obj = writer.addToBody( pobj );
				ind_font = obj.indirectReference;
			}

			pobj = getFontBaseType( ind_font, firstChar, lastChar, shortTag );
			writer.addToBody1( pobj, ref );
		}

		private function getFontBaseType( fontDescriptor: PdfIndirectReference, firstChar: int, lastChar: int, shortTag: Vector.<int> ): PdfDictionary
		{
			var k: int;
			var dic: PdfDictionary = new PdfDictionary( PdfName.FONT );
			dic.put( PdfName.SUBTYPE, PdfName.TYPE1 );
			dic.put( PdfName.BASEFONT, new PdfName( FontName ) );
			var stdEncoding: Boolean = encoding == "Cp1252" || encoding == "MacRoman";

			if ( !_fontSpecific || specialMap != null )
			{
				for ( k = firstChar; k <= lastChar; ++k )
				{
					if ( !differences[ k ] == notdef )
					{
						firstChar = k;
						break;
					}
				}

				if ( stdEncoding )
					dic.put( PdfName.ENCODING, encoding == "Cp1252" ? PdfName.WIN_ANSI_ENCODING : PdfName.MAC_ROMAN_ENCODING );
				else
				{
					var enc: PdfDictionary = new PdfDictionary( PdfName.ENCODING );
					var dif: PdfArray = new PdfArray();
					var gap: Boolean = true;

					for ( k = firstChar; k <= lastChar; ++k )
					{
						if ( shortTag[ k ] != 0 )
						{
							if ( gap )
							{
								dif.add( new PdfNumber( k ) );
								gap = false;
							}
							dif.add( new PdfName( differences[ k ] ) );
						}
						else
							gap = true;
					}
					enc.put( PdfName.DIFFERENCES, dif );
					dic.put( PdfName.ENCODING, enc );
				}
			}

			if ( specialMap != null || forceWidthsOutput || !( builtinFont && ( _fontSpecific || stdEncoding ) ) )
			{
				dic.put( PdfName.FIRSTCHAR, new PdfNumber( firstChar ) );
				dic.put( PdfName.LASTCHAR, new PdfNumber( lastChar ) );
				var wd: PdfArray = new PdfArray();

				for ( k = firstChar; k <= lastChar; ++k )
				{
					if ( shortTag[ k ] == 0 )
						wd.add( new PdfNumber( 0 ) );
					else
						wd.add( new PdfNumber( widths[ k ] ) );
				}
				dic.put( PdfName.WIDTHS, wd );
			}

			if ( !builtinFont && fontDescriptor != null )
				dic.put( PdfName.FONTDESCRIPTOR, fontDescriptor );
			return dic;
		}

		private function getFontDescriptorRef( fontStream: PdfIndirectReference ): PdfDictionary
		{
			if ( builtinFont )
				return null;

			var dic: PdfDictionary = new PdfDictionary( PdfName.FONTDESCRIPTOR );
			dic.put( PdfName.ASCENT, new PdfNumber( Ascender ) );
			dic.put( PdfName.CAPHEIGHT, new PdfNumber( CapHeight ) );
			dic.put( PdfName.DESCENT, new PdfNumber( Descender ) );
			dic.put( PdfName.FONTBBOX, new PdfRectangle( llx, lly, urx, ury ) );
			dic.put( PdfName.FONTNAME, new PdfName( FontName ) );
			dic.put( PdfName.ITALICANGLE, new PdfNumber( ItalicAngle ) );
			dic.put( PdfName.STEMV, new PdfNumber( StdVW ) );

			if ( fontStream != null )
				dic.put( PdfName.FONTFILE, fontStream );
			var flags: int = 0;

			if ( IsFixedPitch )
				flags |= 1;
			flags |= _fontSpecific ? 4 : 32;

			if ( ItalicAngle < 0 )
				flags |= 64;

			if ( FontName.indexOf( "Caps" ) >= 0 || StringUtils.endsWith( FontName, "SC" ) )
				flags |= 131072;

			if ( Weight == "Bold" )
				flags |= 262144;
			dic.put( PdfName.FLAGS, new PdfNumber( flags ) );

			return dic;
		}

		/**
		 * Reads the font metrics
		 *
		 * @param rf ByteArray containing the AFM file
		 * @throws DocumentError
		 * @throws IOError
		 */
		private function process( rf: LineReader ): void
		{
			var line: String;
			var isMetrics: Boolean = false;
			var tokens: StringTokenizer;
			var ident: String;

			while ( ( line = rf.readLine() ) != null )
			{
				tokens = new StringTokenizer( line );

				if ( !tokens.hasMoreTokens() )
					continue;

				ident = tokens.nextToken();

				switch ( ident )
				{
					case "FontName":
						FontName = tokens.nextToken();
						break;

					case "FullName":
						FullName = tokens.nextToken();
						break;

					case "FamilyName":
						FamilyName = tokens.nextToken();
						break;

					case "Weight":
						Weight = tokens.nextToken();
						break;

					case "ItalicAngle":
						ItalicAngle = parseFloat( tokens.nextToken() );
						break;

					case "IsFixedPitch":
						IsFixedPitch = tokens.nextToken() == "true";
						break;

					case "CharacterSet":
						CharacterSet = tokens.nextToken();
						break;

					case "FontBBox":
						llx = parseFloat( tokens.nextToken() );
						lly = parseFloat( tokens.nextToken() );
						urx = parseFloat( tokens.nextToken() );
						ury = parseFloat( tokens.nextToken() );
						break;

					case "UnderlinePosition":
						UnderlinePosition = parseFloat( tokens.nextToken() );
						break;

					case "UnderlineTickness":
						UnderlineThickness = parseFloat( tokens.nextToken() );
						break;

					case "EncodingScheme":
						EncodingScheme = tokens.nextToken();
						break;

					case "CapHeight":
						CapHeight = parseFloat( tokens.nextToken() );
						break;

					case "XHeight":
						XHeight = parseFloat( tokens.nextToken() );
						break;

					case "Ascender":
						Ascender = parseFloat( tokens.nextToken() );
						break;

					case "Descender":
						Descender = parseFloat( tokens.nextToken() );
						break;

					case "StdHW":
						StdHW = parseFloat( tokens.nextToken() );
						break;

					case "StdVW":
						StdVW = parseFloat( tokens.nextToken() );
						break;

					case "StartCharMetrics":
						isMetrics = true;
						break;
				}

				if ( isMetrics )
					break;
			}

			if ( !isMetrics )
				throw new DocumentError( "missing StartCharMetrics" );

			while ( ( line = rf.readLine() ) != null )
			{
				tokens = new StringTokenizer( line );

				if ( !tokens.hasMoreTokens() )
					continue;

				ident = tokens.nextToken();

				if ( ident == "EndCharMetrics" )
				{
					isMetrics = false;
					break;
				}

				var C: int = -1;
				var WX: int = 250;
				var N: String = "";
				var B: Vector.<int>;

				tokens = new StringTokenizer( line, /\s?;\s?/g );

				while ( tokens.hasMoreTokens() )
				{
					var tokc: StringTokenizer = new StringTokenizer( tokens.nextToken() );

					if ( !tokc.hasMoreTokens() )
						continue;

					ident = tokc.nextToken();

					if ( ident == "C" )
						C = parseInt( tokc.nextToken() );
					else if ( ident == "WX" )
						WX = parseFloat( tokc.nextToken() );
					else if ( ident == "N" )
						N = tokc.nextToken();
					else if ( ident == "B" )
						B = Vector.<int>( [ parseInt( tokc.nextToken() ), parseInt( tokc.nextToken() ), parseInt( tokc.nextToken() ), parseInt( tokc
							.nextToken() ) ] );
				}

				var metrics: Vector.<Object> = Vector.<Object>( [ C, WX, N, B ] );

				if ( C >= 0 )
					CharMetrics.put( C, metrics );
				CharMetrics.put( N, metrics );
			}

			if ( isMetrics )
				throw new DocumentError( "missing EndCharMetrics" );

			if ( !CharMetrics.containsKey( "nonbreakingspace" ) )
			{
				var space: Vector.<Object> = CharMetrics.getValue( "space" ) as Vector.<Object>;

				if ( space != null )
					CharMetrics.put( "nonbreakingspace", space );
			}

			while ( ( line = rf.readLine() ) != null )
			{
				tokens = new StringTokenizer( line );

				if ( !tokens.hasMoreTokens() )
					continue;

				ident = tokens.nextToken();

				if ( ident == "EndFontMetrics" )
					return;

				if ( ident == "StartKernPairs" )
				{
					isMetrics = true;
					break;
				}
			}

			if ( !isMetrics )
				throw new DocumentError( "Missing EndFontMetrics" );

			while ( ( line = rf.readLine() ) != null )
			{
				tokens = new StringTokenizer( line );

				if ( !tokens.hasMoreTokens() )
					continue;

				ident = tokens.nextToken();

				if ( ident == "KPX" )
				{
					var first: String = tokens.nextToken();
					var second: String = tokens.nextToken();
					var width: int = parseInt( tokens.nextToken() );
					var relateds: Vector.<Object> = KernPairs.getValue( first ) as Vector.<Object>;

					if ( relateds == null )
					{
						KernPairs.put( first, Vector.<Object>( [ second, width ] ) );
					}
					else
					{
						var n: int = relateds.length;
						var relateds2: Vector.<Object>;
						relateds2 = relateds.concat();
						relateds2[ n ] = second;
						relateds2[ n + 1 ] = width;
						KernPairs.put( first, relateds2 );
					}
				}
				else if ( ident == "EndKernPairs" )
				{
					isMetrics = false;
					break;
				}
			}

			if ( isMetrics )
				throw new DocumentError( "missing EndKernPairs" );
		}
	}
}