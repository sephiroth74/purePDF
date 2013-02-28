/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: BarcodePDF417.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/barcode/pdf417/BarcodePDF417.as $
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
package org.purepdf.pdf.barcode.pdf417
{
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.IllegalStateError;
	import org.purepdf.errors.IndexOutOfBoundsError;
	import org.purepdf.errors.NullPointerError;
	import org.purepdf.pdf.PdfEncodings;
	import org.purepdf.pdf.codec.CCITTG4Encoder;
	import org.purepdf.utils.Bytes;

	public class BarcodePDF417
	{
		public static const PDF417_AUTO_ERROR_LEVEL: int = 0;
		public static const PDF417_FIXED_COLUMNS: int = 2;
		public static const PDF417_FIXED_RECTANGLE: int = 1;
		public static const PDF417_FIXED_ROWS: int = 4;
		public static const PDF417_FORCE_BINARY: int = 32;
		public static const PDF417_INVERT_BITMAP: int = 128;
		public static const PDF417_USE_ASPECT_RATIO: int = 0;
		public static const PDF417_USE_ERROR_LEVEL: int = 16;
		public static const PDF417_USE_MACRO: int = 256;
		public static const PDF417_USE_RAW_CODEWORDS: int = 64;

		protected static const ABSOLUTE_MAX_TEXT_SIZE: int = 5420;
		protected static const AL: int = 28;
		protected static const ALPHA: int = 0x10000;
		protected static const AS: int = 27;
		protected static const BYTESHIFT: int = 913;
		protected static const BYTE_MODE: int = 901;
		protected static const BYTE_MODE_6: int = 924;
		protected static const ISBYTE: int = 0x100000;
		protected static const LL: int = 27;
		protected static const LOWER: int = 0x20000;
		protected static const MACRO_LAST_SEGMENT: int = 922;
		protected static const MACRO_SEGMENT_ID: int = 928;
		protected static const MAX_DATA_CODEWORDS: int = 926;
		protected static const MIXED: int = 0x40000;
		protected static const MIXED_SET: String = "0123456789&\r\t,:#-.$/+%*=^";
		protected static const ML: int = 28;
		protected static const MOD: int = 929;
		protected static const NUMERIC_MODE: int = 902;
		protected static const PAL: int = 29;
		protected static const PL: int = 25;
		protected static const PS: int = 29;
		protected static const PUNCTUATION: int = 0x80000;
		protected static const PUNCTUATION_SET: String = ";<>@[\\]_`~!\r\t,:\n-.$/\"|*()?{}'";
		protected static const SPACE: int = 26;
		protected static const START_CODE_SIZE: int = 17;
		protected static const START_PATTERN: int = 0x1fea8;
		protected static const STOP_PATTERN: int = 0x3fa29;
		protected static const STOP_SIZE: int = 18;
		protected static const TEXT_MODE: int = 900;

		protected var bitPtr: int;
		protected var cwPtr: int;
		protected var segmentList: SegmentList;
		private var _aspectRatio: Number;
		private var _options: int;
		private var _text: Bytes;
		private var _yHeight: Number;
		private var bitColumns: int;
		private var codeColumns: int;
		private var codeRows: int;
		private var codewords: Vector.<int> = new Vector.<int>( MAX_DATA_CODEWORDS + 2, true );
		private var errorLevel: int;
		private var lenCodewords: int;
		private var macroFileId: String;
		private var macroIndex: int;
		private var macroSegmentCount: int = 0;
		private var macroSegmentId: int = -1;
		private var outBits: Bytes;

		public function BarcodePDF417()
		{
			setDefaultParameters();
		}

		public function get aspectRatio(): Number
		{
			return _aspectRatio;
		}

		public function set aspectRatio( value: Number ): void
		{
			_aspectRatio = value;
		}

		public function getImage(): ImageElement
		{
			paintCode();
			var g4: Bytes = CCITTG4Encoder.compress( outBits, bitColumns, codeRows );
			return ImageElement.getCCITTInstance( bitColumns, codeRows, false, ImageElement.CCITTG4, ( _options & PDF417_INVERT_BITMAP ) == 0 ? 0 : ImageElement.CCITT_BLACKIS1, g4, null );
		}

		public function get options(): int
		{
			return _options;
		}

		public function set options( value: int ): void
		{
			_options = value;
		}

		public function paintCode(): void
		{
			var maxErr: int;
			var lenErr: int;
			var tot: int;
			var pad: int;

			if ( ( _options & PDF417_USE_RAW_CODEWORDS ) != 0 )
			{
				if ( lenCodewords > MAX_DATA_CODEWORDS || lenCodewords < 1 || lenCodewords != codewords[0] )
				{
					throw new ArgumentError( "invalid codeword size" );
				}
			} else
			{
				if ( _text == null )
					throw new NullPointerError( "text cannot be null" );
				if ( _text.length > ABSOLUTE_MAX_TEXT_SIZE )
				{
					throw new IndexOutOfBoundsError( "the text is too big" );
				}
				segmentList = new SegmentList();
				breakString();
				assemble();
				segmentList = null;
				codewords[0] = lenCodewords = cwPtr;
			}
			maxErr = maxPossibleErrorLevel( MAX_DATA_CODEWORDS + 2 - lenCodewords );
			if ( ( _options & PDF417_USE_ERROR_LEVEL ) == 0 )
			{
				if ( lenCodewords < 41 )
					errorLevel = 2;
				else if ( lenCodewords < 161 )
					errorLevel = 3;
				else if ( lenCodewords < 321 )
					errorLevel = 4;
				else
					errorLevel = 5;
			}
			if ( errorLevel < 0 )
				errorLevel = 0;
			else if ( errorLevel > maxErr )
				errorLevel = maxErr;
			if ( codeColumns < 1 )
				codeColumns = 1;
			else if ( codeColumns > 30 )
				codeColumns = 30;
			if ( codeRows < 3 )
				codeRows = 3;
			else if ( codeRows > 90 )
				codeRows = 90;
			lenErr = 2 << errorLevel;
			var fixedColumn: Boolean = ( _options & PDF417_FIXED_ROWS ) == 0;
			var skipRowColAdjust: Boolean = false;
			tot = lenCodewords + lenErr;
			if ( ( _options & PDF417_FIXED_RECTANGLE ) != 0 )
			{
				tot = codeColumns * codeRows;
				if ( tot > MAX_DATA_CODEWORDS + 2 )
				{
					tot = getMaxSquare();
				}
				if ( tot < lenCodewords + lenErr )
					tot = lenCodewords + lenErr;
				else
					skipRowColAdjust = true;
			} else if ( ( _options & ( PDF417_FIXED_COLUMNS | PDF417_FIXED_ROWS ) ) == 0 )
			{
				var c: Number, b: Number;
				fixedColumn = true;
				if ( aspectRatio < 0.001 )
					aspectRatio = 0.001;
				else if ( aspectRatio > 1000 )
					aspectRatio = 1000;
				b = 73 * aspectRatio - 4;
				c = ( -b + Math.sqrt( b * b + 4 * 17 * aspectRatio * ( lenCodewords + lenErr ) * _yHeight ) ) / ( 2 * 17 * aspectRatio );
				codeColumns = ( int )( c + 0.5 );
				if ( codeColumns < 1 )
					codeColumns = 1;
				else if ( codeColumns > 30 )
					codeColumns = 30;
			}
			if ( !skipRowColAdjust )
			{
				if ( fixedColumn )
				{
					codeRows = ( tot - 1 ) / codeColumns + 1;
					if ( codeRows < 3 )
						codeRows = 3;
					else if ( codeRows > 90 )
					{
						codeRows = 90;
						codeColumns = ( tot - 1 ) / 90 + 1;
					}
				} else
				{
					codeColumns = ( tot - 1 ) / codeRows + 1;
					if ( codeColumns > 30 )
					{
						codeColumns = 30;
						codeRows = ( tot - 1 ) / 30 + 1;
					}
				}
				tot = codeRows * codeColumns;
			}
			if ( tot > MAX_DATA_CODEWORDS + 2 )
			{
				tot = getMaxSquare();
			}
			errorLevel = maxPossibleErrorLevel( tot - lenCodewords );
			lenErr = 2 << errorLevel;
			pad = tot - lenErr - lenCodewords;
			if ( ( _options & PDF417_USE_MACRO ) != 0 )
			{

				var src: Vector.<int> = codewords.slice( macroIndex );
				var dest: Vector.<int> = codewords.slice( 0, macroIndex + pad - 1 );
				var rest: Vector.<int> = codewords.slice( macroIndex + pad );
				dest.length = pad;

				codewords = dest.concat( src ).concat( rest );

				cwPtr = lenCodewords + pad;
				while ( pad-- != 0 )
					codewords[macroIndex++] = TEXT_MODE;
			} else
			{
				cwPtr = lenCodewords;
				while ( pad-- != 0 )
					codewords[cwPtr++] = TEXT_MODE;
			}
			codewords[0] = lenCodewords = cwPtr;
			calculateErrorCorrection( lenCodewords );
			lenCodewords = tot;
			outPaintCode();
		}

		public function setDefaultParameters(): void
		{
			options = 0;
			outBits = null;
			_text = new Bytes();
			_yHeight = 3;
			aspectRatio = 0.5;
		}

		public function set text( value: String ): void
		{
			_text = PdfEncodings.convertToBytes( value, "cp437" );
		}

		public function get yHeight(): Number
		{
			return _yHeight;
		}

		protected function assemble(): void
		{
			var k: int;

			if ( segmentList.length == 0 )
				return;

			var v: Segment;
			cwPtr = 1;
			for ( k = 0; k < segmentList.length; ++k )
			{
				v = segmentList[k];
				switch ( v.type )
				{
					case 84:
						if ( k != 0 )
							codewords[cwPtr++] = TEXT_MODE;
						textCompaction( v.start, getSegmentLength( v ) );
						break;
					case 78:
						codewords[cwPtr++] = NUMERIC_MODE;
						numberCompaction2( v.start, getSegmentLength( v ) );
						break;
					case 66:
						codewords[cwPtr++] = ( getSegmentLength( v ) % 6 ) != 0 ? BYTE_MODE : BYTE_MODE_6;
						byteCompaction( v.start, getSegmentLength( v ) );
						break;
				}
			}

			if ( ( _options & PDF417_USE_MACRO ) != 0 )
			{
				macroCodes();
			}
		}

		protected function byteCompaction( start: int, length: int ): void
		{
			var k: int, j: int;
			var size: int = ( length / 6 ) * 5 + ( length % 6 );
			if ( size + cwPtr > MAX_DATA_CODEWORDS )
			{
				throw new IndexOutOfBoundsError( "text is too big" );
			}
			length += start;
			for ( k = start; k < length; k += 6 )
			{
				size = length - k < 44 ? length - k : 6;
				if ( size < 6 )
				{
					for ( j = 0; j < size; ++j )
						codewords[cwPtr++] = _text[k + j] & 0xff;
				} else
				{
					byteCompaction6( k );
				}
			}
		}

		protected function byteCompaction6( start: int ): void
		{
			var length: int = 6;
			var ret: int = cwPtr;
			var retLast: int = 4;
			var ni: int, k: int;
			cwPtr += retLast + 1;
			for ( k = 0; k <= retLast; ++k )
				codewords[ret + k] = 0;
			length += start;
			for ( ni = start; ni < length; ++ni )
			{
				for ( k = retLast; k >= 0; --k )
					codewords[ret + k] *= 256;
				codewords[ret + retLast] += _text[ni] & 0xff;
				for ( k = retLast; k > 0; --k )
				{
					codewords[ret + k - 1] += codewords[ret + k] / 900;
					codewords[ret + k] %= 900;
				}
			}
		}

		protected function calculateErrorCorrection( dest: int ): void
		{
			if ( errorLevel < 0 || errorLevel > 8 )
				errorLevel = 0;
			var A: Vector.<int> = BarcodePDF417Tags.ERROR_LEVEL[errorLevel];
			var Alength: int = 2 << errorLevel;
			var k: int;
			for ( k = 0; k < Alength; ++k )
				codewords[dest + k] = 0;
			var lastE: int = Alength - 1;
			var t1: int;
			var t2: int;
			var t3: int;
			var e: int;
			for ( k = 0; k < lenCodewords; ++k )
			{
				t1 = codewords[k] + codewords[dest];
				for ( e = 0; e <= lastE; ++e )
				{
					t2 = ( t1 * A[lastE - e] ) % MOD;
					t3 = MOD - t2;
					codewords[dest + e] = ( ( e == lastE ? 0 : codewords[dest + e + 1] ) + t3 ) % MOD;
				}
			}
			for ( k = 0; k < Alength; ++k )
				codewords[dest + k] = ( MOD - codewords[dest + k] ) % MOD;
		}

		protected function checkSegmentType( segment: Segment, type: int ): Boolean
		{
			if ( segment == null )
				return false;
			return segment.type == type;
		}

		protected function getMaxSquare(): int
		{
			if ( codeColumns > 21 )
			{
				codeColumns = 29;
				codeRows = 32;
			} else
			{
				codeColumns = 16;
				codeRows = 58;
			}
			return MAX_DATA_CODEWORDS + 2;
		}

		protected function getSegmentLength( segment: Segment ): int
		{
			if ( segment == null )
				return 0;
			return segment.end - segment.start;
		}

		protected function numberCompaction2( start: int, length: int ): void
		{
			numberCompaction( _text, start, length );
		}

		protected function outCodeword( codeword: int ): void
		{
			outCodeword17( codeword );
		}


		protected function outCodeword17( codeword: int ): void
		{
			var bytePtr: int = bitPtr / 8;
			var bit: int = bitPtr - bytePtr * 8;
			outBits[bytePtr++] |= codeword >> ( 9 + bit );
			outBits[bytePtr++] |= codeword >> ( 1 + bit );
			codeword <<= 8;
			outBits[bytePtr] |= codeword >> ( 1 + bit );
			bitPtr += 17;
		}

		protected function outCodeword18( codeword: int ): void
		{
			var bytePtr: int = bitPtr / 8;
			var bit: int = bitPtr - bytePtr * 8;
			outBits[bytePtr++] |= codeword >> ( 10 + bit );
			outBits[bytePtr++] |= codeword >> ( 2 + bit );
			codeword <<= 8;
			outBits[bytePtr] |= codeword >> ( 2 + bit );
			if ( bit == 7 )
				outBits[++bytePtr] |= 0x80;
			bitPtr += 18;
		}

		protected function outPaintCode(): void
		{
			var codePtr: int = 0;
			bitColumns = START_CODE_SIZE * ( codeColumns + 3 ) + STOP_SIZE;
			var lenBits: int = ( ( bitColumns - 1 ) / 8 + 1 ) * codeRows;
			outBits = new Bytes( lenBits );
			var row: int;
			var column: int;
			var k: int;
			var rowMod: int;
			var edge: int;
			var cluster: Vector.<int>;
			for ( row = 0; row < codeRows; ++row )
			{
				bitPtr = int( ( bitColumns - 1 ) / 8 + 1 ) * 8 * row;
				rowMod = row % 3;
				cluster = BarcodePDF417Tags.CLUSTERS[rowMod];
				outStartPattern();
				edge = 0;
				switch ( rowMod )
				{
					case 0:
						edge = 30 * int( row / 3 ) + int( ( codeRows - 1 ) / 3 );
						break;
					case 1:
						edge = 30 * int( row / 3 ) + errorLevel * 3 + ( ( codeRows - 1 ) % 3 );
						break;
					default:
						edge = 30 * int( row / 3 ) + codeColumns - 1;
						break;
				}
				outCodeword( cluster[edge] );

				for ( column = 0; column < codeColumns; ++column )
				{
					outCodeword( cluster[codewords[codePtr++]] );
				}

				switch ( rowMod )
				{
					case 0:
						edge = 30 * int( row / 3 ) + codeColumns - 1;
						break;
					case 1:
						edge = 30 * int( row / 3 ) + int( ( codeRows - 1 ) / 3 );
						break;
					default:
						edge = 30 * int( row / 3 ) + errorLevel * 3 + ( ( codeRows - 1 ) % 3 );
						break;
				}
				outCodeword( cluster[edge] );
				outStopPattern();
			}
			if ( ( _options & PDF417_INVERT_BITMAP ) != 0 )
			{
				for ( k = 0; k < outBits.length; ++k )
					outBits[k] ^= 0xff;
			}
		}

		protected function outStartPattern(): void
		{
			outCodeword17( START_PATTERN );
		}

		protected function outStopPattern(): void
		{
			outCodeword18( STOP_PATTERN );
		}

		protected function textCompaction( start: int, length: int ): void
		{
			textCompaction2( _text, start, length );
		}

		private function append( $in: int, len: int ): void
		{
			var sb: String = "";
			sb += $in.toString();

			for ( var i: int = sb.length; i < len; i++ )
				sb = "0" + sb;

			var bytes: Bytes = PdfEncodings.convertToBytes( sb, "cp437" );
			numberCompaction( bytes, 0, bytes.length );
		}

		private function append_string( s: String ): void
		{
			var bytes: Bytes = PdfEncodings.convertToBytes( s, "cp437" );
			textCompaction2( bytes, 0, bytes.length );
		}

		private function basicNumberCompaction( input: Bytes, start: int, length: int ): void
		{
			var ret: int = cwPtr;
			var retLast: int = length / 3;
			var ni: int, k: int;
			cwPtr += retLast + 1;
			for ( k = 0; k <= retLast; ++k )
				codewords[ret + k] = 0;
			codewords[ret + retLast] = 1;
			length += start;
			for ( ni = start; ni < length; ++ni )
			{
				for ( k = retLast; k >= 0; --k )
					codewords[ret + k] *= 10;
				codewords[ret + retLast] += input[ni] - 48;
				for ( k = retLast; k > 0; --k )
				{
					codewords[ret + k - 1] += codewords[ret + k] / 900;
					codewords[ret + k] %= 900;
				}
			}
		}

		private function breakString(): void
		{
			var textLength: int = _text.length;
			var lastP: int = 0;
			var startN: int = 0;
			var nd: int = 0;
			var c: uint = 0; // char
			var k: int;
			var j: int;
			var lastTxt: Boolean;
			var txt: Boolean;
			var v: Segment;
			var vp: Segment;
			var vn: Segment;
			var redo: Boolean;

			if ( ( _options & PDF417_FORCE_BINARY ) != 0 )
			{
				segmentList.add( 66, 0, textLength );
				return;
			}
			for ( k = 0; k < textLength; ++k )
			{
				c = ( _text[k] & 0xff );
				if ( c >= 48 && c <= 57 )
				{
					if ( nd == 0 )
						startN = k;
					++nd;
					continue;
				}
				if ( nd >= 13 )
				{
					if ( lastP != startN )
					{
						c = ( _text[lastP] & 0xff );
						lastTxt = ( c >= 32 && c < 127 ) || c == 13 || c == 10 || c == 9;
						for ( j = lastP; j < startN; ++j )
						{
							c = ( _text[j] & 0xff );
							txt = ( c >= 32 && c < 127 ) || c == 13 || c == 10 || c == 9;
							if ( txt != lastTxt )
							{
								segmentList.add( lastTxt ? 84 : 66, lastP, j );
								lastP = j;
								lastTxt = txt;
							}
						}
						segmentList.add( lastTxt ? 84 : 66, lastP, startN );
					}
					segmentList.add( 78, startN, k );
					lastP = k;
				}
				nd = 0;
			}
			if ( nd < 13 )
				startN = textLength;
			if ( lastP != startN )
			{
				c = ( _text[lastP] & 0xff );
				lastTxt = ( c >= 32 && c < 127 ) || c == 13 || c == 10 || c == 9;
				for ( j = lastP; j < startN; ++j )
				{
					c = ( _text[j] & 0xff );
					txt = ( c >= 32 && c < 127 ) || c == 13 || c == 10 || c == 9;
					if ( txt != lastTxt )
					{
						segmentList.add( lastTxt ? 84 : 66, lastP, j );
						lastP = j;
						lastTxt = txt;
					}
				}
				segmentList.add( lastTxt ? 84 : 66, lastP, startN );
			}
			if ( nd >= 13 )
				segmentList.add( 78, startN, textLength );
			//optimize
			//merge short binary
			for ( k = 0; k < segmentList.length; ++k )
			{
				v = segmentList[k];
				vp = segmentList[k - 1];
				vn = segmentList[k + 1];
				if ( checkSegmentType( v, 66 ) && getSegmentLength( v ) == 1 )
				{
					if ( checkSegmentType( vp, 84 ) && checkSegmentType( vn, 84 ) && getSegmentLength( vp ) + getSegmentLength( vn ) >= 3 )
					{
						vp.end = vn.end;
						segmentList.remove( k );
						segmentList.remove( k );
						k = -1;
						continue;
					}
				}
			}
			//merge text sections
			for ( k = 0; k < segmentList.length; ++k )
			{
				v = segmentList[k];
				vp = segmentList[k - 1];
				vn = segmentList[k + 1];
				if ( checkSegmentType( v, 84 ) && getSegmentLength( v ) >= 5 )
				{
					redo = false;
					if ( ( checkSegmentType( vp, 66 ) && getSegmentLength( vp ) == 1 ) || checkSegmentType( vp, 84 ) )
					{
						redo = true;
						v.start = vp.start;
						segmentList.remove( k - 1 );
						--k;
					}
					if ( ( checkSegmentType( vn, 66 ) && getSegmentLength( vn ) == 1 ) || checkSegmentType( vn, 84 ) )
					{
						redo = true;
						v.end = vn.end;
						segmentList.remove( k + 1 );
					}
					if ( redo )
					{
						k = -1;
						continue;
					}
				}
			}
			//merge binary sections
			for ( k = 0; k < segmentList.length; ++k )
			{
				v = segmentList[k];
				vp = segmentList[k - 1];
				vn = segmentList[k + 1];
				if ( checkSegmentType( v, 66 ) )
				{
					redo = false;
					if ( ( checkSegmentType( vp, 84 ) && getSegmentLength( vp ) < 5 ) || checkSegmentType( vp, 66 ) )
					{
						redo = true;
						v.start = vp.start;
						segmentList.remove( k - 1 );
						--k;
					}
					if ( ( checkSegmentType( vn, 84 ) && getSegmentLength( vn ) < 5 ) || checkSegmentType( vn, 66 ) )
					{
						redo = true;
						v.end = vn.end;
						segmentList.remove( k + 1 );
					}
					if ( redo )
					{
						k = -1;
						continue;
					}
				}
			}
			// check if all numbers
			if ( segmentList.length == 1 && ( v = segmentList[0] ).type == 84 && getSegmentLength( v ) >= 8 )
			{
				for ( k = v.start; k < v.end; ++k )
				{
					c = ( _text[k] & 0xff );
					if ( c < 48 || c > 57 )
						break;
				}
				if ( k == v.end )
					v.type = 78;
			}
		}

		private function macroCodes(): void
		{
			if ( macroSegmentId < 0 )
				throw new IllegalStateError( "macrosegmentid must be >= 0" );

			if ( macroSegmentId >= macroSegmentCount )
				throw new IllegalStateError( "macrosegmentid must be < macrosemgentcount" );

			if ( macroSegmentCount < 1 )
				throw new IllegalStateError( "macrosemgentcount must be > 0" );

			macroIndex = cwPtr;
			codewords[cwPtr++] = MACRO_SEGMENT_ID;
			append( macroSegmentId, 5 );

			if ( macroFileId != null )
				append_string( macroFileId );

			if ( macroSegmentId >= macroSegmentCount - 1 )
				codewords[cwPtr++] = MACRO_LAST_SEGMENT;
		}

		private function numberCompaction( input: Bytes, start: int, length: int ): void
		{
			var full: int = ( length / 44 ) * 15;
			var size: int = length % 44;
			var k: int;
			if ( size == 0 )
				size = full;
			else
				size = full + size / 3 + 1;
			if ( size + cwPtr > MAX_DATA_CODEWORDS )
			{
				throw new IndexOutOfBoundsError( "text is too big" );
			}
			length += start;
			for ( k = start; k < length; k += 44 )
			{
				size = length - k < 44 ? length - k : 44;
				basicNumberCompaction( input, k, size );
			}
		}

		private function textCompaction2( input: Bytes, start: int, len: int ): void
		{
			var dest: Vector.<int> = new Vector.<int>( ABSOLUTE_MAX_TEXT_SIZE * 2, true );
			var mode: int = ALPHA;
			var ptr: int = 0;
			var fullBytes: int = 0;
			var v: int = 0;
			var size: int;
			var length: int = len + start;

			var k: int = start;
			var can_continue: Boolean = true;

			while ( k < length )
			{
				can_continue = true;
				v = getTextTypeAndValue( input, length, k );
				if ( ( v & mode ) != 0 )
				{
					dest[ptr++] = v & 0xff;
					can_continue = false;
						//continue;
				}

				if ( can_continue )
				{
					if ( ( v & ISBYTE ) != 0 )
					{
						if ( ( ptr & 1 ) != 0 )
						{
							dest[ptr++] = PAL;
							mode = ( mode & PUNCTUATION ) != 0 ? ALPHA : mode;
						}
						dest[ptr++] = BYTESHIFT;
						dest[ptr++] = v & 0xff;
						fullBytes += 2;
						can_continue = false;
							//continue;
					}
				}

				if ( can_continue )
				{
					switch ( mode )
					{
						case ALPHA:
							if ( ( v & LOWER ) != 0 )
							{
								dest[ptr++] = LL;
								dest[ptr++] = v & 0xff;
								mode = LOWER;
							} else if ( ( v & MIXED ) != 0 )
							{
								dest[ptr++] = ML;
								dest[ptr++] = v & 0xff;
								mode = MIXED;
							} else if ( ( getTextTypeAndValue( input, length, k + 1 ) & getTextTypeAndValue( input, length, k + 2 ) & PUNCTUATION ) != 0 )
							{
								dest[ptr++] = ML;
								dest[ptr++] = PL;
								dest[ptr++] = v & 0xff;
								mode = PUNCTUATION;
							} else
							{
								dest[ptr++] = PS;
								dest[ptr++] = v & 0xff;
							}
							break;
						case LOWER:
							if ( ( v & ALPHA ) != 0 )
							{
								if ( ( getTextTypeAndValue( input, length, k + 1 ) & getTextTypeAndValue( input, length, k + 2 ) & ALPHA ) != 0 )
								{
									dest[ptr++] = ML;
									dest[ptr++] = AL;
									mode = ALPHA;
								} else
								{
									dest[ptr++] = AS;
								}
								dest[ptr++] = v & 0xff;
							} else if ( ( v & MIXED ) != 0 )
							{
								dest[ptr++] = ML;
								dest[ptr++] = v & 0xff;
								mode = MIXED;
							} else if ( ( getTextTypeAndValue( input, length, k + 1 ) & getTextTypeAndValue( input, length, k + 2 ) & PUNCTUATION ) != 0 )
							{
								dest[ptr++] = ML;
								dest[ptr++] = PL;
								dest[ptr++] = v & 0xff;
								mode = PUNCTUATION;
							} else
							{
								dest[ptr++] = PS;
								dest[ptr++] = v & 0xff;
							}
							break;
						case MIXED:
							if ( ( v & LOWER ) != 0 )
							{
								dest[ptr++] = LL;
								dest[ptr++] = v & 0xff;
								mode = LOWER;
							} else if ( ( v & ALPHA ) != 0 )
							{
								dest[ptr++] = AL;
								dest[ptr++] = v & 0xff;
								mode = ALPHA;
							} else if ( ( getTextTypeAndValue( input, length, k + 1 ) & getTextTypeAndValue( input, length, k + 2 ) & PUNCTUATION ) != 0 )
							{
								dest[ptr++] = PL;
								dest[ptr++] = v & 0xff;
								mode = PUNCTUATION;
							} else
							{
								dest[ptr++] = PS;
								dest[ptr++] = v & 0xff;
							}
							break;
						case PUNCTUATION:
							dest[ptr++] = PAL;
							mode = ALPHA;
							--k;
							break;
					}
				}

				k++;
			}

			if ( ( ptr & 1 ) != 0 )
				dest[ptr++] = PS;
			size = ( ptr + fullBytes ) / 2;
			if ( size + cwPtr > MAX_DATA_CODEWORDS )
			{
				throw new IndexOutOfBoundsError( "text is too big" );
			}
			length = ptr;
			ptr = 0;
			while ( ptr < length )
			{
				v = dest[ptr++];
				if ( v >= 30 )
				{
					codewords[cwPtr++] = v;
					codewords[cwPtr++] = dest[ptr++];
				} else
					codewords[cwPtr++] = v * 30 + dest[ptr++];
			}
		}

		protected static function maxPossibleErrorLevel( remain: int ): int
		{
			var level: int = 8;
			var size: int = 512;
			while ( level > 0 )
			{
				if ( remain >= size )
					return level;
				--level;
				size >>= 1;
			}
			return 0;
		}

		private static function getTextTypeAndValue( input: Bytes, maxLength: int, idx: int ): int
		{
			if ( idx >= maxLength )
				return 0;

			var c: int = ( input[idx] & 0xff );

			if ( c >= 65 && c <= 90 )
				return ( ALPHA + c - 65 );
			if ( c >= 97 && c <= 122 )
				return ( LOWER + c - 97 );
			if ( c == 32 )
				return ( ALPHA + LOWER + MIXED + SPACE );

			var ms: int = MIXED_SET.indexOf( String.fromCharCode( c ) );
			var ps: int = PUNCTUATION_SET.indexOf( String.fromCharCode( c ) );

			if ( ms < 0 && ps < 0 )
				return ( ISBYTE + c );
			if ( ms == ps )
				return ( MIXED + PUNCTUATION + ms );
			if ( ms >= 0 )
				return ( MIXED + ms );
			return ( PUNCTUATION + ps );
		}
	}
}