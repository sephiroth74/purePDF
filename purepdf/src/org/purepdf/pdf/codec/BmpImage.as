/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BmpImage.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/BmpImage.as $
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
	
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.elements.images.ImageRaw;
	import org.purepdf.errors.BadElementError;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.io.ByteArrayInputStream;
	import org.purepdf.io.InputStream;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.utils.Bytes;

	public class BmpImage
	{
		private static const BI_BITFIELDS: int = 3;

		private static const BI_RGB: int = 0;
		private static const BI_RLE4: int = 2;
		private static const BI_RLE8: int = 1;

		private static const LCS_CALIBRATED_RGB: int = 0;
		private static const LCS_CMYK: int = 2;
		private static const LCS_sRGB: int = 1;

		private static const VERSION_2_1_BIT: int = 0;
		private static const VERSION_2_24_BIT: int = 3;
		private static const VERSION_2_4_BIT: int = 1;
		private static const VERSION_2_8_BIT: int = 2;

		private static const VERSION_3_1_BIT: int = 4;
		private static const VERSION_3_24_BIT: int = 7;
		private static const VERSION_3_4_BIT: int = 5;
		private static const VERSION_3_8_BIT: int = 6;

		private static const VERSION_3_NT_16_BIT: int = 8;
		private static const VERSION_3_NT_32_BIT: int = 9;
		private static const VERSION_4_16_BIT: int = 13;

		private static const VERSION_4_1_BIT: int = 10;
		private static const VERSION_4_24_BIT: int = 14;
		private static const VERSION_4_32_BIT: int = 15;
		private static const VERSION_4_4_BIT: int = 11;
		private static const VERSION_4_8_BIT: int = 12;

		public var properties: HashMap = new HashMap();
		protected var height: int;

		protected var width: int;
		private var alphaMask: int;
		private var bitmapFileSize: Number;
		private var bitmapOffset: Number;
		private var bitsPerPixel: int;
		private var blueMask: int;
		private var compression: Number;
		private var greenMask: int;
		private var imageSize: Number;
		private var imageType: int;
		// BMP variables
		private var inputStream: InputStream;
		private var isBottomUp: Boolean;
		private var numBands: int;
		private var palette: Bytes;
		private var redMask: int;
		private var xPelsPerMeter: Number;
		private var yPelsPerMeter: Number;

		public function BmpImage( input: InputStream, noHeader: Boolean, size: int )
		{
			bitmapFileSize = size;
			bitmapOffset = 0;
			process( input, noHeader );
		}

		/**
		 * @throws IOError
		 */
		protected function process( stream: InputStream, noHeader: Boolean ): void
		{
			var numberOfEntries: int;
			var sizeOfPalette: int;
			var off: int;
			var i: int;

			if ( noHeader || stream is ByteArrayInputStream )
			{
				inputStream = stream;
			} else
			{
				inputStream = new ByteArrayInputStream( stream.bytearray );
			}
			if ( !noHeader )
			{
				// Start File Header
				if ( !( readUnsignedByte( inputStream ) == 'B'.charCodeAt( 0 ) && readUnsignedByte( inputStream ) == 'M'.charCodeAt( 0 ) ) )
				{
					throw new RuntimeError( "invalid magic value for bmp file" );
				}

				bitmapFileSize = readDWord( inputStream );

				readWord( inputStream );
				readWord( inputStream );

				bitmapOffset = readDWord( inputStream );
			}
			var size: Number = readDWord( inputStream );

			if ( size == 12 )
			{
				width = readWord( inputStream );
				height = readWord( inputStream );
			} else
			{
				width = readLong( inputStream );
				height = readLong( inputStream );
			}

			var planes: int = readWord( inputStream );
			bitsPerPixel = readWord( inputStream );

			properties.put( "color_planes", planes );
			properties.put( "bits_per_pixel", bitsPerPixel );

			numBands = 3;
			if ( bitmapOffset == 0 )
				bitmapOffset = size;
			if ( size == 12 )
			{
				properties.put( "bmp_version", "BMP v. 2.x" );

				if ( bitsPerPixel == 1 )
				{
					imageType = VERSION_2_1_BIT;
				} else if ( bitsPerPixel == 4 )
				{
					imageType = VERSION_2_4_BIT;
				} else if ( bitsPerPixel == 8 )
				{
					imageType = VERSION_2_8_BIT;
				} else if ( bitsPerPixel == 24 )
				{
					imageType = VERSION_2_24_BIT;
				}

				numberOfEntries = ( bitmapOffset - 14 - size ) / 3;
				sizeOfPalette = numberOfEntries * 3;
				if ( bitmapOffset == size )
				{
					switch ( imageType )
					{
						case VERSION_2_1_BIT:
							sizeOfPalette = 2 * 3;
							break;
						case VERSION_2_4_BIT:
							sizeOfPalette = 16 * 3;
							break;
						case VERSION_2_8_BIT:
							sizeOfPalette = 256 * 3;
							break;
						case VERSION_2_24_BIT:
							sizeOfPalette = 0;
							break;
					}
					bitmapOffset = size + sizeOfPalette;
				}
				readPalette( sizeOfPalette );
			} else
			{

				compression = readDWord( inputStream );
				imageSize = readDWord( inputStream );
				xPelsPerMeter = readLong( inputStream );
				yPelsPerMeter = readLong( inputStream );
				var colorsUsed: Number = readDWord( inputStream );
				var colorsImportant: Number = readDWord( inputStream );

				switch ( int( compression ) )
				{
					case BI_RGB:
						properties.put( "compression", "BI_RGB" );
						break;

					case BI_RLE8:
						properties.put( "compression", "BI_RLE8" );
						break;

					case BI_RLE4:
						properties.put( "compression", "BI_RLE4" );
						break;

					case BI_BITFIELDS:
						properties.put( "compression", "BI_BITFIELDS" );
						break;
				}

				properties.put( "x_pixels_per_meter", xPelsPerMeter );
				properties.put( "y_pixels_per_meter", yPelsPerMeter );
				properties.put( "colors_used", colorsUsed );
				properties.put( "colors_important", colorsImportant );

				if ( size == 40 )
				{
					switch ( int( compression ) )
					{

						case BI_RGB:
						case BI_RLE8:
						case BI_RLE4:

							if ( bitsPerPixel == 1 )
							{
								imageType = VERSION_3_1_BIT;
							} else if ( bitsPerPixel == 4 )
							{
								imageType = VERSION_3_4_BIT;
							} else if ( bitsPerPixel == 8 )
							{
								imageType = VERSION_3_8_BIT;
							} else if ( bitsPerPixel == 24 )
							{
								imageType = VERSION_3_24_BIT;
							} else if ( bitsPerPixel == 16 )
							{
								imageType = VERSION_3_NT_16_BIT;
								redMask = 0x7C00;
								greenMask = 0x3E0;
								blueMask = 0x1F;
								properties.put( "red_mask", redMask );
								properties.put( "green_mask", greenMask );
								properties.put( "blue_mask", blueMask );
							} else if ( bitsPerPixel == 32 )
							{
								imageType = VERSION_3_NT_32_BIT;
								redMask = 0x00FF0000;
								greenMask = 0x0000FF00;
								blueMask = 0x000000FF;
								properties.put( "red_mask", redMask );
								properties.put( "green_mask", greenMask );
								properties.put( "blue_mask", blueMask );
							}

							numberOfEntries = int( ( bitmapOffset - 14 - size ) / 4 );
							sizeOfPalette = numberOfEntries * 4;
							if ( bitmapOffset == size )
							{
								switch ( imageType )
								{
									case VERSION_3_1_BIT:
										sizeOfPalette = int( colorsUsed == 0 ? 2 : colorsUsed ) * 4;
										break;
									case VERSION_3_4_BIT:
										sizeOfPalette = int( colorsUsed == 0 ? 16 : colorsUsed ) * 4;
										break;
									case VERSION_3_8_BIT:
										sizeOfPalette = int( colorsUsed == 0 ? 256 : colorsUsed ) * 4;
										break;
									default:
										sizeOfPalette = 0;
										break;
								}
								bitmapOffset = size + sizeOfPalette;
							}
							readPalette( sizeOfPalette );

							properties.put( "bmp_version", "BMP v. 3.x" );
							break;

						case BI_BITFIELDS:

							if ( bitsPerPixel == 16 )
							{
								imageType = VERSION_3_NT_16_BIT;
							} else if ( bitsPerPixel == 32 )
							{
								imageType = VERSION_3_NT_32_BIT;
							}

							redMask = int( readDWord( inputStream ) );
							greenMask = int( readDWord( inputStream ) );
							blueMask = int( readDWord( inputStream ) );

							properties.put( "red_mask", redMask );
							properties.put( "green_mask", greenMask );
							properties.put( "blue_mask", blueMask );

							if ( colorsUsed != 0 )
							{
								sizeOfPalette = int( colorsUsed ) * 4;
								readPalette( sizeOfPalette );
							}

							properties.put( "bmp_version", "BMP v. 3.x NT" );
							break;

						default:
							throw new RuntimeError( "Invalid compression specified in BMP file." );
					}
				} else if ( size == 108 )
				{
					properties.put( "bmp_version", "BMP v. 4.x" );

					redMask = int( readDWord( inputStream ) );
					greenMask = int( readDWord( inputStream ) );
					blueMask = int( readDWord( inputStream ) );
					alphaMask = int( readDWord( inputStream ) );
					var csType: Number = readDWord( inputStream );
					var redX: int = readLong( inputStream );
					var redY: int = readLong( inputStream );
					var redZ: int = readLong( inputStream );
					var greenX: int = readLong( inputStream );
					var greenY: int = readLong( inputStream );
					var greenZ: int = readLong( inputStream );
					var blueX: int = readLong( inputStream );
					var blueY: int = readLong( inputStream );
					var blueZ: int = readLong( inputStream );
					var gammaRed: Number = readDWord( inputStream );
					var gammaGreen: Number = readDWord( inputStream );
					var gammaBlue: Number = readDWord( inputStream );

					if ( bitsPerPixel == 1 )
					{
						imageType = VERSION_4_1_BIT;
					} else if ( bitsPerPixel == 4 )
					{
						imageType = VERSION_4_4_BIT;
					} else if ( bitsPerPixel == 8 )
					{
						imageType = VERSION_4_8_BIT;
					} else if ( bitsPerPixel == 16 )
					{
						imageType = VERSION_4_16_BIT;
						if ( int( compression ) == BI_RGB )
						{
							redMask = 0x7C00;
							greenMask = 0x3E0;
							blueMask = 0x1F;
						}
					} else if ( bitsPerPixel == 24 )
					{
						imageType = VERSION_4_24_BIT;
					} else if ( bitsPerPixel == 32 )
					{
						imageType = VERSION_4_32_BIT;
						if ( int( compression ) == BI_RGB )
						{
							redMask = 0x00FF0000;
							greenMask = 0x0000FF00;
							blueMask = 0x000000FF;
						}
					}

					properties.put( "red_mask", redMask );
					properties.put( "green_mask", greenMask );
					properties.put( "blue_mask", blueMask );
					properties.put( "alpha_mask", alphaMask );

					numberOfEntries = int( ( bitmapOffset - 14 - size ) / 4 );
					sizeOfPalette = numberOfEntries * 4;
					if ( bitmapOffset == size )
					{
						switch ( imageType )
						{
							case VERSION_4_1_BIT:
								sizeOfPalette = int( colorsUsed == 0 ? 2 : colorsUsed ) * 4;
								break;
							case VERSION_4_4_BIT:
								sizeOfPalette = int( colorsUsed == 0 ? 16 : colorsUsed ) * 4;
								break;
							case VERSION_4_8_BIT:
								sizeOfPalette = int( colorsUsed == 0 ? 256 : colorsUsed ) * 4;
								break;
							default:
								sizeOfPalette = 0;
								break;
						}
						bitmapOffset = size + sizeOfPalette;
					}
					readPalette( sizeOfPalette );

					switch ( int( csType ) )
					{
						case LCS_CALIBRATED_RGB:
							// All the new fields are valid only for this case
							properties.put( "color_space", "LCS_CALIBRATED_RGB" );
							properties.put( "redX", ( redX ) );
							properties.put( "redY", ( redY ) );
							properties.put( "redZ", ( redZ ) );
							properties.put( "greenX", ( greenX ) );
							properties.put( "greenY", ( greenY ) );
							properties.put( "greenZ", ( greenZ ) );
							properties.put( "blueX", ( blueX ) );
							properties.put( "blueY", ( blueY ) );
							properties.put( "blueZ", ( blueZ ) );
							properties.put( "gamma_red", ( gammaRed ) );
							properties.put( "gamma_green", ( gammaGreen ) );
							properties.put( "gamma_blue", ( gammaBlue ) );

							// break;
							throw new RuntimeError( "Not implemented yet." );

						case LCS_sRGB:
							properties.put( "color_space", "LCS_sRGB" );
							break;

						case LCS_CMYK:
							properties.put( "color_space", "LCS_CMYK" );
							throw new RuntimeError( "Not implemented yet." );
					}

				} else
				{
					properties.put( "bmp_version", "BMP v. 5.x" );
					throw new RuntimeError( "BMP version 5 not implemented yet." );
				}
			}

			if ( height > 0 )
			{
				isBottomUp = true;
			} else
			{
				isBottomUp = false;
				height = Math.abs( height );
			}
			if ( bitsPerPixel == 1 || bitsPerPixel == 4 || bitsPerPixel == 8 )
			{
				numBands = 1;
				var r: Bytes;
				var g: Bytes;
				var b: Bytes;
				var sizep: int;
				if ( imageType == VERSION_2_1_BIT || imageType == VERSION_2_4_BIT || imageType == VERSION_2_8_BIT )
				{

					sizep = palette.length / 3;

					if ( sizep > 256 )
					{
						sizep = 256;
					}

					r = new Bytes( sizep );
					g = new Bytes( sizep );
					b = new Bytes( sizep );
					for ( i = 0; i < sizep; i++ )
					{
						off = 3 * i;
						b[i] = palette[off];
						g[i] = palette[off + 1];
						r[i] = palette[off + 2];
					}
				} else
				{
					sizep = palette.length / 4;

					if ( sizep > 256 )
					{
						sizep = 256;
					}


					r = new Bytes( sizep );
					g = new Bytes( sizep );
					b = new Bytes( sizep );
					for ( i = 0; i < sizep; i++ )
					{
						off = 4 * i;
						b[i] = palette[off];
						g[i] = palette[off + 1];
						r[i] = palette[off + 2];
					}
				}

			} else if ( bitsPerPixel == 16 )
			{
				numBands = 3;
			} else if ( bitsPerPixel == 32 )
			{
				numBands = alphaMask == 0 ? 3 : 4;
			} else
			{
				numBands = 3;
			}
		}

		private function decodeRLE( is8: Boolean, values: Bytes ): Bytes
		{
			var val: Bytes = new Bytes( width * height );
			try
			{
				var ptr: int = 0;
				var x: int = 0;
				var q: int = 0;
				var i: int;
				var bt: int;

				for ( var y: int = 0; y < height && ptr < values.length;  )
				{
					var count: int = values[ptr++] & 0xff;
					if ( count != 0 )
					{
						bt = values[ptr++] & 0xff;
						if ( is8 )
						{
							for ( i = count; i != 0; --i )
							{
								val[q++] = bt;
							}
						} else
						{
							for ( i = 0; i < count; ++i )
							{
								val[q++] = ( ( i & 1 ) == 1 ? ( bt & 0x0f ) : ( ( bt >>> 4 ) & 0x0f ) );
							}
						}
						x += count;
					} else
					{
						count = values[ptr++] & 0xff;
						if ( count == 1 )
							break;
						switch ( count )
						{
							case 0:
								x = 0;
								++y;
								q = y * width;
								break;
							case 2:
								// delta mode
								x += values[ptr++] & 0xff;
								y += values[ptr++] & 0xff;
								q = y * width + x;
								break;
							default:
								// absolute mode
								if ( is8 )
								{
									for ( i = count; i != 0; --i )
										val[q++] = ( values[ptr++] & 0xff );
								} else
								{
									bt = 0;
									for ( i = 0; i < count; ++i )
									{
										if ( ( i & 1 ) == 0 )
											bt = values[ptr++] & 0xff;
										val[q++] = ( ( i & 1 ) == 1 ? ( bt & 0x0f ) : ( ( bt >>> 4 ) & 0x0f ) );
									}
								}
								x += count;
								if ( is8 )
								{
									if ( ( count & 1 ) == 1 )
										++ptr;
								} else
								{
									if ( ( count & 3 ) == 1 || ( count & 3 ) == 2 )
										++ptr;
								}
								break;
						}
					}
				}
			} catch ( e: RuntimeError )
			{
				//empty on purpose
			}

			return val;
		}

		private function findMask( mask: int ): int
		{
			var k: int = 0;
			for ( ; k < 32; ++k )
			{
				if ( ( mask & 1 ) == 1 )
					break;
				mask >>>= 1;
			}
			return mask;
		}

		private function findShift( mask: int ): int
		{
			var k: int = 0;
			for ( ; k < 32; ++k )
			{
				if ( ( mask & 1 ) == 1 )
					break;
				mask >>>= 1;
			}
			return k;
		}

		private function getImage(): ImageElement
		{
			var bdata: Bytes;

			// There should only be one tile.
			switch ( imageType )
			{

				case VERSION_2_1_BIT:
					// no compression
					return read1Bit( 3 );

				case VERSION_2_4_BIT:
					// no compression
					return read4Bit( 3 );

				case VERSION_2_8_BIT:
					// no compression
					return read8Bit( 3 );

				case VERSION_2_24_BIT:
					// no compression
					bdata = new Bytes( width * height * 3 );
					read24Bit( bdata );
					return new ImageRaw( null, width, height, 3, 8, bdata.buffer );

				case VERSION_3_1_BIT:
					// 1-bit images cannot be compressed.
					return read1Bit( 4 );

				case VERSION_3_4_BIT:
					switch ( int( compression ) )
					{
						case BI_RGB:
							return read4Bit( 4 );

						case BI_RLE4:
							return readRLE4();

						default:
							throw new RuntimeError( "Invalid compression specified for BMP file." );
					}

				case VERSION_3_8_BIT:
					switch ( int( compression ) )
					{
						case BI_RGB:
							return read8Bit( 4 );

						case BI_RLE8:
							return readRLE8();

						default:
							throw new RuntimeError( "Invalid compression specified for BMP file." );
					}

				case VERSION_3_24_BIT:
					// 24-bit images are not compressed
					bdata = new Bytes( width * height * 3 );
					read24Bit( bdata );
					return new ImageRaw( null, width, height, 3, 8, bdata.buffer );

				case VERSION_3_NT_16_BIT:
					return read1632Bit( false );

				case VERSION_3_NT_32_BIT:
					return read1632Bit( true );

				case VERSION_4_1_BIT:
					return read1Bit( 4 );

				case VERSION_4_4_BIT:
					switch ( int( compression ) )
					{

						case BI_RGB:
							return read4Bit( 4 );

						case BI_RLE4:
							return readRLE4();

						default:
							throw new RuntimeError( "Invalid compression specified for BMP file." );
					}

				case VERSION_4_8_BIT:
					switch ( int( compression ) )
					{

						case BI_RGB:
							return read8Bit( 4 );

						case BI_RLE8:
							return readRLE8();

						default:
							throw new RuntimeError( "Invalid compression specified for BMP file." );
					}

				case VERSION_4_16_BIT:
					return read1632Bit( false );

				case VERSION_4_24_BIT:
					bdata = new Bytes( width * height * 3 );
					read24Bit( bdata );
					return new ImageRaw( null, width, height, 3, 8, bdata.buffer );

				case VERSION_4_32_BIT:
					return read1632Bit( true );
			}
			return null;
		}

		private function getPalette( group: int ): Bytes
		{
			if ( palette == null )
				return null;
			var np: Bytes = new Bytes( palette.length / group * 3 );
			var e: int = palette.length / group;
			var src: int;
			var dest: int;
			for ( var k: int = 0; k < e; ++k )
			{
				src = k * group;
				dest = k * 3;
				np[dest + 2] = palette[src++];
				np[dest + 1] = palette[src++];
				np[dest] = palette[src];
			}
			return np;
		}

		private function indexedModel( bdata: Bytes, bpc: int, paletteEntries: int ): ImageElement
		{
			var img: ImageElement = new ImageRaw( null, width, height, 1, bpc, bdata.buffer );
			var colorspace: PdfArray = new PdfArray();
			colorspace.add( PdfName.INDEXED );
			colorspace.add( PdfName.DEVICERGB );
			var np: Bytes = getPalette( paletteEntries );
			var len: int = np.length;
			colorspace.add( new PdfNumber( len / 3 - 1 ) );
			colorspace.add( new PdfString( np ) );
			var ad: PdfDictionary = new PdfDictionary();
			ad.put( PdfName.COLORSPACE, colorspace );
			img.additional = ad;
			return img;
		}

		private function read1632Bit( is32: Boolean ): ImageElement
		{
			var red_mask: int = findMask( redMask );
			var red_shift: int = findShift( redMask );
			var red_factor: int = red_mask + 1;
			var green_mask: int = findMask( greenMask );
			var green_shift: int = findShift( greenMask );
			var green_factor: int = green_mask + 1;
			var blue_mask: int = findMask( blueMask );
			var blue_shift: int = findShift( blueMask );
			var blue_factor: int = blue_mask + 1;
			var bdata: Bytes = new Bytes( width * height * 3 );
			var bitsPerScanline: int;
			var padding: int = 0;
			var i: int;
			var j: int;
			var m: int;

			if ( !is32 )
			{
				// width * bitsPerPixel should be divisible by 32
				bitsPerScanline = width * 16;
				if ( bitsPerScanline % 32 != 0 )
				{
					padding = ( bitsPerScanline / 32 + 1 ) * 32 - bitsPerScanline;
					padding = int( Math.ceil( padding / 8.0 ) );
				}
			}

			var imSize: int = imageSize;
			if ( imSize == 0 )
			{
				imSize = int( bitmapFileSize - bitmapOffset );
			}

			var l: int = 0;
			var v: int;
			if ( isBottomUp )
			{
				for ( i = height - 1; i >= 0; --i )
				{
					l = width * 3 * i;
					for ( j = 0; j < width; j++ )
					{
						if ( is32 )
							v = readDWord( inputStream );
						else
							v = readWord( inputStream );
						bdata[l++] = ( ( ( v >>> red_shift ) & red_mask ) * 256 / red_factor );
						bdata[l++] = ( ( ( v >>> green_shift ) & green_mask ) * 256 / green_factor );
						bdata[l++] = ( ( ( v >>> blue_shift ) & blue_mask ) * 256 / blue_factor );
					}
					for ( m = 0; m < padding; m++ )
					{
						inputStream.readUnsignedByte();
					}
				}
			} else
			{
				for ( i = 0; i < height; i++ )
				{
					for ( j = 0; j < width; j++ )
					{
						if ( is32 )
							v = readDWord( inputStream );
						else
							v = readWord( inputStream );
						bdata[l++] = ( ( ( v >>> red_shift ) & red_mask ) * 256 / red_factor );
						bdata[l++] = ( ( ( v >>> green_shift ) & green_mask ) * 256 / green_factor );
						bdata[l++] = ( ( ( v >>> blue_shift ) & blue_mask ) * 256 / blue_factor );
					}
					for ( m = 0; m < padding; m++ )
					{
						inputStream.readUnsignedByte();
					}
				}
			}
			return new ImageRaw( null, width, height, 3, 8, bdata.buffer );
		}

		private function read1Bit( paletteEntries: int ): ImageElement
		{
			var bdata: Bytes = new Bytes( ( ( width + 7 ) / 8 ) * height );
			var padding: int = 0;
			var bytesPerScanline: int = int( Math.ceil( width / 8.0 ) );

			var remainder: int = bytesPerScanline % 4;
			if ( remainder != 0 )
			{
				padding = 4 - remainder;
			}

			var imSize: int = ( bytesPerScanline + padding ) * height;

			var values: Bytes = new Bytes( imSize );
			var bytesRead: int = 0;
			var i: int;

			while ( bytesRead < imSize )
			{
				bytesRead += inputStream.readBytes( values.buffer, bytesRead, imSize - bytesRead );
			}

			if ( isBottomUp )
			{

				for ( i = 0; i < height; i++ )
				{
					values.buffer.position = imSize - ( i + 1 ) * ( bytesPerScanline + padding );
					values.writeBytes( bdata, i * bytesPerScanline, bytesPerScanline );
				}
			} else
			{

				for ( i = 0; i < height; i++ )
				{
					values.buffer.position = i * ( bytesPerScanline + padding );
					values.writeBytes( bdata, i * bytesPerScanline, bytesPerScanline );
				}
			}
			return indexedModel( bdata, 1, paletteEntries );
		}

		private function read24Bit( bdata: Bytes ): void
		{
			var padding: int = 0;

			var bitsPerScanline: int = width * 24;
			if ( bitsPerScanline % 32 != 0 )
			{
				padding = ( bitsPerScanline / 32 + 1 ) * 32 - bitsPerScanline;
				padding = int( Math.ceil( padding / 8.0 ) );
			}


			var imSize: int = ( ( width * 3 + 3 ) / 4 * 4 ) * height;
			var values: Bytes = new Bytes( imSize );
			try
			{
				var bytesRead: int = 0;
				while ( bytesRead < imSize )
				{
					var r: int = inputStream.readBytes( values.buffer, bytesRead, imSize - bytesRead );
					if ( r < 0 )
						break;
					bytesRead += r;
				}
			} catch ( ioe: IOError )
			{
				throw new ConversionError( ioe );
			}

			var l: int = 0;
			var count: int;
			var i: int;
			var j: int;

			if ( isBottomUp )
			{
				var max: int = width * height * 3 - 1;

				count = -padding;
				for ( i = 0; i < height; i++ )
				{
					l = max - ( i + 1 ) * width * 3 + 1;
					count += padding;
					for ( j = 0; j < width; j++ )
					{
						bdata[l + 2] = values[count++];
						bdata[l + 1] = values[count++];
						bdata[l] = values[count++];
						l += 3;
					}
				}
			} else
			{
				count = -padding;
				for ( i = 0; i < height; i++ )
				{
					count += padding;
					for ( j = 0; j < width; j++ )
					{
						bdata[l + 2] = values[count++];
						bdata[l + 1] = values[count++];
						bdata[l] = values[count++];
						l += 3;
					}
				}
			}
		}

		private function read4Bit( paletteEntries: int ): ImageElement
		{
			var bdata: Bytes = new Bytes( ( ( width + 1 ) / 2 ) * height );
			var padding: int = 0;
			var bytesPerScanline: int = int( Math.ceil( width / 2.0 ) );
			var remainder: int = bytesPerScanline % 4;
			var i: int;

			if ( remainder != 0 )
			{
				padding = 4 - remainder;
			}

			var imSize: int = ( bytesPerScanline + padding ) * height;
			var values: Bytes = new Bytes( imSize );
			var bytesRead: int = 0;

			while ( bytesRead < imSize )
			{
				bytesRead += inputStream.readBytes( values.buffer, bytesRead, imSize - bytesRead );
			}

			if ( isBottomUp )
			{
				for ( i = 0; i < height; i++ )
				{
					values.buffer.position = imSize - ( i + 1 ) * ( bytesPerScanline + padding );
					values.writeBytes( bdata, i * bytesPerScanline, bytesPerScanline );
				}
			} else
			{
				for ( i = 0; i < height; i++ )
				{
					values.buffer.position = i * ( bytesPerScanline + padding );
					values.writeBytes( bdata, i * bytesPerScanline, bytesPerScanline );
				}
			}
			return indexedModel( bdata, 4, paletteEntries );
		}

		private function read8Bit( paletteEntries: int ): ImageElement
		{
			var bdata: Bytes = new Bytes( width * height );
			var padding: int = 0;
			var bitsPerScanline: int = width * 8;
			if ( bitsPerScanline % 32 != 0 )
			{
				padding = ( bitsPerScanline / 32 + 1 ) * 32 - bitsPerScanline;
				padding = int( Math.ceil( padding / 8.0 ) );
			}

			var imSize: int = ( width + padding ) * height;
			var values: Bytes = new Bytes( imSize );
			var bytesRead: int = 0;
			var i: int;

			while ( bytesRead < imSize )
			{
				bytesRead += inputStream.readBytes( values.buffer, bytesRead, imSize - bytesRead );
			}

			if ( isBottomUp )
			{

				for ( i = 0; i < height; i++ )
				{
					values.buffer.position = imSize - ( i + 1 ) * ( width + padding );
					values.writeBytes( bdata, i * width, width );
				}
			} else
			{
				for ( i = 0; i < height; i++ )
				{
					values.buffer.position = i * ( width + padding );
					values.writeBytes( bdata, i * width, width );
				}
			}
			return indexedModel( bdata, 8, paletteEntries );
		}

		private function readDWord( stream: InputStream ): Number
		{
			return readUnsignedInt( stream );
		}

		private function readInt( stream: InputStream ): int
		{
			var b1: int = readUnsignedByte( stream );
			var b2: int = readUnsignedByte( stream );
			var b3: int = readUnsignedByte( stream );
			var b4: int = readUnsignedByte( stream );
			return ( b4 << 24 ) | ( b3 << 16 ) | ( b2 << 8 ) | b1;
		}

		private function readLong( stream: InputStream ): int
		{
			return readInt( stream );
		}

		private function readPalette( sizeOfPalette: int ): void
		{
			if ( sizeOfPalette == 0 )
			{
				return;
			}

			palette = new Bytes( sizeOfPalette );
			var bytesRead: int = 0;
			while ( bytesRead < sizeOfPalette )
			{
				var r: int = inputStream.readBytes( palette.buffer, bytesRead, sizeOfPalette - bytesRead );
				if ( r < 0 )
				{
					throw new RuntimeError( "incomplete palette" );
				}
				bytesRead += r;
			}
			properties.put( "palette", palette );
		}

		private function readRLE4(): ImageElement
		{
			var imSize: int = imageSize;
			if ( imSize == 0 )
			{
				imSize = ( bitmapFileSize - bitmapOffset );
			}

			var values: Bytes = new Bytes( imSize );
			var bytesRead: int = 0;
			while ( bytesRead < imSize )
			{
				bytesRead += inputStream.readBytes( values.buffer, bytesRead, imSize - bytesRead );
			}

			var val: Bytes = decodeRLE( false, values );
			var i: int;

			if ( isBottomUp )
			{

				var inverted: Bytes = val;
				val = new Bytes( width * height );
				var l: int = 0;
				var index: int;
				var lineEnd: int;

				for ( i = height - 1; i >= 0; i-- )
				{
					index = i * width;
					lineEnd = l + width;
					while ( l != lineEnd )
					{
						val[l++] = inverted[index++];
					}
				}
			}
			var stride: int = ( ( width + 1 ) / 2 );
			var bdata: Bytes = new Bytes( stride * height );
			var ptr: int = 0;
			var sh: int = 0;
			for ( var h: int = 0; h < height; ++h )
			{
				for ( var w: int = 0; w < width; ++w )
				{
					if ( ( w & 1 ) == 0 )
						bdata[sh + w / 2] = ( val[ptr++] << 4 );
					else
						bdata[sh + w / 2] |= ( val[ptr++] & 0x0f );
				}
				sh += stride;
			}
			return indexedModel( bdata, 4, 4 );
		}

		private function readRLE8(): ImageElement
		{
			var imSize: int = imageSize;
			if ( imSize == 0 )
			{
				imSize = ( bitmapFileSize - bitmapOffset );
			}

			var values: Bytes = new Bytes( imSize );
			var bytesRead: int = 0;
			while ( bytesRead < imSize )
			{
				bytesRead += inputStream.readBytes( values.buffer, bytesRead, imSize - bytesRead );
			}

			var i: int;
			var val: Bytes = decodeRLE( true, values );
			imSize = width * height;

			if ( isBottomUp )
			{

				var temp: Bytes = new Bytes( val.length );
				var bytesPerScanline: int = width;
				for ( i = 0; i < height; i++ )
				{
					//System.arraycopy( val, imSize - ( i + 1 ) * ( bytesPerScanline ), temp, i * bytesPerScanline, bytesPerScanline );
					val.buffer.position = imSize - ( i + 1 ) * ( bytesPerScanline );
					val.writeBytes( temp, i * bytesPerScanline, bytesPerScanline );
				}
				val = temp;
			}
			return indexedModel( val, 8, 4 );
		}

		private function readShort( stream: InputStream ): int
		{
			var b1: int = readUnsignedByte( stream );
			var b2: int = readUnsignedByte( stream );
			return ( b2 << 8 ) | b1;
		}

		private function readUnsignedByte( stream: InputStream ): int
		{
			return ( stream.readUnsignedByte() & 0xff );
		}

		private function readUnsignedInt( stream: InputStream ): Number
		{
			var b1: int = readUnsignedByte( stream );
			var b2: int = readUnsignedByte( stream );
			var b3: int = readUnsignedByte( stream );
			var b4: int = readUnsignedByte( stream );
			var l: Number = ( b4 << 24 ) | ( b3 << 16 ) | ( b2 << 8 ) | b1;
			return l & 0xffffffff;
		}

		private function readUnsignedShort( stream: InputStream ): int
		{
			var b1: int = readUnsignedByte( stream );
			var b2: int = readUnsignedByte( stream );
			return ( ( b2 << 8 ) | b1 ) & 0xffff;
		}

		private function readWord( stream: InputStream ): int
		{
			return readUnsignedShort( stream );
		}

		/**
		 * Reads a BMP from a byte array.
		 * @param data the byte array
		 * @throws IOException on error
		 * @return the image
		 */
		public static function getImage( data: ByteArray ): ImageElement
		{
			var input: ByteArrayInputStream = new ByteArrayInputStream( data );
			var img: ImageElement = getImage2( input );
			img.originalData = data;
			return img;
		}

		/**
		 * Reads a BMP from a stream. The stream is not closed.
		 * @param is the stream
		 * @throws IOException on error
		 * @return the image
		 */
		public static function getImage2( input: InputStream ): ImageElement
		{
			return getImage3( input, false, 0 );
		}

		/**
		 * Reads a BMP from a stream. The stream is not closed.
		 * The BMP may not have a header and be considered as a plain DIB.
		 * @param is the stream
		 * @param noHeader true to process a plain DIB
		 * @param size the size of the DIB. Not used for a BMP
		 * @throws IOException on error
		 * @return the image
		 */
		public static function getImage3( input: InputStream, noHeader: Boolean, size: int ): ImageElement
		{
			var bmp: BmpImage = new BmpImage( input, noHeader, size );
			try
			{
				var img: ImageElement = bmp.getImage();
				img.setDpi( ( bmp.xPelsPerMeter * 0.0254 + 0.5 ), ( bmp.yPelsPerMeter * 0.0254 + 0.5 ) );
				img.originalType = ImageElement.ORIGINAL_BMP;
				return img;
			} catch ( be: BadElementError )
			{
				throw new ConversionError( be );
			}
			return null;
		}
	}
}