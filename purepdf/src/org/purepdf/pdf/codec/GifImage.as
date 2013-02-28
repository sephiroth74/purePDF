/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: GifImage.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/GifImage.as $
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
	import org.purepdf.errors.ConversionError;
	import org.purepdf.io.ByteArrayInputStream;
	import org.purepdf.io.DataInputStream;
	import org.purepdf.io.InputStream;
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.StringUtils;

	public class GifImage
	{
		protected static const SHORT_MASK: int = 0x7fff;
		protected static const MaxStackSize: int = 4096;
		protected var bgColor: int;
		protected var bgIndex: int;
		protected var block: Bytes = new Bytes( 256 );
		protected var blockSize: int = 0;
		protected var delay: int = 0;
		protected var dispose: int = 0; // 0=no action; 1=leave in place; 2=restore to bg; 3=restore to prev
		protected var frames: Vector.<GifFrame> = new Vector.<GifFrame>();
		protected var fromData: ByteArray;
		protected var fromUrl: String;
		protected var gctFlag: Boolean;
		protected var height: int;
		protected var input: DataInputStream;
		protected var interlace: Boolean;
		protected var ix: int, iy: int, iw: int, ih: int;
		protected var lctFlag: Boolean;
		protected var lctSize: int;
		protected var m_bpc: int;
		protected var m_curr_table: Bytes;
		protected var m_gbpc: int;
		protected var m_global_table: Bytes;
		protected var m_line_stride: int;
		protected var m_local_table: Bytes;
		protected var m_out: ByteArray;
		protected var pixelAspect: int;
		protected var pixelStack: Bytes;
		protected var pixels: Bytes;
		protected var prefix: Vector.<int>;
		protected var suffix: Bytes;
		protected var transIndex: int;
		protected var transparency: Boolean = false;
		protected var width: int;

		public function GifImage( data: ByteArray )
		{
			fromData = data;
			var ins: InputStream = null;

			ins = new ByteArrayInputStream( data );
			process( ins );
		}

		public function get framesCount(): int
		{
			return frames.length;
		}

		/**
		 * Gets the image from a frame.
		 * First frame is 1
		 *
		 * @param frame
		 * @return the image
		 */
		public function getImage( frame: int = 1 ): ImageElement
		{
			var gf: GifFrame = frames[ frame - 1 ];
			return gf.image;
		}

		protected function decodeImageData(): Boolean
		{
			var NullCode: int = -1;
			var npix: int = iw * ih;
			var available: int;
			var clear: int;
			var code_mask: int;
			var code_size: int;
			var end_of_information: int;
			var in_code: int;
			var old_code: int;
			var bits: int;
			var code: int;
			var count: int;
			var i: int;
			var datum: int;
			var data_size: int;
			var first: int;
			var top: int;
			var bi: int;
			var skipZero: Boolean = false;

			if ( prefix == null )
				prefix = new Vector.<int>( MaxStackSize );

			if ( suffix == null )
				suffix = new Bytes( MaxStackSize );

			if ( pixelStack == null )
				pixelStack = new Bytes( MaxStackSize + 1 );
			
			
			m_line_stride = ( iw * m_bpc + 7 ) / 8;
			m_out = new ByteArray();
			m_out.length = ( m_line_stride * ih );
			var pass: int = 1;
			var inc: int = interlace ? 8 : 1;
			var line: int = 0;
			var xpos: int = 0;
			
			//  Initialize GIF data stream decoder.
			data_size = input.readUnsignedByte();
			clear = 1 << data_size;
			end_of_information = clear + 1;
			available = clear + 2;
			old_code = NullCode;
			code_size = data_size + 1;
			code_mask = ( 1 << code_size ) - 1;

			for ( code = 0; code < clear; code++ )
			{
				prefix[ code ] = 0;
				suffix[ code ] = code;
			}
			
			//  Decode GIF pixel stream.
			datum = bits = count = first = top = bi = 0;

			for ( i = 0; i < npix;  )
			{
				if ( top == 0 )
				{
					if ( bits < code_size )
					{
						//  Load bytes until there are enough bits for a code.
						if ( count == 0 )
						{
							// Read a new data block.
							count = readBlock();

							if ( count <= 0 )
							{
								skipZero = true;
								break;
							}
							bi = 0;
						}
						datum += ( block[ bi ] & 0xff ) << bits;
						bits += 8;
						bi++;
						count--;
						continue;
					}
					//  Get the next code.
					code = datum & code_mask;
					datum >>= code_size;
					bits -= code_size;

					//  Interpret the code
					if ( ( code > available ) || ( code == end_of_information ) )
						break;
					
					if ( code == clear )
					{
						//  Reset decoder.
						code_size = data_size + 1;
						code_mask = ( 1 << code_size ) - 1;
						available = clear + 2;
						old_code = NullCode;
						continue;
					}
					

					if ( old_code == NullCode )
					{
						pixelStack.writeIntAtPosition( top++, suffix[code] );
						old_code = code;
						first = code;
						continue;
					}
					
					in_code = code;

					if ( code == available )
					{
						pixelStack[ top++ ] = first;
						code = old_code;
					}
					
					while ( code > clear )
					{
						//pixelStack[ top++ ] = suffix[code];
						pixelStack.writeIntAtPosition( top++, suffix[ code ] );
						code = prefix[ code ];
					}
					first = suffix[ code ] & 0xff;

					//  Add a new string to the string table,
					if ( available >= MaxStackSize )
						break;
					pixelStack[ top++ ] = first;
					prefix[ available ] = old_code & SHORT_MASK;
					suffix[ available ] = first;
					available++;

					if ( ( ( available & code_mask ) == 0 ) && ( available < MaxStackSize ) )
					{
						code_size++;
						code_mask += available;
					}
					old_code = in_code;
				}
				//  Pop a pixel off the pixel stack.
				top--;
				i++;
				setPixel( xpos, line, pixelStack[ top ] );
				++xpos;

				if ( xpos >= iw )
				{
					xpos = 0;
					line += inc;

					if ( line >= ih )
					{
						if ( interlace )
						{
							do
							{
								pass++;

								switch ( pass )
								{
									case 2:
										line = 4;
										break;
									case 3:
										line = 2;
										inc = 4;
										break;
									case 4:
										line = 1;
										inc = 2;
										break;
									default: // this shouldn't happen
										line = ih - 1;
										inc = 0;
								}
							} while ( line >= ih );
						}
						else
						{
							line = ih - 1; // this shouldn't happen
							inc = 0;
						}
					}
				}
			}
			
			return skipZero;
		}

		protected function readBlock(): int
		{
			blockSize = input.readUnsignedByte();

			if ( blockSize <= 0 )
				return blockSize = 0;

			for ( var k: int = 0; k < blockSize; ++k )
			{
				var v: int = input.readUnsignedByte();

				if ( v < 0 )
				{
					return blockSize = k;
				}
				block[ k ] = v;
			}
			return blockSize;
		}

		protected function readColorTable( bpc: int ): Bytes
		{
			var ncolors: int = 1 << bpc;
			var nbytes: int = 3 * ncolors;
			bpc = newBpc( bpc );
			var table: Bytes = new Bytes( ( 1 << bpc ) * 3 );
			input.readFully( table.buffer, 0, nbytes );
			return table;
		}

		protected function readContents(): void
		{
			var done: Boolean = false;
			var code: int;

			while ( !done )
			{
				code = input.readUnsignedByte();

				switch ( code )
				{
					case 0x2C: // image separator
						readImage();
						break;
					case 0x21: // extension
						code = input.readUnsignedByte();
						switch ( code )
					{
						case 0xf9: // graphics control extension
							readGraphicControlExt();
							break;
						case 0xff: // application extension
							readBlock();
							skip(); // don't care
							break;
						default: // uninteresting extension
							skip();
					}
						break;
					default:
						done = true;
						break;
				}
			}
		}

		protected function readGraphicControlExt(): void
		{
			input.readUnsignedByte(); // block size
			var packed: int = input.readUnsignedByte(); // packed fields
			dispose = ( packed & 0x1c ) >> 2; // disposal method

			if ( dispose == 0 )
				dispose = 1; // elect to keep old image if discretionary
			transparency = ( packed & 1 ) != 0;
			delay = readShort() * 10; // delay in milliseconds
			transIndex = input.readUnsignedByte(); // transparent color index
			input.readUnsignedByte(); // block terminator
		}

		protected function readHeader(): void
		{
			var id: String = "";

			for ( var i: int = 0; i < 6; i++ )
				id += String.fromCharCode( input.readUnsignedByte() );

			if ( !StringUtils.startsWith( id, "GIF8" ) )
			{
				throw new IOError( "gif signature not found" );
			}
			readLSD();

			if ( gctFlag )
			{
				m_global_table = readColorTable( m_gbpc );
			}
		}

		protected function readImage(): void
		{
			ix = readShort(); // (sub)image position & size
			iy = readShort();
			iw = readShort();
			ih = readShort();
			var packed: int = input.readUnsignedByte();
			lctFlag = ( packed & 0x80 ) != 0; // 1 - local color table flag
			interlace = ( packed & 0x40 ) != 0; // 2 - interlace flag
			// 3 - sort flag
			// 4-5 - reserved
			lctSize = 2 << ( packed & 7 ); // 6-8 - local color table size
			m_bpc = newBpc( m_gbpc );

			if ( lctFlag )
			{
				m_curr_table = readColorTable( ( packed & 7 ) + 1 ); // read table
				m_bpc = newBpc( ( packed & 7 ) + 1 );
			}
			else
			{
				m_curr_table = m_global_table;
			}

			if ( transparency && transIndex >= m_curr_table.length / 3 )
				transparency = false;

			if ( transparency && m_bpc == 1 )
			{ // Acrobat 5.05 doesn't like this combination
				var tp: Bytes = new Bytes( 12 );
				tp.writeBytes( m_curr_table, 0, 6 );
				m_curr_table = tp;
				m_bpc = 2;
			}
			var skipZero: Boolean = decodeImageData(); // decode pixel data

			if ( !skipZero )
				skip();
			var img: ImageElement = null;

			try
			{
				img = new ImageRaw( null, iw, ih, 1, m_bpc, m_out );
				var colorspace: PdfArray = new PdfArray();
				colorspace.add( PdfName.INDEXED );
				colorspace.add( PdfName.DEVICERGB );
				var len: int = m_curr_table.length;
				colorspace.add( new PdfNumber( len / 3 - 1 ) );
				colorspace.add( new PdfString( m_curr_table ) );
				var ad: PdfDictionary = new PdfDictionary();
				ad.put( PdfName.COLORSPACE, colorspace );
				img.additional = ad;

				if ( transparency )
				{
					var ti: Vector.<int> = new Vector.<int>( 2 );
					ti[ 0 ] = transIndex;
					ti[ 1 ] = transIndex;
					img.transparency = ti;
				}
			}
			catch ( e: Error )
			{
				throw new ConversionError( e.getStackTrace() );
			}
			img.originalType = ImageElement.ORIGINAL_GIF;
			img.originalData = fromData;
			img.url = fromUrl;
			var gf: GifFrame = new GifFrame();
			gf.image = img;
			gf.ix = ix;
			gf.iy = iy;
			frames.push( gf ); // add image to frame list
		}

		protected function readLSD(): void
		{
			width = readShort();
			height = readShort();
			var packed: int = input.readUnsignedByte();
			gctFlag = ( packed & 0x80 ) != 0;
			m_gbpc = ( packed & 7 ) + 1;
			bgIndex = input.readUnsignedByte();
			pixelAspect = input.readUnsignedByte(); // pixel aspect ratio
		}

		protected function readShort(): int
		{
			return input.readUnsignedByte() | ( input.readUnsignedByte() << 8 );
		}

		protected function setPixel( x: int, y: int, v: int ): void
		{
			var pos: int;
			
			if ( m_bpc == 8 )
			{
				pos = x + iw * y;
				m_out[ pos ] = ByteBuffer.intToByte( v );
			}
			else
			{
				pos = m_line_stride * y + x / ( 8 / m_bpc );
				var vout: int = v << ( 8 - m_bpc * ( x % ( 8 / m_bpc ) ) - m_bpc );
				m_out[ pos ] |= vout;
			}
		}

		protected function skip(): void
		{
			do
			{
				readBlock();
			} while ( blockSize > 0 );
		}

		private function process( i: InputStream ): void
		{
			input = new DataInputStream( i );
			readHeader();
			readContents();

			if ( frames.length == 0 )
				throw new IOError( "the file does not contain any valid image" );
		}

		private static function newBpc( bpc: int ): int
		{
			switch ( bpc )
			{
				case 1:
				case 2:
				case 4:
					break;
				case 3:
					return 4;
				default:
					return 8;
			}
			return bpc;
		}
	}
}
import org.purepdf.elements.images.ImageElement;

class GifFrame
{
	public var image: ImageElement;
	public var ix: int;
	public var iy: int;
}