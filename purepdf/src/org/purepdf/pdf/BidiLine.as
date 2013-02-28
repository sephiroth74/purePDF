/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BidiLine.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/BidiLine.as $
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
	import org.purepdf.elements.Chunk;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.lang.Character;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.Utilities;
	import org.purepdf.utils.pdf_core;

	public class BidiLine
	{
		use namespace pdf_core;
		
		private static const mirrorChars: Object = { 0x0028: 0x0029, 0x0029: 0x0028, 0x003C: 0x003E, 0x003E: 0x003C, 0x005B: 0x005D,
							0x005D: 0x005B, 0x007B: 0x007D, 0x007D: 0x007B, 0x00AB: 0x00BB, 0x00BB: 0x00AB, 0x2039: 0x203A,
							0x203A: 0x2039, 0x2045: 0x2046, 0x2046: 0x2045, 0x207D: 0x207E, 0x207E: 0x207D, 0x208D: 0x208E,
							0x208E: 0x208D, 0x2208: 0x220B, 0x2209: 0x220C, 0x220A: 0x220D, 0x220B: 0x2208, 0x220C: 0x2209,
							0x220D: 0x220A, 0x2215: 0x29F5, 0x223C: 0x223D, 0x223D: 0x223C, 0x2243: 0x22CD, 0x2252: 0x2253,
							0x2253: 0x2252, 0x2254: 0x2255, 0x2255: 0x2254, 0x2264: 0x2265, 0x2265: 0x2264, 0x2266: 0x2267,
							0x2267: 0x2266, 0x2268: 0x2269, 0x2269: 0x2268, 0x226A: 0x226B, 0x226B: 0x226A, 0x226E: 0x226F,
							0x226F: 0x226E, 0x2270: 0x2271, 0x2271: 0x2270, 0x2272: 0x2273, 0x2273: 0x2272, 0x2274: 0x2275,
							0x2275: 0x2274, 0x2276: 0x2277, 0x2277: 0x2276, 0x2278: 0x2279, 0x2279: 0x2278, 0x227A: 0x227B,
							0x227B: 0x227A, 0x227C: 0x227D, 0x227D: 0x227C, 0x227E: 0x227F, 0x227F: 0x227E, 0x2280: 0x2281,
							0x2281: 0x2280, 0x2282: 0x2283, 0x2283: 0x2282, 0x2284: 0x2285, 0x2285: 0x2284, 0x2286: 0x2287,
							0x2287: 0x2286, 0x2288: 0x2289, 0x2289: 0x2288, 0x228A: 0x228B, 0x228B: 0x228A, 0x228F: 0x2290,
							0x2290: 0x228F, 0x2291: 0x2292, 0x2292: 0x2291, 0x2298: 0x29B8, 0x22A2: 0x22A3, 0x22A3: 0x22A2,
							0x22A6: 0x2ADE, 0x22A8: 0x2AE4, 0x22A9: 0x2AE3, 0x22AB: 0x2AE5, 0x22B0: 0x22B1, 0x22B1: 0x22B0,
							0x22B2: 0x22B3, 0x22B3: 0x22B2, 0x22B4: 0x22B5, 0x22B5: 0x22B4, 0x22B6: 0x22B7, 0x22B7: 0x22B6,
							0x22C9: 0x22CA, 0x22CA: 0x22C9, 0x22CB: 0x22CC, 0x22CC: 0x22CB, 0x22CD: 0x2243, 0x22D0: 0x22D1,
							0x22D1: 0x22D0, 0x22D6: 0x22D7, 0x22D7: 0x22D6, 0x22D8: 0x22D9, 0x22D9: 0x22D8, 0x22DA: 0x22DB,
							0x22DB: 0x22DA, 0x22DC: 0x22DD, 0x22DD: 0x22DC, 0x22DE: 0x22DF, 0x22DF: 0x22DE, 0x22E0: 0x22E1,
							0x22E1: 0x22E0, 0x22E2: 0x22E3, 0x22E3: 0x22E2, 0x22E4: 0x22E5, 0x22E5: 0x22E4, 0x22E6: 0x22E7,
							0x22E7: 0x22E6, 0x22E8: 0x22E9, 0x22E9: 0x22E8, 0x22EA: 0x22EB, 0x22EB: 0x22EA, 0x22EC: 0x22ED,
							0x22ED: 0x22EC, 0x22F0: 0x22F1, 0x22F1: 0x22F0, 0x22F2: 0x22FA, 0x22F3: 0x22FB, 0x22F4: 0x22FC,
							0x22F6: 0x22FD, 0x22F7: 0x22FE, 0x22FA: 0x22F2, 0x22FB: 0x22F3, 0x22FC: 0x22F4, 0x22FD: 0x22F6,
							0x22FE: 0x22F7, 0x2308: 0x2309, 0x2309: 0x2308, 0x230A: 0x230B, 0x230B: 0x230A, 0x2329: 0x232A,
							0x232A: 0x2329, 0x2768: 0x2769, 0x2769: 0x2768, 0x276A: 0x276B, 0x276B: 0x276A, 0x276C: 0x276D,
							0x276D: 0x276C, 0x276E: 0x276F, 0x276F: 0x276E, 0x2770: 0x2771, 0x2771: 0x2770, 0x2772: 0x2773,
							0x2773: 0x2772, 0x2774: 0x2775, 0x2775: 0x2774, 0x27D5: 0x27D6, 0x27D6: 0x27D5, 0x27DD: 0x27DE,
							0x27DE: 0x27DD, 0x27E2: 0x27E3, 0x27E3: 0x27E2, 0x27E4: 0x27E5, 0x27E5: 0x27E4, 0x27E6: 0x27E7,
							0x27E7: 0x27E6, 0x27E8: 0x27E9, 0x27E9: 0x27E8, 0x27EA: 0x27EB, 0x27EB: 0x27EA, 0x2983: 0x2984,
							0x2984: 0x2983, 0x2985: 0x2986, 0x2986: 0x2985, 0x2987: 0x2988, 0x2988: 0x2987, 0x2989: 0x298A,
							0x298A: 0x2989, 0x298B: 0x298C, 0x298C: 0x298B, 0x298D: 0x2990, 0x298E: 0x298F, 0x298F: 0x298E,
							0x2990: 0x298D, 0x2991: 0x2992, 0x2992: 0x2991, 0x2993: 0x2994, 0x2994: 0x2993, 0x2995: 0x2996,
							0x2996: 0x2995, 0x2997: 0x2998, 0x2998: 0x2997, 0x29B8: 0x2298, 0x29C0: 0x29C1, 0x29C1: 0x29C0,
							0x29C4: 0x29C5, 0x29C5: 0x29C4, 0x29CF: 0x29D0, 0x29D0: 0x29CF, 0x29D1: 0x29D2, 0x29D2: 0x29D1,
							0x29D4: 0x29D5, 0x29D5: 0x29D4, 0x29D8: 0x29D9, 0x29D9: 0x29D8, 0x29DA: 0x29DB, 0x29DB: 0x29DA,
							0x29F5: 0x2215, 0x29F8: 0x29F9, 0x29F9: 0x29F8, 0x29FC: 0x29FD, 0x29FD: 0x29FC, 0x2A2B: 0x2A2C,
							0x2A2C: 0x2A2B, 0x2A2D: 0x2A2C, 0x2A2E: 0x2A2D, 0x2A34: 0x2A35, 0x2A35: 0x2A34, 0x2A3C: 0x2A3D,
							0x2A3D: 0x2A3C, 0x2A64: 0x2A65, 0x2A65: 0x2A64, 0x2A79: 0x2A7A, 0x2A7A: 0x2A79, 0x2A7D: 0x2A7E,
							0x2A7E: 0x2A7D, 0x2A7F: 0x2A80, 0x2A80: 0x2A7F, 0x2A81: 0x2A82, 0x2A82: 0x2A81, 0x2A83: 0x2A84,
							0x2A84: 0x2A83, 0x2A8B: 0x2A8C, 0x2A8C: 0x2A8B, 0x2A91: 0x2A92, 0x2A92: 0x2A91, 0x2A93: 0x2A94,
							0x2A94: 0x2A93, 0x2A95: 0x2A96, 0x2A96: 0x2A95, 0x2A97: 0x2A98, 0x2A98: 0x2A97, 0x2A99: 0x2A9A,
							0x2A9A: 0x2A99, 0x2A9B: 0x2A9C, 0x2A9C: 0x2A9B, 0x2AA1: 0x2AA2, 0x2AA2: 0x2AA1, 0x2AA6: 0x2AA7,
							0x2AA7: 0x2AA6, 0x2AA8: 0x2AA9, 0x2AA9: 0x2AA8, 0x2AAA: 0x2AAB, 0x2AAB: 0x2AAA, 0x2AAC: 0x2AAD,
							0x2AAD: 0x2AAC, 0x2AAF: 0x2AB0, 0x2AB0: 0x2AAF, 0x2AB3: 0x2AB4, 0x2AB4: 0x2AB3, 0x2ABB: 0x2ABC,
							0x2ABC: 0x2ABB, 0x2ABD: 0x2ABE, 0x2ABE: 0x2ABD, 0x2ABF: 0x2AC0, 0x2AC0: 0x2ABF, 0x2AC1: 0x2AC2,
							0x2AC2: 0x2AC1, 0x2AC3: 0x2AC4, 0x2AC4: 0x2AC3, 0x2AC5: 0x2AC6, 0x2AC6: 0x2AC5, 0x2ACD: 0x2ACE,
							0x2ACE: 0x2ACD, 0x2ACF: 0x2AD0, 0x2AD0: 0x2ACF, 0x2AD1: 0x2AD2, 0x2AD2: 0x2AD1, 0x2AD3: 0x2AD4,
							0x2AD4: 0x2AD3, 0x2AD5: 0x2AD6, 0x2AD6: 0x2AD5, 0x2ADE: 0x22A6, 0x2AE3: 0x22A9, 0x2AE4: 0x22A8,
							0x2AE5: 0x22AB, 0x2AEC: 0x2AED, 0x2AED: 0x2AEC, 0x2AF7: 0x2AF8, 0x2AF8: 0x2AF7, 0x2AF9: 0x2AFA,
							0x2AFA: 0x2AF9, 0x3008: 0x3009, 0x3009: 0x3008, 0x300A: 0x300B, 0x300B: 0x300A, 0x300C: 0x300D,
							0x300D: 0x300C, 0x300E: 0x300F, 0x300F: 0x300E, 0x3010: 0x3011, 0x3011: 0x3010, 0x3014: 0x3015,
							0x3015: 0x3014, 0x3016: 0x3017, 0x3017: 0x3016, 0x3018: 0x3019, 0x3019: 0x3018, 0x301A: 0x301B,
							0x301B: 0x301A, 0xFF08: 0xFF09, 0xFF09: 0xFF08, 0xFF1C: 0xFF1E, 0xFF1E: 0xFF1C, 0xFF3B: 0xFF3D,
							0xFF3D: 0xFF3B, 0xFF5B: 0xFF5D, 0xFF5D: 0xFF5B, 0xFF5F: 0xFF60, 0xFF60: 0xFF5F, 0xFF62: 0xFF63,
							0xFF63: 0xFF62 };
		protected var arabicOptions: int;
		protected var chunks: Vector.<PdfChunk> = new Vector.<PdfChunk>();
		protected var currentChar: int = 0;
		protected var detailChunks: Vector.<PdfChunk> = new Vector.<PdfChunk>( pieceSize, true );
		protected var indexChars: Vector.<int> = new Vector.<int>( pieceSize, true );
		protected var indexChunk: int = 0;
		protected var indexChunkChar: int = 0;
		protected var orderLevels: Vector.<int> = new Vector.<int>( pieceSize, true );
		protected var pieceSize: int = 256;
		protected var runDirection: int;
		protected var shortStore: Boolean;
		protected var storedCurrentChar: int = 0;
		protected var storedDetailChunks: Vector.<PdfChunk> = new Vector.<PdfChunk>();
		protected var storedIndexChars: Vector.<int> = new Vector.<int>();
		protected var storedIndexChunk: int = 0;
		protected var storedIndexChunkChar: int = 0;
		protected var storedOrderLevels: Vector.<int> = new Vector.<int>();
		protected var storedRunDirection: int;
		protected var storedText: Vector.<int> = new Vector.<int>();
		protected var storedTotalTextLength: int = 0;
		protected var text: Vector.<int> = new Vector.<int>( pieceSize, true );
		protected var totalTextLength: int = 0;

		public function BidiLine()
		{
		}

		public function addChunk( chunk: PdfChunk ): void
		{
			chunks.push( chunk );
		}

		public function addPiece( c: int, chunk: PdfChunk ): void
		{
			if ( totalTextLength >= pieceSize )
			{
				var tempText: Vector.<int> = text;
				var tempDetailChunks: Vector.<PdfChunk> = detailChunks;
				pieceSize *= 2;
				text = tempText.concat();
				text.length = totalTextLength;
				detailChunks = tempDetailChunks.concat();
				detailChunks.length = totalTextLength;
			}
			text[totalTextLength] = c;
			detailChunks[totalTextLength++] = chunk;
		}
		
		public function reorder( start: int, end: int ): void
		{
			var maxLevel: int = orderLevels[start];
			var minLevel: int = maxLevel;
			var onlyOddLevels: int = maxLevel;
			var onlyEvenLevels: int = maxLevel;
			var k: int;
			var b: int;
			
			for ( k = start + 1; k <= end; ++k) {
				b = orderLevels[k];
				if (b > maxLevel)
					maxLevel = b;
				else if (b < minLevel)
					minLevel = b;
				onlyOddLevels &= b;
				onlyEvenLevels |= b;
			}
			if ((onlyEvenLevels & 1) == 0) // nothing to do
				return;
			if ((onlyOddLevels & 1) == 1) { // single inversion
				flip(start, end + 1);
				return;
			}
			
			var pstart: int;
			var pend: int;
			minLevel |= 1;
			for (; maxLevel >= minLevel; --maxLevel) {
				pstart = start;
				for (;;) {
					for (;pstart <= end; ++pstart) {
						if (orderLevels[pstart] >= maxLevel)
							break;
					}
					if (pstart > end)
						break;
					pend = pstart + 1;
					for (; pend <= end; ++pend) {
						if (orderLevels[pend] < maxLevel)
							break;
					}
					flip(pstart, pend);
					pstart = pend + 1;
				}
			}
		}
		
		public function flip( start: int, end: int ): void
		{
			var mid: int = (start + end) / 2;
			var temp: int;
			--end;
			for (; start < mid; ++start, --end) 
			{
				temp = indexChars[start];
				indexChars[start] = indexChars[end];
				indexChars[end] = temp;
			}
		}

		public function createArrayOfPdfChunks( startIdx: int, endIdx: int, extraPdfChunk: PdfChunk = null ): Vector.<PdfChunk>
		{
			var bidi: Boolean = ( runDirection == PdfWriter.RUN_DIRECTION_LTR || runDirection == PdfWriter.RUN_DIRECTION_RTL );

			if ( bidi )
				reorder(startIdx, endIdx);

			var ar: Vector.<PdfChunk> = new Vector.<PdfChunk>();
			var refCk: PdfChunk = detailChunks[startIdx];
			var ck: PdfChunk = null;
			var buf: String = "";
			var c: int;
			var idx: int = 0;

			for ( ; startIdx <= endIdx; ++startIdx )
			{
				idx = bidi ? indexChars[startIdx] : startIdx;
				c = text[idx];
				ck = detailChunks[idx];

				if ( PdfChunk.noPrint( ck.getUnicodeEquivalent( c ) ) )
					continue;

				if ( ck.isImage() || ck.isSeparator() || ck.isTab() )
				{
					if ( buf.length > 0 )
					{
						ar.push( PdfChunk.fromString( buf.toString(), refCk ) );
						buf = "";
					}
					ar.push( ck );
				} else if ( ck == refCk )
				{
					buf += String.fromCharCode( c );
				} else
				{
					if ( buf.length > 0 )
					{
						ar.push( PdfChunk.fromString( buf.toString(), refCk ) );
						buf = "";
					}

					if ( !ck.isImage() && !ck.isSeparator() && !ck.isTab() )
						buf += String.fromCharCode( c );
					refCk = ck;
				}
			}

			if ( buf.length > 0 )
				ar.push( PdfChunk.fromString( buf.toString(), refCk ) );

			if ( extraPdfChunk != null )
				ar.push( extraPdfChunk );
			return ar;
		}

		public function doArabicShapping(): void
		{
			var src: int = 0;
			var dest: int = 0;
			var c: int;
			var startArabicIdx: int;
			var arabicWordSize: int;
			var size: int;
			var k: int;

			for ( ; ;  )
			{
				while ( src < totalTextLength )
				{
					c = text[src];

					if ( c >= 0x0600 && c <= 0x06ff )
						break;

					if ( src != dest )
					{
						text[dest] = text[src];
						detailChunks[dest] = detailChunks[src];
						orderLevels[dest] = orderLevels[src];
					}
					++src;
					++dest;
				}

				if ( src >= totalTextLength )
				{
					totalTextLength = dest;
					return;
				}
				startArabicIdx = src;
				++src;

				while ( src < totalTextLength )
				{
					c = text[src];

					if ( c < 0x0600 || c > 0x06ff )
						break;
					++src;
				}
				arabicWordSize = src - startArabicIdx;
				
				text.fixed = false;
				size = ArabicLigaturizer.arabic_shape( text, startArabicIdx, arabicWordSize, text, dest, arabicWordSize, arabicOptions );
				text.fixed = true;

				if ( startArabicIdx != dest )
				{
					for ( k = 0; k < size; ++k )
					{
						detailChunks[dest] = detailChunks[startArabicIdx];
						orderLevels[dest++] = orderLevels[startArabicIdx++];
					}
				} else
				{
					dest += size;
				}
			}
		}

		public function getParagraph( $runDirection: int ): Boolean
		{
			runDirection = $runDirection;
			currentChar = 0;
			totalTextLength = 0;
			var hasText: Boolean = false;
			var c: int;
			var uniC: int;
			var bf: BaseFont;
			var k: int;

			for ( ; indexChunk < chunks.length; ++indexChunk )
			{
				var ck: PdfChunk = chunks[indexChunk];
				bf = ck.font.font;
				var s: String = ck.toString();
				var len: int = s.length;

				for ( ; indexChunkChar < len; ++indexChunkChar )
				{
					c = s.charCodeAt( indexChunkChar );
					uniC = bf.getUnicodeEquivalent( c );

					if ( uniC == 13 || uniC == 10 )
					{
						if ( uniC == 13 && indexChunkChar + 1 < len && s.charCodeAt( indexChunkChar + 1 ) == 10 )
							++indexChunkChar;
						++indexChunkChar;

						if ( indexChunkChar >= len )
						{
							indexChunkChar = 0;
							++indexChunk;
						}
						hasText = true;

						if ( totalTextLength == 0 )
							detailChunks[0] = ck;
						break;
					}
					addPiece( c, ck );
				}

				if ( hasText )
					break;
				indexChunkChar = 0;
			}

			if ( totalTextLength == 0 )
				return hasText;
			// remove trailing WS
			totalTextLength = trimRight( 0, totalTextLength - 1 ) + 1;

			if ( totalTextLength == 0 )
			{
				return true;
			}

			if ( runDirection == PdfWriter.RUN_DIRECTION_LTR || runDirection == PdfWriter.RUN_DIRECTION_RTL )
			{
				if ( orderLevels.length < totalTextLength )
				{
					orderLevels = new Vector.<int>( pieceSize, true );
					indexChars = new Vector.<int>( pieceSize, true );
				}
				
				ArabicLigaturizer.processNumbers( text, 0, totalTextLength, arabicOptions );
				var order: BidiOrder = new BidiOrder();
				order.create( text, 0, totalTextLength, ( runDirection == PdfWriter.RUN_DIRECTION_RTL ? 1 : 0 ) );
				var od: Vector.<int> = order.getLevel();

				for ( k = 0; k < totalTextLength; ++k )
				{
					orderLevels[k] = od[k];
					indexChars[k] = k;
				}
				doArabicShapping();
				mirrorGlyphs();
			}
			totalTextLength = trimRightEx( 0, totalTextLength - 1 ) + 1;
			return true;
		}

		/**
		 * Gets the width of a range of characters
		 */
		public function getWidth( startIdx: int, lastIdx: int ): Number
		{
			var c: int = 0;
			var uniC: int;
			var ck: PdfChunk = null;
			var width: Number = 0;

			for ( ; startIdx <= lastIdx; ++startIdx )
			{
				var surrogate: Boolean = Utilities.isSurrogatePair( text, startIdx );

				if ( surrogate )
				{
					width += detailChunks[startIdx].getCharWidth( Utilities.convertToUtf32_3( text, startIdx ) );
					++startIdx;
				} else
				{
					c = text[startIdx];
					ck = detailChunks[startIdx];

					if ( PdfChunk.noPrint( ck.getUnicodeEquivalent( c ) ) )
						continue;
					width += detailChunks[startIdx].getCharWidth( c );
				}
			}
			return width;
		}

		public function get isEmpty(): Boolean
		{
			return ( currentChar >= totalTextLength && indexChunk >= chunks.length );
		}

		public function mirrorGlyphs(): void
		{
			var mirror: int;

			for ( var k: int = 0; k < totalTextLength; ++k )
			{
				if ( ( orderLevels[k] & 1 ) == 1 )
				{
					mirror = mirrorChars[text[k]];

					if ( mirror != 0 )
						text[k] = mirror;
				}
			}
		}

		public function processLine( leftX: Number, width: Number, alignment: int, runDirection: int, $arabicOptions: int ): PdfLine
		{
			arabicOptions = $arabicOptions;
			save();
			var isRTL: Boolean = ( runDirection == PdfWriter.RUN_DIRECTION_RTL );
			var ck: PdfChunk;

			if ( currentChar >= totalTextLength )
			{
				var hasText: Boolean = getParagraph( runDirection );

				if ( !hasText )
					return null;

				if ( totalTextLength == 0 )
				{
					var ar: Vector.<PdfChunk> = new Vector.<PdfChunk>();
					ck = PdfChunk.fromString( "", detailChunks[0] );
					ar.push( ck );
					return PdfLine.create( 0, 0, 0, alignment, true, ar, isRTL );
				}
			}
			var originalWidth: Number = width;
			var lastSplit: int = -1;

			if ( currentChar != 0 )
				currentChar = trimLeftEx( currentChar, totalTextLength - 1 );
			var oldCurrentChar: int = currentChar;
			var uniC: int = 0;
			ck = null;
			var charWidth: Number = 0;
			var lastValidChunk: PdfChunk = null;
			var splitChar: Boolean = false;
			var surrogate: Boolean = false;

			for ( ; currentChar < totalTextLength; ++currentChar )
			{
				ck = detailChunks[currentChar];
				surrogate = Utilities.isSurrogatePair( text, currentChar );

				if ( surrogate )
					uniC = ck.getUnicodeEquivalent( Utilities.convertToUtf32_3( text, currentChar ) );
				else
					uniC = ck.getUnicodeEquivalent( text[currentChar] );

				if ( PdfChunk.noPrint( uniC ) )
					continue;

				if ( surrogate )
					charWidth = ck.getCharWidth( uniC );
				else
					charWidth = ck.getCharWidth( text[currentChar] );
				splitChar = ck.isExtSplitCharacter( oldCurrentChar, currentChar, totalTextLength, text, detailChunks );

				if ( splitChar && Character.isWhitespace( uniC ) )
				{
					//throw new NonImplementatioError();
					lastSplit = currentChar;
				}

				if ( width - charWidth < 0 )
					break;

				if ( splitChar )
					lastSplit = currentChar;
				width -= charWidth;
				lastValidChunk = ck;

				if ( ck.isTab() )
				{
					var tab: Vector.<Object> = ck.getAttribute( Chunk.TAB ) as Vector.<Object>;
					var tabPosition: Number = Number( tab[1] );
					var newLine: Boolean = tab[2];

					if ( newLine && tabPosition < originalWidth - width )
					{
						return PdfLine.create( 0, originalWidth, width, alignment, true, createArrayOfPdfChunks( oldCurrentChar,
										currentChar - 1 ), isRTL );
					}
					detailChunks[currentChar].adjustLeft( leftX );
					width = originalWidth - tabPosition;
				}

				if ( surrogate )
					++currentChar;
			}

			if ( lastValidChunk == null )
			{
				++currentChar;

				if ( surrogate )
					++currentChar;
				return PdfLine.create( 0, originalWidth, 0, alignment, false, createArrayOfPdfChunks( currentChar - 1, currentChar -
								1 ), isRTL );
			}

			if ( currentChar >= totalTextLength )
				return PdfLine.create( 0, originalWidth, width, alignment, true, createArrayOfPdfChunks( oldCurrentChar,
								totalTextLength - 1 ), isRTL );
			var newCurrentChar: int = trimRightEx( oldCurrentChar, currentChar - 1 );

			if ( newCurrentChar < oldCurrentChar )
				return PdfLine.create( 0, originalWidth, width, alignment, false, createArrayOfPdfChunks( oldCurrentChar,
								currentChar - 1 ), isRTL );

			if ( newCurrentChar == currentChar - 1 )
			{
				var he: Object = lastValidChunk.getAttribute( Chunk.HYPHENATION );

				if ( he != null )
				{
					throw new NonImplementatioError();
				}
			}

			if ( lastSplit == -1 || lastSplit >= newCurrentChar )
				return PdfLine.create( 0, originalWidth, width + getWidth( newCurrentChar + 1, currentChar - 1 ), alignment, false,
								createArrayOfPdfChunks( oldCurrentChar, newCurrentChar ), isRTL );
			currentChar = lastSplit + 1;
			newCurrentChar = trimRightEx( oldCurrentChar, lastSplit );

			if ( newCurrentChar < oldCurrentChar )
				newCurrentChar = currentChar - 1;
			return PdfLine.create( 0, originalWidth, originalWidth - getWidth( oldCurrentChar, newCurrentChar ), alignment, false,
							createArrayOfPdfChunks( oldCurrentChar, newCurrentChar ), isRTL );
		}

		public function restore(): void
		{
			runDirection = storedRunDirection;
			totalTextLength = storedTotalTextLength;
			indexChunk = storedIndexChunk;
			indexChunkChar = storedIndexChunkChar;
			currentChar = storedCurrentChar;

			if ( !shortStore )
			{
				text = storedText.concat();
				text.length = totalTextLength;
				detailChunks = storedDetailChunks.concat();
				detailChunks.length = totalTextLength;
			}

			if ( runDirection == PdfWriter.RUN_DIRECTION_LTR || runDirection == PdfWriter.RUN_DIRECTION_RTL )
			{
				throw new NonImplementatioError();
			}
		}

		public function save(): void
		{
			if ( indexChunk > 0 )
			{
				if ( indexChunk >= chunks.length )
				{
					chunks.length = 0;
				} else
				{
					for ( --indexChunk; indexChunk >= 0; --indexChunk )
						chunks.splice( indexChunk, 1 );
				}
				indexChunk = 0;
			}
			storedRunDirection = runDirection;
			storedTotalTextLength = totalTextLength;
			storedIndexChunk = indexChunk;
			storedIndexChunkChar = indexChunkChar;
			storedCurrentChar = currentChar;
			shortStore = ( currentChar < totalTextLength );

			if ( !shortStore )
			{
				if ( storedText.length < totalTextLength )
				{
					storedText = new Vector.<int>( totalTextLength );
					storedDetailChunks = new Vector.<PdfChunk>( totalTextLength );
				}
				storedText = text.concat();
				storedDetailChunks = detailChunks.concat();
				storedText.length = totalTextLength;
				storedDetailChunks.length = totalTextLength;
			}

			if ( runDirection == PdfWriter.RUN_DIRECTION_LTR || runDirection == PdfWriter.RUN_DIRECTION_RTL )
			{
				throw new NonImplementatioError();
			}
		}

		public function trimLeft( startIdx: int, endIdx: int ): int
		{
			var idx: int = startIdx;
			var c: int;

			for ( ; idx <= endIdx; ++idx )
			{
				c = detailChunks[idx].getUnicodeEquivalent( text[idx] );

				if ( !isWS( c ) )
					break;
			}
			return idx;
		}

		public function trimLeftEx( startIdx: int, endIdx: int ): int
		{
			var idx: int = startIdx;
			var c: int = 0;

			for ( ; idx <= endIdx; ++idx )
			{
				c = detailChunks[idx].getUnicodeEquivalent( text[idx] );

				if ( !isWS( c ) && !PdfChunk.noPrint( c ) )
					break;
			}
			return idx;
		}

		public function trimRight( startIdx: int, endIdx: int ): int
		{
			var idx: int = endIdx;
			var c: int;

			for ( ; idx >= startIdx; --idx )
			{
				c = detailChunks[idx].getUnicodeEquivalent( text[idx] );

				if ( !isWS( c ) )
					break;
			}
			return idx;
		}

		public function trimRightEx( startIdx: int, endIdx: int ): int
		{
			var idx: int = endIdx;
			var c: int = 0;

			for ( ; idx >= startIdx; --idx )
			{
				c = detailChunks[idx].getUnicodeEquivalent( text[idx] );

				if ( !isWS( c ) && !PdfChunk.noPrint( c ) )
					break;
			}
			return idx;
		}

		static public function fromBidiLine( org: BidiLine ): BidiLine
		{
			var result: BidiLine = new BidiLine();
			result.runDirection = org.runDirection;
			result.pieceSize = org.pieceSize;
			result.text = org.text.concat();
			result.detailChunks = org.detailChunks.concat();
			result.totalTextLength = org.totalTextLength;
			result.orderLevels = org.orderLevels.concat();
			result.indexChars = org.indexChars.concat();
			result.chunks = org.chunks.concat();
			result.indexChunk = org.indexChunk;
			result.indexChunkChar = org.indexChunkChar;
			result.currentChar = org.currentChar;
			result.storedRunDirection = org.storedRunDirection;
			result.storedText = org.storedText.concat();
			result.storedDetailChunks = org.storedDetailChunks.concat();
			result.storedTotalTextLength = org.storedTotalTextLength;
			result.storedOrderLevels = org.storedOrderLevels.concat();
			result.storedIndexChars = org.storedIndexChars.concat();
			result.storedIndexChunk = org.storedIndexChunk;
			result.storedIndexChunkChar = org.storedIndexChunkChar;
			result.storedCurrentChar = org.storedCurrentChar;
			result.shortStore = org.shortStore;
			result.arabicOptions = org.arabicOptions;
			return result;
		}

		static public function isWS( c: int ): Boolean
		{
			return c <= 32;
		}
	}
}