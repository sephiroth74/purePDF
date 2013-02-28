/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: CCITTG4Encoder.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/CCITTG4Encoder.as $
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
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.utils.Bytes;

	public class CCITTG4Encoder
	{
		private var rowbytes: int;
		private var rowpixels: int;
		private var bit: int = 8;
		private var data: int;
		private var refline: Bytes;
		private var outBuf: ByteBuffer = new ByteBuffer();
		private var dataBp: Bytes;
		private var offsetData: int;
		private var sizeData: int;
		
		/**
		 * Creates a new encoder.
		 * @param width the line width
		 */
		public function CCITTG4Encoder( width: int )
		{
			rowpixels = width;
			rowbytes = (rowpixels + 7) / 8;
			refline = new Bytes(rowbytes);
		}
		
		/**
		 * Encodes a number of lines.
		 * @param data the data to be encoded
		 * @param offset the offset into the data
		 * @param size the size of the data to be encoded
		 */    
		public function fax4Encode( data: Bytes, offset: int, size: int ): void
		{
			dataBp = data;
			offsetData = offset;
			sizeData = size;
			
			while (sizeData > 0) {
				fax3Encode2DRow();

				refline.buffer.position = 0;
				refline.writeBytes( dataBp, offsetData, rowbytes );
								
				offsetData += rowbytes;
				sizeData -= rowbytes;
			}
		}
		
		private static function find0span( bp: Bytes, offset: int, bs: int, be: int ): int
		{
			var bits: int = be - bs;
			var n: int;
			var span: int;
			var pos: int = offset + (bs >> 3);

			if (bits > 0 && (n = (bs & 7)) != 0) {
				span = zeroruns[(bp[pos] << n) & 0xff];
				if (span > 8-n)
					span = 8-n;
				if (span > bits)
					span = bits;
				if (n+span < 8)
					return span;
				bits -= span;
				pos++;
			} else
			{
				span = 0;
			}

			while (bits >= 8) {
				if (bp[pos] != 0)
					return (span + zeroruns[bp[pos] & 0xff]);
				span += 8;
				bits -= 8;
				pos++;
			}

			if (bits > 0) {
				n = zeroruns[bp[pos] & 0xff];
				span += (n > bits ? bits : n);
			}
			return span;
		}
		
		/**
		 * Encodes a number of lines.
		 * @param data the data to be encoded
		 * @param height the number of lines to encode
		 */    
		public function fax4Encode2( data: Bytes, height: int ): void
		{
			fax4Encode( data, 0, rowbytes * height );
		}
		
		private function pixel(data: Bytes, offset: int, bit: int ): int
		{
			if (bit >= rowpixels)
				return 0;
			return ((data[offset + (bit >> 3)] & 0xff) >> (7-((bit)&7))) & 1;
		}
		
		private static function finddiff( bp: Bytes, offset: int, bs: int, be: int, color: int ): int
		{
			return bs + (color != 0 ? find1span(bp, offset, bs, be) : find0span(bp, offset, bs, be));
		}
		
		private static function finddiff2( bp: Bytes, offset: int, bs: int, be: int, color: int ): int
		{
			return bs < be ? finddiff(bp, offset, bs, be, color) : be;
		}
		
		private static function find1span( bp: Bytes, offset: int, bs: int, be: int ): int
		{
			var bits: int = be - bs;
			var n: int;
			var span: int;
			var pos: int = offset + (bs >> 3);

			if (bits > 0 && (n = (bs & 7)) != 0) {
				span = oneruns[(bp[pos] << n) & 0xff];
				if (span > 8-n)
					span = 8-n;
				if (span > bits)
					span = bits;
				if (n+span < 8)
					return span;
				bits -= span;
				pos++;
			} else
			{
				span = 0;
			}

			while (bits >= 8) {
				if (bp[pos] != -1)
					return (span + oneruns[bp[pos] & 0xff]);
				span += 8;
				bits -= 8;
				pos++;
			}

			if (bits > 0) {
				n = oneruns[bp[pos] & 0xff];
				span += (n > bits ? bits : n);
			}
			return span;
		}
		
		private function putcode( table: Vector.<int> ): void
		{
			putBits( table[CODE], table[LENGTH] );
		}
		
		private function putspan( span: int, tab: Vector.<Vector.<int>> ): void
		{
			var code: int;
			var length: int;
			var te: Vector.<int>;
			
			while (span >= 2624) {
				te = tab[63 + (2560>>6)];
				code = te[CODE];
				length = te[LENGTH];
				putBits(code, length);
				span -= te[RUNLEN];
			}
			if (span >= 64) {
				te = tab[63 + (span>>6)];
				code = te[CODE];
				length = te[LENGTH];
				putBits(code, length);
				span -= te[RUNLEN];
			}
			
			code = tab[span][CODE];
			length = tab[span][LENGTH];
			putBits(code, length);
		}
		
		private function putBits( bits: int, length: int ): void
		{
			while (length > bit) {
				data |= bits >> (length - bit);
				length -= bit;
				outBuf.append_byte( data );
				data = 0;
				bit = 8;
			}
			data |= (bits & msbmask[length]) << (bit - length);
			bit -= length;
			if (bit == 0) {
				outBuf.append_byte( data );
				data = 0;
				bit = 8;
			}
		}
		
		private function fax3Encode2DRow(): void
		{
			var a0: int = 0;
			var a1: int = (pixel(dataBp, offsetData, 0) != 0 ? 0 : finddiff(dataBp, offsetData, 0, rowpixels, 0));
			var b1: int = (pixel(refline, 0, 0) != 0 ? 0 : finddiff(refline, 0, 0, rowpixels, 0));
			var a2: int;
			var b2: int;
			var d: int;
			
			for (;;) {
				b2 = finddiff2(refline, 0, b1, rowpixels, pixel(refline, 0,b1));
				if (b2 >= a1) {
					d = b1 - a1;
					if (!(-3 <= d && d <= 3)) {	/* horizontal mode */
						a2 = finddiff2(dataBp, offsetData, a1, rowpixels, pixel(dataBp, offsetData,a1));
						putcode(horizcode);
						if (a0+a1 == 0 || pixel(dataBp, offsetData, a0) == 0) {
							putspan(a1-a0, TIFFFaxWhiteCodes);
							putspan(a2-a1, TIFFFaxBlackCodes);
						} else {
							putspan(a1-a0, TIFFFaxBlackCodes);
							putspan(a2-a1, TIFFFaxWhiteCodes);
						}
						a0 = a2;
					} else {			/* vertical mode */
						putcode(vcodes[d+3]);
						a0 = a1;
					}
				} else {				/* pass mode */
					putcode(passcode);
					a0 = b2;
				}
				if (a0 >= rowpixels)
					break;
				a1 = finddiff(dataBp, offsetData, a0, rowpixels, pixel(dataBp, offsetData,a0));
				b1 = finddiff(refline, 0, a0, rowpixels, pixel(dataBp, offsetData,a0) ^ 1);
				b1 = finddiff(refline, 0, b1, rowpixels, pixel(dataBp, offsetData,a0));
			}
		}
		
		public function close(): Bytes
		{
			fax4PostEncode();
			return outBuf.toByteArray();
		}
		
		private function fax4PostEncode(): void
		{
			putBits( EOL, 12 );
			putBits( EOL, 12 );
			
			if (bit != 8) {
				outBuf.append_byte( data );
				data = 0;
				bit = 8;
			}
		}

		
		/**
		 * Encodes a full image.
		 * @param data the data to encode
		 * @param width the image width
		 * @param height the image height
		 * @return the encoded image
		 */    
		public static function compress( data: Bytes, width: int, height: int ): Bytes
		{
			var g4: CCITTG4Encoder = new CCITTG4Encoder( width );
			g4.fax4Encode( data, 0, g4.rowbytes * height );
			return g4.close();
		}
		
		private static const LENGTH: int = 0;
		private static const CODE: int = 1;
		private static const RUNLEN: int = 2;
		private static const EOL: int = 0x001;
		private static const G3CODE_EOL: int= -1;
		private static const G3CODE_INVALID: int = -2;
		private static const G3CODE_EOF: int = -3;
		private static const G3CODE_INCOMP: int = -4;
		
		private var horizcode: Vector.<int> = Vector.<int>([ 3, 0x1, 0 ]);
		private var passcode: Vector.<int> = Vector.<int>([ 4, 0x1, 0 ]);
		private var vcodes: Vector.<Vector.<int>> = Vector.<Vector.<int>>([
			Vector.<int>([ 7, 0x03, 0 ]),	
			Vector.<int>([ 6, 0x03, 0 ]),	
			Vector.<int>([ 3, 0x03, 0 ]),	
			Vector.<int>([ 1, 0x1, 0 ]),	
			Vector.<int>([ 3, 0x2, 0 ]),	
			Vector.<int>([ 6, 0x02, 0 ]),	
			Vector.<int>([ 7, 0x02, 0 ])	
		]);
		
		private var TIFFFaxWhiteCodes: Vector.<Vector.<int>> = Vector.<Vector.<int>>([
			Vector.<int>([ 8, 0x35, 0 ]),
			Vector.<int>([ 6, 0x7, 1 ]),
			Vector.<int>([ 4, 0x7, 2 ]),
			Vector.<int>([ 4, 0x8, 3 ]),
			Vector.<int>([ 4, 0xB, 4 ]),
			Vector.<int>([ 4, 0xC, 5 ]),
			Vector.<int>([ 4, 0xE, 6 ]),
			Vector.<int>([ 4, 0xF, 7 ]),
			Vector.<int>([ 5, 0x13, 8 ]),
			Vector.<int>([ 5, 0x14, 9 ]),
			Vector.<int>([ 5, 0x7, 10 ]),
			Vector.<int>([ 5, 0x8, 11 ]),
			Vector.<int>([ 6, 0x8, 12 ]),
			Vector.<int>([ 6, 0x3, 13 ]),
			Vector.<int>([ 6, 0x34, 14 ]),
			Vector.<int>([ 6, 0x35, 15 ]),
			Vector.<int>([ 6, 0x2A, 16 ]),
			Vector.<int>([ 6, 0x2B, 17 ]),
			Vector.<int>([ 7, 0x27, 18 ]),
			Vector.<int>([ 7, 0xC, 19 ]),
			Vector.<int>([ 7, 0x8, 20 ]),
			Vector.<int>([ 7, 0x17, 21 ]),
			Vector.<int>([ 7, 0x3, 22 ]),
			Vector.<int>([ 7, 0x4, 23 ]),
			Vector.<int>([ 7, 0x28, 24 ]),
			Vector.<int>([ 7, 0x2B, 25 ]),
			Vector.<int>([ 7, 0x13, 26 ]),
			Vector.<int>([ 7, 0x24, 27 ]),
			Vector.<int>([ 7, 0x18, 28 ]),
			Vector.<int>([ 8, 0x2, 29 ]),
			Vector.<int>([ 8, 0x3, 30 ]),
			Vector.<int>([ 8, 0x1A, 31 ]),
			Vector.<int>([ 8, 0x1B, 32 ]),
			Vector.<int>([ 8, 0x12, 33 ]),
			Vector.<int>([ 8, 0x13, 34 ]),
			Vector.<int>([ 8, 0x14, 35 ]),
			Vector.<int>([ 8, 0x15, 36 ]),
			Vector.<int>([ 8, 0x16, 37 ]),
			Vector.<int>([ 8, 0x17, 38 ]),
			Vector.<int>([ 8, 0x28, 39 ]),
			Vector.<int>([ 8, 0x29, 40 ]),
			Vector.<int>([ 8, 0x2A, 41 ]),
			Vector.<int>([ 8, 0x2B, 42 ]),
			Vector.<int>([ 8, 0x2C, 43 ]),
			Vector.<int>([ 8, 0x2D, 44 ]),
			Vector.<int>([ 8, 0x4, 45 ]),
			Vector.<int>([ 8, 0x5, 46 ]),
			Vector.<int>([ 8, 0xA, 47 ]),
			Vector.<int>([ 8, 0xB, 48 ]),
			Vector.<int>([ 8, 0x52, 49 ]),
			Vector.<int>([ 8, 0x53, 50 ]),
			Vector.<int>([ 8, 0x54, 51 ]),
			Vector.<int>([ 8, 0x55, 52 ]),
			Vector.<int>([ 8, 0x24, 53 ]),
			Vector.<int>([ 8, 0x25, 54 ]),
			Vector.<int>([ 8, 0x58, 55 ]),
			Vector.<int>([ 8, 0x59, 56 ]),
			Vector.<int>([ 8, 0x5A, 57 ]),
			Vector.<int>([ 8, 0x5B, 58 ]),
			Vector.<int>([ 8, 0x4A, 59 ]),
			Vector.<int>([ 8, 0x4B, 60 ]),
			Vector.<int>([ 8, 0x32, 61 ]),
			Vector.<int>([ 8, 0x33, 62 ]),
			Vector.<int>([ 8, 0x34, 63 ]),
			Vector.<int>([ 5, 0x1B, 64 ]),
			Vector.<int>([ 5, 0x12, 128 ]),
			Vector.<int>([ 6, 0x17, 192 ]),
			Vector.<int>([ 7, 0x37, 256 ]),
			Vector.<int>([ 8, 0x36, 320 ]),
			Vector.<int>([ 8, 0x37, 384 ]),
			Vector.<int>([ 8, 0x64, 448 ]),
			Vector.<int>([ 8, 0x65, 512 ]),
			Vector.<int>([ 8, 0x68, 576 ]),
			Vector.<int>([ 8, 0x67, 640 ]),
			Vector.<int>([ 9, 0xCC, 704 ]),
			Vector.<int>([ 9, 0xCD, 768 ]),
			Vector.<int>([ 9, 0xD2, 832 ]),
			Vector.<int>([ 9, 0xD3, 896 ]),
			Vector.<int>([ 9, 0xD4, 960 ]),
			Vector.<int>([ 9, 0xD5, 1024 ]),
			Vector.<int>([ 9, 0xD6, 1088 ]),
			Vector.<int>([ 9, 0xD7, 1152 ]),
			Vector.<int>([ 9, 0xD8, 1216 ]),
			Vector.<int>([ 9, 0xD9, 1280 ]),
			Vector.<int>([ 9, 0xDA, 1344 ]),
			Vector.<int>([ 9, 0xDB, 1408 ]),
			Vector.<int>([ 9, 0x98, 1472 ]),
			Vector.<int>([ 9, 0x99, 1536 ]),
			Vector.<int>([ 9, 0x9A, 1600 ]),
			Vector.<int>([ 6, 0x18, 1664 ]),
			Vector.<int>([ 9, 0x9B, 1728 ]),
			Vector.<int>([ 11, 0x8, 1792 ]),
			Vector.<int>([ 11, 0xC, 1856 ]),
			Vector.<int>([ 11, 0xD, 1920 ]),
			Vector.<int>([ 12, 0x12, 1984 ]),
			Vector.<int>([ 12, 0x13, 2048 ]),
			Vector.<int>([ 12, 0x14, 2112 ]),
			Vector.<int>([ 12, 0x15, 2176 ]),
			Vector.<int>([ 12, 0x16, 2240 ]),
			Vector.<int>([ 12, 0x17, 2304 ]),
			Vector.<int>([ 12, 0x1C, 2368 ]),
			Vector.<int>([ 12, 0x1D, 2432 ]),
			Vector.<int>([ 12, 0x1E, 2496 ]),
			Vector.<int>([ 12, 0x1F, 2560 ]),
			Vector.<int>([ 12, 0x1, G3CODE_EOL ]),
			Vector.<int>([ 9, 0x1, G3CODE_INVALID ]),
			Vector.<int>([ 10, 0x1, G3CODE_INVALID ]),
			Vector.<int>([ 11, 0x1, G3CODE_INVALID ]),
			Vector.<int>([ 12, 0x0, G3CODE_INVALID ])
		]);
		
		private var TIFFFaxBlackCodes: Vector.<Vector.<int>> = Vector.<Vector.<int>>([
			Vector.<int>([ 10, 0x37, 0 ]),
			Vector.<int>([ 3, 0x2, 1 ]),
			Vector.<int>([ 2, 0x3, 2 ]),
			Vector.<int>([ 2, 0x2, 3 ]),
			Vector.<int>([ 3, 0x3, 4 ]),
			Vector.<int>([ 4, 0x3, 5 ]),
			Vector.<int>([ 4, 0x2, 6 ]),
			Vector.<int>([ 5, 0x3, 7 ]),
			Vector.<int>([ 6, 0x5, 8 ]),
			Vector.<int>([ 6, 0x4, 9 ]),
			Vector.<int>([ 7, 0x4, 10 ]),
			Vector.<int>([ 7, 0x5, 11 ]),
			Vector.<int>([ 7, 0x7, 12 ]),
			Vector.<int>([ 8, 0x4, 13 ]),
			Vector.<int>([ 8, 0x7, 14 ]),
			Vector.<int>([ 9, 0x18, 15 ]),
			Vector.<int>([ 10, 0x17, 16 ]),
			Vector.<int>([ 10, 0x18, 17 ]),
			Vector.<int>([ 10, 0x8, 18 ]),
			Vector.<int>([ 11, 0x67, 19 ]),
			Vector.<int>([ 11, 0x68, 20 ]),
			Vector.<int>([ 11, 0x6C, 21 ]),
			Vector.<int>([ 11, 0x37, 22 ]),
			Vector.<int>([ 11, 0x28, 23 ]),
			Vector.<int>([ 11, 0x17, 24 ]),
			Vector.<int>([ 11, 0x18, 25 ]),
			Vector.<int>([ 12, 0xCA, 26 ]),
			Vector.<int>([ 12, 0xCB, 27 ]),
			Vector.<int>([ 12, 0xCC, 28 ]),
			Vector.<int>([ 12, 0xCD, 29 ]),
			Vector.<int>([ 12, 0x68, 30 ]),
			Vector.<int>([ 12, 0x69, 31 ]),
			Vector.<int>([ 12, 0x6A, 32 ]),
			Vector.<int>([ 12, 0x6B, 33 ]),
			Vector.<int>([ 12, 0xD2, 34 ]),
			Vector.<int>([ 12, 0xD3, 35 ]),
			Vector.<int>([ 12, 0xD4, 36 ]),
			Vector.<int>([ 12, 0xD5, 37 ]),
			Vector.<int>([ 12, 0xD6, 38 ]),
			Vector.<int>([ 12, 0xD7, 39 ]),
			Vector.<int>([ 12, 0x6C, 40 ]),
			Vector.<int>([ 12, 0x6D, 41 ]),
			Vector.<int>([ 12, 0xDA, 42 ]),
			Vector.<int>([ 12, 0xDB, 43 ]),
			Vector.<int>([ 12, 0x54, 44 ]),
			Vector.<int>([ 12, 0x55, 45 ]),
			Vector.<int>([ 12, 0x56, 46 ]),
			Vector.<int>([ 12, 0x57, 47 ]),
			Vector.<int>([ 12, 0x64, 48 ]),
			Vector.<int>([ 12, 0x65, 49 ]),
			Vector.<int>([ 12, 0x52, 50 ]),
			Vector.<int>([ 12, 0x53, 51 ]),
			Vector.<int>([ 12, 0x24, 52 ]),
			Vector.<int>([ 12, 0x37, 53 ]),
			Vector.<int>([ 12, 0x38, 54 ]),
			Vector.<int>([ 12, 0x27, 55 ]),
			Vector.<int>([ 12, 0x28, 56 ]),
			Vector.<int>([ 12, 0x58, 57 ]),
			Vector.<int>([ 12, 0x59, 58 ]),
			Vector.<int>([ 12, 0x2B, 59 ]),
			Vector.<int>([ 12, 0x2C, 60 ]),
			Vector.<int>([ 12, 0x5A, 61 ]),
			Vector.<int>([ 12, 0x66, 62 ]),
			Vector.<int>([ 12, 0x67, 63 ]),
			Vector.<int>([ 10, 0xF, 64 ]),
			Vector.<int>([ 12, 0xC8, 128 ]),
			Vector.<int>([ 12, 0xC9, 192 ]),
			Vector.<int>([ 12, 0x5B, 256 ]),
			Vector.<int>([ 12, 0x33, 320 ]),
			Vector.<int>([ 12, 0x34, 384 ]),
			Vector.<int>([ 12, 0x35, 448 ]),
			Vector.<int>([ 13, 0x6C, 512 ]),
			Vector.<int>([ 13, 0x6D, 576 ]),
			Vector.<int>([ 13, 0x4A, 640 ]),
			Vector.<int>([ 13, 0x4B, 704 ]),
			Vector.<int>([ 13, 0x4C, 768 ]),
			Vector.<int>([ 13, 0x4D, 832 ]),
			Vector.<int>([ 13, 0x72, 896 ]),
			Vector.<int>([ 13, 0x73, 960 ]),
			Vector.<int>([ 13, 0x74, 1024 ]),
			Vector.<int>([ 13, 0x75, 1088 ]),
			Vector.<int>([ 13, 0x76, 1152 ]),
			Vector.<int>([ 13, 0x77, 1216 ]),
			Vector.<int>([ 13, 0x52, 1280 ]),
			Vector.<int>([ 13, 0x53, 1344 ]),
			Vector.<int>([ 13, 0x54, 1408 ]),
			Vector.<int>([ 13, 0x55, 1472 ]),
			Vector.<int>([ 13, 0x5A, 1536 ]),
			Vector.<int>([ 13, 0x5B, 1600 ]),
			Vector.<int>([ 13, 0x64, 1664 ]),
			Vector.<int>([ 13, 0x65, 1728 ]),
			Vector.<int>([ 11, 0x8, 1792 ]),
			Vector.<int>([ 11, 0xC, 1856 ]),
			Vector.<int>([ 11, 0xD, 1920 ]),
			Vector.<int>([ 12, 0x12, 1984 ]),
			Vector.<int>([ 12, 0x13, 2048 ]),
			Vector.<int>([ 12, 0x14, 2112 ]),
			Vector.<int>([ 12, 0x15, 2176 ]),
			Vector.<int>([ 12, 0x16, 2240 ]),
			Vector.<int>([ 12, 0x17, 2304 ]),
			Vector.<int>([ 12, 0x1C, 2368 ]),
			Vector.<int>([ 12, 0x1D, 2432 ]),
			Vector.<int>([ 12, 0x1E, 2496 ]),
			Vector.<int>([ 12, 0x1F, 2560 ]),
			Vector.<int>([ 12, 0x1, G3CODE_EOL ]),
			Vector.<int>([ 9, 0x1, G3CODE_INVALID ]),
			Vector.<int>([ 10, 0x1, G3CODE_INVALID ]),
			Vector.<int>([ 11, 0x1, G3CODE_INVALID ]),
			Vector.<int>([ 12, 0x0, G3CODE_INVALID ])
		]);
		
		private var msbmask: Vector.<int> = Vector.<int>([ 0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff ]);
		
		private static var oneruns: Vector.<int> = Vector.<int>([
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x00 - 0x0f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x10 - 0x1f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x20 - 0x2f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x30 - 0x3f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x40 - 0x4f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x50 - 0x5f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x60 - 0x6f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x70 - 0x7f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0x80 - 0x8f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0x90 - 0x9f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0xa0 - 0xaf */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0xb0 - 0xbf */
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,	/* 0xc0 - 0xcf */
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,	/* 0xd0 - 0xdf */
			3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,	/* 0xe0 - 0xef */
			4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 7, 8	/* 0xf0 - 0xff */
		]);
		
		private static var zeroruns: Vector.<int> = Vector.<int>([
			8, 7, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4,	/* 0x00 - 0x0f */
			3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,	/* 0x10 - 0x1f */
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,	/* 0x20 - 0x2f */
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,	/* 0x30 - 0x3f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0x40 - 0x4f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0x50 - 0x5f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0x60 - 0x6f */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0x70 - 0x7f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x80 - 0x8f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0x90 - 0x9f */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0xa0 - 0xaf */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0xb0 - 0xbf */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0xc0 - 0xcf */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0xd0 - 0xdf */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0xe0 - 0xef */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	/* 0xf0 - 0xff */
		]);
	}
}