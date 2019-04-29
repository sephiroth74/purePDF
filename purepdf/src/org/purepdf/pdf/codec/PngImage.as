/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PngImage.as 392 2011-01-14 08:05:17Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 392 $ $LastChangedDate: 2011-01-14 03:05:17 -0500 (Fri, 14 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/PngImage.as $
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
package org.purepdf.pdf.codec
{
	import flash.errors.IOError;
	import flash.utils.ByteArray;
	
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.elements.images.ImageRaw;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.io.ByteArrayInputStream;
	import org.purepdf.io.DataInputStream;
	import org.purepdf.io.InputStream;
	import org.purepdf.io.zip.InflaterInputStream;
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfLiteral;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfObject;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.pdf_core;

	public class PngImage
	{
		public static const IDAT: String = "IDAT";
		public static const IEND: String = "IEND";
		public static const IHDR: String = "IHDR";
		public static const PLTE: String = "PLTE";
		public static const PNGID: Vector.<int> = Vector.<int>( [ 137, 80, 78, 71, 13, 10, 26, 10 ] );
		public static const cHRM: String = "cHRM";
		public static const gAMA: String = "gAMA";
		public static const iCCP: String = "iCCP";
		public static const pHYs: String = "pHYs";
		public static const sRGB: String = "sRGB";
		public static const tRNS: String = "tRNS";
		private static const PNG_FILTER_AVERAGE: int = 3;
		private static const PNG_FILTER_NONE: int = 0;
		private static const PNG_FILTER_PAETH: int = 4;
		private static const PNG_FILTER_SUB: int = 1;
		private static const PNG_FILTER_UP: int = 2;
		private static const TRANSFERSIZE: int = 4096;
		private static const intents: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.PERCEPTUAL, PdfName.RELATIVECOLORIMETRIC, PdfName.SATURATION, PdfName.ABSOLUTECOLORIMETRIC ] );
		private var XYRatio: Number;
		private var additional: PdfDictionary = new PdfDictionary();
		private var bitDepth: int;
		private var bytesPerPixel: int; // private var of: number private var per: bytes private var pixel: input
		private var colorTable: Bytes;
		private var colorType: int;
		private var compressionMethod: int;
		private var dataStream: DataInputStream;
		private var dpiX: int;
		private var dpiY: int;
		private var filterMethod: int;
		private var gamma: Number = 1.0;
		private var genBWMask: Boolean;
		private var hasCHRM: Boolean = false;
		private var height: int;
		private var idat: ByteBuffer = new ByteBuffer();
		private var image: Bytes;
		private var inputBands: int;
		private var ins: ByteArrayInputStream;
		private var intent: PdfName;
		private var interlaceMethod: int;
		private var palShades: Boolean;
		private var smask: Bytes;
		private var trans: Bytes;
		private var transBlue: int = -1;
		private var transGreen: int = -1;
		private var transRedGray: int = -1;
		private var width: int;
		private var xW: Number, yW: Number, xR: Number, yR: Number, xG: Number, yG: Number, xB: Number, yB: Number;

		public function PngImage( $ins: ByteArrayInputStream )
		{
			ins = $ins;
		}

		private function checkMarker( s: String ): Boolean
		{
			if ( s.length != 4 )
				return false;

			for ( var k: int = 0; k < 4; ++k )
			{
				var c: int = s.charCodeAt( k );

				if ( ( c < 'a'.charCodeAt( 0 ) || c > 'z'.charCodeAt( 0 ) ) && ( c < 'A'.charCodeAt( 0 ) || c > 'Z'.charCodeAt( 0 ) ) )
					return false;
			}
			return true;
		}

		private function decodeIdat(): void
		{
			var nbitDepth: int = bitDepth;

			if ( nbitDepth == 16 )
				nbitDepth = 8;
			var size: int = -1;
			bytesPerPixel = ( bitDepth == 16 ) ? 2 : 1;

			switch ( colorType )
			{
				case 0:
					size = ( nbitDepth * width + 7 ) / 8 * height;
					break;
				case 2:
					size = width * 3 * height;
					bytesPerPixel *= 3;
					break;
				case 3:
					if ( interlaceMethod == 1 )
						size = ( nbitDepth * width + 7 ) / 8 * height;
					bytesPerPixel = 1;
					break;
				case 4:
					size = width * height;
					bytesPerPixel *= 2;
					break;
				case 6:
					size = width * 3 * height;
					bytesPerPixel *= 4;
					break;
			}

			if ( size >= 0 )
			{
				image = new Bytes( size );
			}

			if ( palShades )
			{
				smask = new Bytes( width * height );
			}
			else if ( genBWMask )
			{
				smask = new Bytes( ( width + 7 ) / 8 * height );
			}
			var bb: Bytes = new Bytes();
			bb.buffer = idat.getBuffer();
			var bai: ByteArrayInputStream = new ByteArrayInputStream( idat.getBuffer(), 0, idat.getBuffer().length );
			
			var infStream: InputStream = new InflaterInputStream( bai );
			dataStream = new DataInputStream( infStream );

			if ( interlaceMethod != 1 )
			{
				decodePass( 0, 0, 1, 1, width, height );
			}
			else
			{
				decodePass( 0, 0, 8, 8, ( width + 7 ) / 8, ( height + 7 ) / 8 );
				decodePass( 4, 0, 8, 8, ( width + 3 ) / 8, ( height + 7 ) / 8 );
				decodePass( 0, 4, 4, 8, ( width + 3 ) / 4, ( height + 3 ) / 8 );
				decodePass( 2, 0, 4, 4, ( width + 1 ) / 4, ( height + 3 ) / 4 );
				decodePass( 0, 2, 2, 4, ( width + 1 ) / 2, ( height + 1 ) / 4 );
				decodePass( 1, 0, 2, 2, width / 2, ( height + 1 ) / 2 );
				decodePass( 0, 1, 1, 2, width, height / 2 );
			}
		}

		private function decodePass( xOffset: int, yOffset: int, xStep: int, yStep: int, passWidth: int, passHeight: int ): void
		{
			if ( ( passWidth == 0 ) || ( passHeight == 0 ) )
			{
				return;
			}
			var bytesPerRow: int = ( inputBands * passWidth * bitDepth + 7 ) / 8;
			var curr: Bytes = new Bytes( bytesPerRow );
			var prior: Bytes = new Bytes( bytesPerRow );
			
			var srcY: int, dstY: int;

			for ( srcY = 0, dstY = yOffset; srcY < passHeight; srcY++, dstY += yStep )
			{
				var filter: int = 0;

				try
				{
					filter = dataStream.readUnsignedByte();
					dataStream.readFully( curr.buffer, 0, bytesPerRow );
				}
				catch ( e: Error )
				{
					trace( e.getStackTrace() );
				}

				switch ( filter )
				{
					case PNG_FILTER_NONE:
						break;
					case PNG_FILTER_SUB:
						decodeSubFilter( curr, bytesPerRow, bytesPerPixel );
						break;
					case PNG_FILTER_UP:
						decodeUpFilter( curr, prior, bytesPerRow );
						break;
					case PNG_FILTER_AVERAGE:
						decodeAverageFilter( curr, prior, bytesPerRow, bytesPerPixel );
						break;
					case PNG_FILTER_PAETH:
						decodePaethFilter( curr, prior, bytesPerRow, bytesPerPixel );
						break;
					default:
						// Error -- uknown filter type
						throw new RuntimeError( "unknown png filter" );
				}
				processPixels( curr, xOffset, xStep, dstY, passWidth );
				var tmp: Bytes = prior;
				prior = curr;
				curr = tmp;
			}
		}

		private function getColorspace(): PdfObject
		{
			if ( gamma == 1 && !hasCHRM )
			{
				if ( ( colorType & 2 ) == 0 )
					return PdfName.DEVICEGRAY;
				else
					return PdfName.DEVICERGB;
			}
			else
			{
				var array: PdfArray = new PdfArray();
				var dic: PdfDictionary = new PdfDictionary();

				if ( ( colorType & 2 ) == 0 )
				{
					if ( gamma == 1 )
						return PdfName.DEVICEGRAY;
					array.add( PdfName.CALGRAY );
					dic.put( PdfName.GAMMA, new PdfNumber( gamma ) );
					dic.put( PdfName.WHITEPOINT, new PdfLiteral( "[1 1 1]" ) );
					array.add( dic );
				}
				else
				{
					var wp: PdfObject = new PdfLiteral( "[1 1 1]" );
					array.add( PdfName.CALRGB );

					if ( gamma != 1 )
					{
						var gm: PdfArray = new PdfArray();
						var n: PdfNumber = new PdfNumber( gamma );
						gm.add( n );
						gm.add( n );
						gm.add( n );
						dic.put( PdfName.GAMMA, gm );
					}

					if ( hasCHRM )
					{
						var z: Number = yW * ( ( xG - xB ) * yR - ( xR - xB ) * yG + ( xR - xG ) * yB );
						var YA: Number = yR * ( ( xG - xB ) * yW - ( xW - xB ) * yG + ( xW - xG ) * yB ) / z;
						var XA: Number = YA * xR / yR;
						var ZA: Number = YA * ( ( 1 - xR ) / yR - 1 );
						var YB: Number = -yG * ( ( xR - xB ) * yW - ( xW - xB ) * yR + ( xW - xR ) * yB ) / z;
						var XB: Number = YB * xG / yG;
						var ZB: Number = YB * ( ( 1 - xG ) / yG - 1 );
						var YC: Number = yB * ( ( xR - xG ) * yW - ( xW - xG ) * yW + ( xW - xR ) * yG ) / z;
						var XC: Number = YC * xB / yB;
						var ZC: Number = YC * ( ( 1 - xB ) / yB - 1 );
						var XW: Number = XA + XB + XC;
						var YW: Number = 1;
						var ZW: Number = ZA + ZB + ZC;
						var wpa: PdfArray = new PdfArray();
						wpa.add( new PdfNumber( XW ) );
						wpa.add( new PdfNumber( YW ) );
						wpa.add( new PdfNumber( ZW ) );
						wp = wpa;
						var matrix: PdfArray = new PdfArray();
						matrix.add( new PdfNumber( XA ) );
						matrix.add( new PdfNumber( YA ) );
						matrix.add( new PdfNumber( ZA ) );
						matrix.add( new PdfNumber( XB ) );
						matrix.add( new PdfNumber( YB ) );
						matrix.add( new PdfNumber( ZB ) );
						matrix.add( new PdfNumber( XC ) );
						matrix.add( new PdfNumber( YC ) );
						matrix.add( new PdfNumber( ZC ) );
						dic.put( PdfName.MATRIX, matrix );
					}
					dic.put( PdfName.WHITEPOINT, wp );
					array.add( dic );
				}
				return array;
			}
		}

		private function getImage(): ImageElement
		{
			readPng();
			var pal0: int = 0;
			var palIdx: int = 0;
			var im2: ImageElement;
			palShades = false;

			if ( trans != null )
			{
				for ( var k: int = 0; k < trans.length; ++k )
				{
					var n: int = trans[ k ] & 0xff;

					if ( n == 0 )
					{
						++pal0;
						palIdx = k;
					}

					if ( n != 0 && n != 255 )
					{
						palShades = true;
						break;
					}
				}
			}

			if ( ( colorType & 4 ) != 0 )
				palShades = true;
			genBWMask = ( !palShades && ( pal0 > 1 || transRedGray >= 0 ) );

			if ( !palShades && !genBWMask && pal0 == 1 )
			{
				additional.put( PdfName.MASK, new PdfLiteral( "[" + palIdx + " " + palIdx + "]" ) );
			}
			var needDecode: Boolean = ( interlaceMethod == 1 ) || ( bitDepth == 16 ) || ( ( colorType & 4 ) != 0 ) || palShades || genBWMask;

			switch ( colorType )
			{
				case 0:
					inputBands = 1;
					break;
				case 2:
					inputBands = 3;
					break;
				case 3:
					inputBands = 1;
					break;
				case 4:
					inputBands = 2;
					break;
				case 6:
					inputBands = 4;
					break;
			}

			if ( needDecode )
				decodeIdat();
			var components: int = inputBands;

			if ( ( colorType & 4 ) != 0 )
				--components;
			var bpc: int = bitDepth;

			if ( bpc == 16 )
				bpc = 8;
			var img: ImageElement;

			if ( image != null )
			{
				if ( colorType == 3 )
					img = new ImageRaw( null, width, height, components, bpc, image.buffer );
				else
					img = ImageElement.getRawInstance( width, height, components, bpc, image.buffer );
			}
			else
			{
				img = new ImageRaw( null, width, height, components, bpc, idat.toByteArray().buffer );
				img.deflated = true;
				var decodeparms: PdfDictionary = new PdfDictionary();
				decodeparms.put( PdfName.BITSPERCOMPONENT, new PdfNumber( bitDepth ) );
				decodeparms.put( PdfName.PREDICTOR, new PdfNumber( 15 ) );
				decodeparms.put( PdfName.COLUMNS, new PdfNumber( width ) );
				decodeparms.put( PdfName.COLORS, new PdfNumber( ( colorType == 3 || ( colorType & 2 ) == 0 ) ? 1 : 3 ) );
				additional.put( PdfName.DECODEPARMS, decodeparms );
			}

			if ( additional.getValue( PdfName.COLORSPACE ) == null )
				additional.put( PdfName.COLORSPACE, getColorspace() );

			if ( intent != null )
				additional.put( PdfName.INTENT, intent );

			if ( additional.size > 0 )
				img.additional = additional;

			if ( palShades )
			{
				im2 = ImageElement.getRawInstance( width, height, 1, 8, smask.buffer );
				im2.makeMask();
				img.imageMask = im2;
			}

			if ( genBWMask )
			{
				im2 = ImageElement.getRawInstance( width, height, 1, 1, smask.buffer );
				im2.makeMask();
				img.imageMask = im2;
			}
			img.setDpi( dpiX, dpiY );
			img.xyRatio = XYRatio;
			img.originalType = ImageElement.ORIGINAL_PNG;
			return img;
		}

		private function getPixel( curr: Bytes ): Vector.<int>
		{
			var out: Vector.<int>;
			var k: int;

			switch ( bitDepth )
			{
				case 8:
				{
					out = new Vector.<int>( curr.length );

					for ( k = 0; k < out.length; ++k )
						out[ k ] = curr[ k ] & 0xff;
					return out;
				}
				case 16:
				{
					out = new Vector.<int>( curr.length / 2 );

					for ( k = 0; k < out.length; ++k )
						out[ k ] = ( ( curr[ k * 2 ] & 0xff ) << 8 ) + ( curr[ k * 2 + 1 ] & 0xff );
					return out;
				}
				default:
				{
					out = new Vector.<int>( curr.length * 8 / bitDepth );
					var idx: int = 0;
					var passes: int = 8 / bitDepth;
					var mask: int = ( 1 << bitDepth ) - 1;

					for ( k = 0; k < curr.length; ++k )
					{
						for ( var j: int = passes - 1; j >= 0; --j )
						{
							out[ idx++ ] = ( curr[ k ] >>> ( bitDepth * j ) ) & mask;
						}
					}
					return out;
				}
			}
		}

		private function processPixels( curr: Bytes, xOffset: int, step: int, y: int, width: int ): void
		{
			var srcX: int;
			var dstX: int;
			var out: Vector.<int> = this.getPixel( curr );
			var sizes: int = 0;
			var yStride: int;
			var k: int;
			var v: Vector.<int>;
			var idx: int;
			
			switch ( colorType )
			{
				case 0:
				case 3:
				case 4:
					sizes = 1;
					break;
				case 2:
				case 6:
					sizes = 3;
					break;
			}
			
			if ( image != null )
			{
				dstX = xOffset;
				yStride = ( sizes * this.width * ( bitDepth == 16 ? 8 : bitDepth ) + 7 ) / 8;

				for ( srcX = 0; srcX < width; srcX++ )
				{
					setPixel( image, out, inputBands * srcX, sizes, dstX, y, bitDepth, yStride );
					dstX += step;
				}
			}
			
			if ( palShades )
			{
				if ( ( colorType & 4 ) != 0 )
				{
					if ( bitDepth == 16 )
					{
						for ( k = 0; k < width; ++k )
							out[ k * inputBands + sizes ] >>>= 8;
					}
					yStride = this.width;
					dstX = xOffset;

					for ( srcX = 0; srcX < width; srcX++ )
					{
						setPixel( smask, out, inputBands * srcX + sizes, 1, dstX, y, 8, yStride );
						dstX += step;
					}
				}
				else
				{ //colorType 3
					yStride = this.width;
					v = new Vector.<int>( 1 );
					dstX = xOffset;

					for ( srcX = 0; srcX < width; srcX++ )
					{
						idx = out[ srcX ];

						if ( idx < trans.length )
							v[ 0 ] = trans[ idx ];
						else
							v[ 0 ] = 255; // Patrick Valsecchi
						setPixel( smask, v, 0, 1, dstX, y, 8, yStride );
						dstX += step;
					}
				}
			}
			else if ( genBWMask )
			{
				switch ( colorType )
				{
					case 3:
					{
						yStride = ( this.width + 7 ) / 8;
						v = new Vector.<int>( 1 );
						dstX = xOffset;

						for ( srcX = 0; srcX < width; srcX++ )
						{
							idx = out[ srcX ];
							v[ 0 ] = ( ( idx < trans.length && trans[ idx ] == 0 ) ? 1 : 0 );
							setPixel( smask, v, 0, 1, dstX, y, 1, yStride );
							dstX += step;
						}
						break;
					}
					case 0:
					{
						yStride = ( this.width + 7 ) / 8;
						v = new Vector.<int>( 1 );
						dstX = xOffset;

						for ( srcX = 0; srcX < width; srcX++ )
						{
							var g: int = out[ srcX ];
							v[ 0 ] = ( g == transRedGray ? 1 : 0 );
							setPixel( smask, v, 0, 1, dstX, y, 1, yStride );
							dstX += step;
						}
						break;
					}
					case 2:
					{
						yStride = ( this.width + 7 ) / 8;
						v = new Vector.<int>( 1 );
						dstX = xOffset;

						for ( srcX = 0; srcX < width; srcX++ )
						{
							var markRed: int = inputBands * srcX;
							v[ 0 ] = ( out[ markRed ] == transRedGray && out[ markRed + 1 ] == transGreen && out[ markRed + 2 ] == transBlue ? 1 : 0 );
							setPixel( smask, v, 0, 1, dstX, y, 1, yStride );
							dstX += step;
						}
						break;
					}
				}
			}
		}

		private function readPng(): void
		{
			for ( var i: int = 0; i < PNGID.length; i++ )
			{
				if ( PNGID[ i ] != ins.readUnsignedByte() )
				{
					throw new IOError( "file is not a valid png" );
				}
			}
			var buffer: Bytes = new Bytes( TRANSFERSIZE );
			var k: int;

			while ( true )
			{
				var len: int = getInt( ins );
				
				var marker: String = getString( ins );

				if ( len < 0 || !checkMarker( marker ) )
					throw new IOError( "corrupted png file" );

				if ( IDAT == marker )
				{
					var size: int;

					while ( len != 0 )
					{
						size = ins.readBytes( buffer.buffer, 0, Math.min( len, TRANSFERSIZE ) );

						if ( size < 0 )
							return;
						idat.writeBytes( buffer, 0, size );
						len -= size;
					}
				}
				else if ( tRNS == marker )
				{
					switch ( colorType )
					{
						case 0:
							if ( len >= 2 )
							{
								len -= 2;
								var gray: int = getWord( ins );

								if ( bitDepth == 16 )
									transRedGray = gray;
								else
									additional.put( PdfName.MASK, new PdfLiteral( "[" + gray + " " + gray + "]" ) );
							}
							break;
						case 2:
							if ( len >= 6 )
							{
								len -= 6;
								var red: int = getWord( ins );
								var green: int = getWord( ins );
								var blue: int = getWord( ins );

								if ( bitDepth == 16 )
								{
									transRedGray = red;
									transGreen = green;
									transBlue = blue;
								}
								else
								{
									additional.put( PdfName.MASK, new PdfLiteral( "[" + red + " " + red + " " + green + " " + green + " " + blue + " " + blue + "]" ) );
								}
							}
							break;
						case 3:
							if ( len > 0 )
							{
								trans = new Bytes();

								for ( k = 0; k < len; ++k )
									trans[ k ] = ins.readUnsignedByte();
								len = 0;
							}
							break;
					}
					ins.skip( len );
				}
				else if ( IHDR == marker )
				{
					width = getInt( ins );
					height = getInt( ins );
					bitDepth = ins.readUnsignedByte();
					colorType = ins.readUnsignedByte();
					compressionMethod = ins.readUnsignedByte();
					filterMethod = ins.readUnsignedByte();
					interlaceMethod = ins.readUnsignedByte();
				}
				else if ( PLTE == marker )
				{
					if ( colorType == 3 )
					{
						var colorspace: PdfArray = new PdfArray();
						colorspace.add( PdfName.INDEXED );
						colorspace.add( getColorspace() );
						colorspace.add( new PdfNumber( len / 3 - 1 ) );
						var colortable: ByteBuffer = new ByteBuffer();

						while ( ( len-- ) > 0 )
						{
							colortable.pdf_core::append_int( ins.readUnsignedByte() );
						}
						colorspace.add( new PdfString( colorTable = colortable.toByteArray() ) );
						additional.put( PdfName.COLORSPACE, colorspace );
					}
					else
					{
						ins.skip( len );
					}
				}
				else if ( pHYs == marker )
				{
					var dx: int = getInt( ins );
					var dy: int = getInt( ins );
					var unit: int = ins.readUnsignedByte();

					if ( unit == 1 )
					{
						dpiX = ( dx * 0.0254 + 0.5 );
						dpiY = ( dy * 0.0254 + 0.5 );
					}
					else
					{
						if ( dy != 0 )
							XYRatio = Number( dx ) / Number( dy );
					}
				}
				else if ( cHRM == marker )
				{
					xW = getInt( ins ) / 100000;
					yW = getInt( ins ) / 100000;
					xR = getInt( ins ) / 100000;
					yR = getInt( ins ) / 100000;
					xG = getInt( ins ) / 100000;
					yG = getInt( ins ) / 100000;
					xB = getInt( ins ) / 100000;
					yB = getInt( ins ) / 100000;
					hasCHRM = !( Math.abs( xW ) < 0.0001 || Math.abs( yW ) < 0.0001 || Math.abs( xR ) < 0.0001 || Math.abs( yR ) < 0.0001 || Math.abs( xG ) < 0.0001 || Math.abs( yG ) < 0.0001 || Math.abs( xB ) < 0.0001 || Math.abs( yB ) < 0.0001 );
				}
				else if ( sRGB == marker )
				{
					var ri: int = ins.readUnsignedByte();
					intent = intents[ ri ];
					gamma = 2.2;
					xW = 0.3127;
					yW = 0.329;
					xR = 0.64;
					yR = 0.33;
					xG = 0.3;
					yG = 0.6;
					xB = 0.15;
					yB = 0.06;
					hasCHRM = true;
				}
				else if ( gAMA == marker )
				{
					var gm: int = getInt( ins );

					if ( gm != 0 )
					{
						gamma = 100000 / gm;

						if ( !hasCHRM )
						{
							xW = 0.3127;
							yW = 0.329;
							xR = 0.64;
							yR = 0.33;
							xG = 0.3;
							yG = 0.6;
							xB = 0.15;
							yB = 0.06;
							hasCHRM = true;
						}
					}
				}
				else if ( iCCP == marker )
				{
					do
					{
						--len;
					} while ( ins.readUnsignedByte() != 0 );
					ins.readUnsignedByte();
					--len;
					var icccom: Bytes = new Bytes( len );
					var p: int = 0;

					while ( len > 0 )
					{
						var r: int = ins.readBytes( icccom.buffer, p, len );

						if ( r < 0 )
							throw new IOError( "premature end of file" );
						p += r;
						len -= r;
					}
				}
				else if ( IEND == marker )
				{
					break;
				}
				else
				{
					ins.skip( len );
				}
				ins.skip( 4 );
			}
		}

		public static function getImage( data: ByteArray ): ImageElement
		{
			var ins: ByteArrayInputStream = new ByteArrayInputStream( data );
			var png: PngImage = new PngImage( ins );
			var img: ImageElement = png.getImage();
			img.originalData = data;
			return img;
		}

		public static function getInt( ins: ByteArrayInputStream ): int
		{
			return ( ins.readUnsignedByte() << 24 ) + ( ins.readUnsignedByte() << 16 ) + ( ins.readUnsignedByte() << 8 ) + ins.readUnsignedByte();
		}

		public static function getString( ins: ByteArrayInputStream ): String
		{
			var buf: String = "";

			for ( var i: int = 0; i < 4; i++ )
			{
				buf += String.fromCharCode( ins.readUnsignedByte() );
			}
			return buf;
		}

		public static function getWord( ins: ByteArrayInputStream ): int
		{
			return ( ins.readUnsignedByte() << 8 ) + ins.readUnsignedByte();
		}

		protected static function getPixel( image: Bytes, x: int, y: int, bitDepth: int, bytesPerRow: int ): int
		{
			var pos: int;
			var v: int;

			if ( bitDepth == 8 )
			{
				pos = bytesPerRow * y + x;
				return image[ pos ] & 0xff;
			}
			else
			{
				pos = bytesPerRow * y + x / ( 8 / bitDepth );
				v = image[ pos ] >> ( 8 - bitDepth * ( x % ( 8 / bitDepth ) ) - bitDepth );
				return v & ( ( 1 << bitDepth ) - 1 );
			}
		}

		protected static function setPixel( image: Bytes, data: Vector.<int>, offset: int, size: int, x: int, y: int, bitDepth: int, bytesPerRow: int ): void
		{
			var pos: int;
			var k: int;

			if ( bitDepth == 8 )
			{
				pos = bytesPerRow * y + size * x;

				for ( k = 0; k < size; ++k )
					image[ pos + k ] = data[ k + offset ];
			}
			else if ( bitDepth == 16 )
			{
				pos = bytesPerRow * y + size * x;

				for ( k = 0; k < size; ++k )
					image[ pos + k ] = ( data[ k + offset ] >>> 8 );
			}
			else
			{
				pos = bytesPerRow * y + x / ( 8 / bitDepth );
				var v: int = data[ offset ] << ( 8 - bitDepth * ( x % ( 8 / bitDepth ) ) - bitDepth );
				image[ pos ] |= v;
			}
		}
		
		private static function decodeAverageFilter( curr: Bytes, prev: Bytes, count: int, bpp: int ): void
		{
			var raw: int;
			var priorRow: int;
			var i: int;
			
			for ( i = 0; i < bpp; i++ )
			{
				raw = curr[ i ] & 0xff;
				priorRow = (prev[ i ] & 0xff) >>> 1;
				curr[ i ] = ( raw + priorRow );
			}
			
			for ( i = bpp; i < count; i++ )
			{
				raw = curr[ i ] & 0xff;
				priorRow = ((prev[ i ] & 0xff) + (curr[ i - bpp ] & 0xff)) >>> 1;
				curr[ i ] = ( raw + priorRow );
			}
		}

		private static function decodePaethFilter( curr: Bytes, prev: Bytes, count: int, bpp: int ): void
		{
			var raw: int;
			var priorPixel: int;
			var priorRow: int;
			var priorRowPixel: int;
			var i: int;

			for ( i = 0; i < bpp; i++ )
			{
				raw = curr[ i ] & 0xff;
				priorRow = prev[ i ] & 0xff;
				curr[ i ] = ( raw + priorRow );
			}

			for ( i = bpp; i < count; i++ )
			{
				raw = curr[ i ] & 0xff;
				priorPixel = curr[ i - bpp ] & 0xff;
				priorRow = prev[ i ] & 0xff;
				priorRowPixel = prev[ i - bpp ] & 0xff;
				curr[ i ] = ( raw + paethPredictor( priorPixel, priorRow, priorRowPixel ) );
			}
		}

		private static function decodeSubFilter( curr: Bytes, count: int, bpp: int ): void
		{
			var val: int;

			for ( var i: int = bpp; i < count; i++ )
			{
				val = curr[ i ] & 0xff;
				val += curr[ i - bpp ] & 0xff;
				curr[ i ] = val;
			}
		}

		private static function decodeUpFilter( curr: Bytes, prev: Bytes, count: int ): void
		{
			var raw: int;
			var prior: int;

			for ( var i: int = 0; i < count; i++ )
			{
				raw = curr[ i ] & 0xff;
				prior = prev[ i ] & 0xff;
				curr[ i ] = ( raw + prior );
			}
		}

		private static function paethPredictor( a: int, b: int, c: int ): int
		{
			var p: int = a + b - c;
			var pa: int = Math.abs( p - a );
			var pb: int = Math.abs( p - b );
			var pc: int = Math.abs( p - c );

			if ( ( pa <= pb ) && ( pa <= pc ) )
			{
				return a;
			}
			else if ( pb <= pc )
			{
				return b;
			}
			else
			{
				return c;
			}
		}
		
		private static function bytesToString( b: Bytes, len: int ): String
		{
			var s: String = "[";
			for ( var k: int = 0; k < len; ++k )
			{
				s += b[k];
				if( k < len - 1 )
					s += ",";
			}
			s += "]";
			return s;
		}
	}
}