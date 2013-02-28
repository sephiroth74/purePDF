/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PRTokeniser.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PRTokeniser.as $
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
	import flash.utils.ByteArray;
	
	import org.purepdf.errors.InvalidPdfError;
	import org.purepdf.io.RandomAccessFileOrArray;
	import org.purepdf.utils.Bytes;

	public class PRTokeniser
	{
		public static const TK_COMMENT: int = 4;
		public static const TK_ENDOFFILE: int = 11;
		public static const TK_END_ARRAY: int = 6;
		public static const TK_END_DIC: int = 8;
		public static const TK_NAME: int = 3;
		public static const TK_NUMBER: int = 1;
		public static const TK_OTHER: int = 10;
		public static const TK_REF: int = 9;
		public static const TK_START_ARRAY: int = 5;
		public static const TK_START_DIC: int = 7;
		public static const TK_STRING: int = 2;

		public static const delims: Vector.<Boolean> = Vector.<Boolean>( [ true, true, false, false, false, false, false, false, false, false, true, true,
				false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, true, false, false, false, false, true, false, false, true, true, false, false, false, false, false, true, false, false, false,
				false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
				false, false, false, false, false ] );
		private static const EMPTY: String = "";

		protected var file: RandomAccessFileOrArray;
		protected var generation: int;
		protected var hexString: Boolean;
		protected var reference: int;
		protected var type: int;
		internal var stringValue: String;

		public function PRTokeniser( pdfIn: ByteArray )
		{
			file = new RandomAccessFileOrArray( pdfIn );
		}

		public function backOnePosition( ch: int ): void
		{
			if ( ch != -1 )
			{
				file.pushBack( ByteBuffer.intToByte( ch ) );
			}
		}

		public function checkPdfHeader(): int
		{
			file.startOffset = 0;
			var str: String = readString( 1024 );
			var idx: int = str.indexOf( "%PDF-" );
			if ( idx < 0 )
				throw new InvalidPdfError( "pdf header not found" );
			file.startOffset = idx;
			return parseInt( str.charAt( idx + 7 ) );
		}

		public function getFile(): RandomAccessFileOrArray
		{
			return file;
		}

		public function getFilePointer(): uint
		{
			return file.getFilePointer();
		}

		public function getGeneration(): int
		{
			return generation;
		}

		public function getReference(): int
		{
			return reference;
		}

		public function getSafeFile(): RandomAccessFileOrArray
		{
			return RandomAccessFileOrArray.fromFile( file );
		}

		/**
		 * @throws EOFError
		 */
		public function getStartxref(): int
		{
			var size: int = Math.min( 1024, file.length );
			var pos: int = file.length - size;
			file.seek( pos );
			var str: String = readString( 1024 );
			var idx: int = str.lastIndexOf( "startxref" );
			if ( idx < 0 )
				throw new InvalidPdfError( "pdf startxref not found" );
			return pos + idx;
		}

		public function getTokenType(): int
		{
			return type;
		}
		
		public function getStringValue(): String
		{
			return stringValue;
		}

		public function intValue(): int
		{
			return parseInt( stringValue );
		}

		public function isHexString(): Boolean
		{
			return this.hexString;
		}

		public function get length(): int
		{
			return file.length;
		}

		/**
		 * @throws EOFError
		 */
		public function nextToken(): Boolean
		{
			var ch: int = 0;
			do
			{
				ch = file.readInt();
			} while ( ch != -1 && isWhitespace( ch ) );
			if ( ch == -1 )
			{
				type = TK_ENDOFFILE;
				return false;
			}

			// Note:  We have to initialize stringValue here, after we've looked for the end of the stream,
			// to ensure that we don't lose the value of a token that might end exactly at the end
			// of the stream
			var outBuf: String = null;
			stringValue = EMPTY;

			switch ( ch )
			{
				case 91:
					type = TK_START_ARRAY;
					break;
				case 93:
					type = TK_END_ARRAY;
					break;
				case 47:
				{
					outBuf = "";
					type = TK_NAME;
					while ( true )
					{
						ch = file.readInt();
						if ( delims[ch + 1] )
							break;
						if ( ch == 35 )
						{
							ch = ( getHex( file.readInt() ) << 4 ) + getHex( file.readInt() );
						}
						outBuf += String.fromCharCode( ch );
					}
					backOnePosition( ch );
					break;
				}
				case 62:
					ch = file.readInt();
					if ( ch != 62 )
						throwError( "greater than not expected" );
					type = TK_END_DIC;
					break;
				case 60:
				{
					var v1: int = file.readInt();
					if ( v1 == 60 )
					{
						type = TK_START_DIC;
						break;
					}
					outBuf = "";
					type = TK_STRING;
					hexString = true;
					var v2: int = 0;
					while ( true )
					{
						while ( isWhitespace( v1 ) )
							v1 = file.readInt();
						if ( v1 == 62 )
							break;
						v1 = getHex( v1 );
						if ( v1 < 0 )
							break;
						v2 = file.readInt();
						while ( isWhitespace( v2 ) )
							v2 = file.readInt();
						if ( v2 == 62 )
						{
							ch = v1 << 4;
							outBuf += String.fromCharCode( ch );
							break;
						}
						v2 = getHex( v2 );
						if ( v2 < 0 )
							break;
						ch = ( v1 << 4 ) + v2;
						outBuf += String.fromCharCode( ch );
						v1 = file.readInt();
					}
					if ( v1 < 0 || v2 < 0 )
						throwError( "error reading string" );
					break;
				}
				case 37:
					type = TK_COMMENT;
					do
					{
						ch = file.readInt();
					} while ( ch != -1 && ch != 13 && ch != 10 );
					break;
				case 40:
				{
					outBuf = "";
					type = TK_STRING;
					hexString = false;
					var nesting: int = 0;
					while ( true )
					{
						ch = file.readInt();
						if ( ch == -1 )
							break;
						if ( ch == 40 )
						{
							++nesting;
						} else if ( ch == 41 )
						{
							--nesting;
						} else if ( ch == 92 )
						{
							var lineBreak: Boolean = false;
							ch = file.readInt();
							switch ( ch )
							{
								case 110:
									ch = 10;
									break;
								case 114:
									ch = 13;
									break;
								case 116:
									ch = 9;
									break;
								case 98:
									ch = 8;
									break;
								case 102:
									ch = 12;
									break;
								case 40:
								case 41:
								case 92:
									break;
								case 13:
									lineBreak = true;
									ch = file.readInt();
									if ( ch != 10 )
										backOnePosition( ch );
									break;
								case 10:
									lineBreak = true;
									break;
								default:
								{
									if ( ch < 48 || ch > 55 )
									{
										break;
									}
									var octal: int = ch - 48;
									ch = file.readInt();
									if ( ch < 48 || ch > 55 )
									{
										backOnePosition( ch );
										ch = octal;
										break;
									}
									octal = ( octal << 3 ) + ch - 48;
									ch = file.readInt();
									if ( ch < 48 || ch > 55 )
									{
										backOnePosition( ch );
										ch = octal;
										break;
									}
									octal = ( octal << 3 ) + ch - 48;
									ch = octal & 0xff;
									break;
								}
							}
							if ( lineBreak )
								continue;
							if ( ch < 0 )
								break;
						} else if ( ch == 13 )
						{
							ch = file.readInt();
							if ( ch < 0 )
								break;
							if ( ch != 10 )
							{
								backOnePosition( ch );
								ch = 10;
							}
						}
						if ( nesting == -1 )
							break;
						outBuf += String.fromCharCode( ch );
					}
					if ( ch == -1 )
						throwError( "error reading string" );
					break;
				}
				default:
				{
					outBuf = "";
					if ( ch == 45 || ch == 43 || ch == 46 || ( ch >= 48 && ch <= 57 ) )
					{
						type = TK_NUMBER;
						do
						{
							outBuf += String.fromCharCode( ch );
							ch = file.readInt();
						} while ( ch != -1 && ( ( ch >= 48 && ch <= 57 ) || ch == 46 ) );
					} else
					{
						type = TK_OTHER;
						do
						{
							outBuf += String.fromCharCode( ch );
							ch = file.readInt();
						} while ( !delims[ch + 1] );
					}
					backOnePosition( ch );
					break;
				}
			}
			if ( outBuf != null && outBuf.length > 0 )
				stringValue = outBuf;
			return true;
		}

		public function nextValidToken(): void
		{
			var level: int = 0;
			var n1: String = null;
			var n2: String = null;
			var ptr: uint = 0;
			while ( nextToken() )
			{
				if ( type == TK_COMMENT )
					continue;
				switch ( level )
				{
					case 0:
					{
						if ( type != TK_NUMBER )
							return;
						ptr = file.getFilePointer();
						n1 = stringValue;
						++level;
						break;
					}
					case 1:
					{
						if ( type != TK_NUMBER )
						{
							file.seek( ptr );
							type = TK_NUMBER;
							stringValue = n1;
							return;
						}
						n2 = stringValue;
						++level;
						break;
					}
					default:
					{
						if ( type != TK_OTHER || stringValue != "R" )
						{
							file.seek( ptr );
							type = TK_NUMBER;
							stringValue = n1;
							return;
						}
						type = TK_REF;
						reference = parseInt( n1 );
						generation = parseInt( n2 );
						return;
					}
				}
			}
			// if we hit here, the file is either corrupt (stream ended unexpectedly),
			// or the last token ended exactly at the end of a stream.  This last
			// case can occur inside an Object Stream.
		}

		public function readInt(): int
		{
			return file.readInt();
		}

		public function readLineSegment( input: Bytes ): Boolean
		{
			var c: int = -1;
			var eol: Boolean = false;
			var ptr: uint = 0;
			var len: uint = input.length;
			var cur: uint;
			if ( ptr < len )
			{
				while ( isWhitespace( ( c = readInt() ) ) )
				{
				}
				;
			}
			while ( !eol && ptr < len )
			{
				switch ( c )
				{
					case -1:
					case 10:
						eol = true;
						break;
					case 13:
						eol = true;
						cur = getFilePointer();
						if ( ( readInt() ) != 10 )
						{
							seek( cur );
						}
						break;
					default:
						input[ptr++] = c;
						break;
				}

				// break loop? do it before we read() again
				if ( eol || len <= ptr )
				{
					break;
				} else
				{
					c = readInt();
				}
			}
			if ( ptr >= len )
			{
				eol = false;
				while ( !eol )
				{
					switch ( c = readInt() )
					{
						case -1:
						case 10:
							eol = true;
							break;
						case 13:
							eol = true;
							cur = getFilePointer();
							if ( ( readInt() ) != 10 )
							{
								seek( cur );
							}
							break;
					}
				}
			}

			if ( ( c == -1 ) && ( ptr == 0 ) )
			{
				return false;
			}
			if ( ptr + 2 <= len )
			{
				input[ptr++] = 32;
				input[ptr] = 88;
			}
			return true;
		}

		public function readString( size: int ): String
		{
			var buf: String = "";
			var ch: int;
			while ( ( size-- ) > 0 )
			{
				ch = file.readInt();
				if ( ch == -1 )
					break;
				buf += String.fromCharCode( ch );
			}
			return buf;
		}

		/**
		 * @throws EOFError
		 */
		public function seek( pos: int ): void
		{
			file.seek( pos );
		}

		public function throwError( error: String ): void
		{
			throw new InvalidPdfError( error + " at file pointer " + file.getFilePointer() );
		}

		public static function getHex( v: int ): int
		{
			if ( v >= 48 && v <= 57 )
				return v - 48;
			if ( v >= 65 && v <= 70 )
				return v - 65 + 10;
			if ( v >= 97 && v <= 102 )
				return v - 97 + 10;
			return -1;
		}

		public static function isDelimiter( ch: int ): Boolean
		{
			return ( ch == 40 || ch == 41 || ch == 60 || ch == 62 || ch == 91 || ch == 93 || ch == 47 || ch == 37 );
		}

		public static function isDelimiterWhitespace( ch: int ): Boolean
		{
			return delims[ch + 1];
		}

		public static function isWhitespace( ch: int ): Boolean
		{
			return ( ch == 0 || ch == 9 || ch == 10 || ch == 12 || ch == 13 || ch == 32 );
		}
	}
}