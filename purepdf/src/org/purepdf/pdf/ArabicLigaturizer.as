/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ArabicLigaturizer.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/ArabicLigaturizer.as $
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
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.utils.StringUtils;

	public class ArabicLigaturizer
	{
		public static const DIGITS_MASK: int = 0xe0;
		public static const DIGIT_TYPE_MASK: int = 0x0100; // 0x3f00?
		public static const DIGITS_EN2AN: int = 0x20;
		public static const DIGITS_AN2EN: int = 0x40;
		public static const DIGITS_EN2AN_INIT_LR: int = 0x60;
		public static const DIGITS_EN2AN_INIT_AL: int = 0x80;
		public static const DIGIT_TYPE_AN: int = 0;
		public static const DIGIT_TYPE_AN_EXTENDED: int = 0x100;
		
		private static const ALEF: int = 0x0627;
		private static const ALEFHAMZA: int = 0x0623;
		private static const ALEFHAMZABELOW: int = 0x0625;
		private static const ALEFMADDA: int = 0x0622;
		private static const LAM: int = 0x0644;
		private static const HAMZA: int = 0x0621;
		private static const TATWEEL: int = 0x0640;
		private static const ZWJ: int = 0x200D;
		private static const HAMZAABOVE: int = 0x0654;
		private static const HAMZABELOW: int = 0x0655;
		private static const WAWHAMZA: int = 0x0624;
		private static const YEHHAMZA: int = 0x0626;
		private static const WAW: int = 0x0648;
		private static const ALEFMAKSURA: int = 0x0649;
		private static const YEH: int = 0x064A;
		private static const FARSIYEH: int = 0x06CC;
		private static const SHADDA: int = 0x0651;
		private static const KASRA: int = 0x0650;
		private static const FATHA: int = 0x064E;
		private static const DAMMA: int = 0x064F;
		private static const MADDA: int = 0x0653;
		private static const LAM_ALEF: int = 0xFEFB;
		private static const LAM_ALEFHAMZA: int = 0xFEF7;
		private static const LAM_ALEFHAMZABELOW: int = 0xFEF9;
		private static const LAM_ALEFMADDA: int = 0xFEF5;
		
		public static const AR_NOTHING: int  = 0x0;
		public static const AR_NOVOWEL: int = 0x1;
		public static const AR_COMPOSEDTASHKEEL: int = 0x4;
		public static const AR_LIG: int = 0x8;
		
		public function ArabicLigaturizer()
		{
		}
		
		private static const chartable: Vector.<Vector.<int>> = Vector.<Vector.<int>>([
			Vector.<int>([0x0621, 0xFE80]),
			Vector.<int>([0x0622, 0xFE81, 0xFE82]),
			Vector.<int>([0x0623, 0xFE83, 0xFE84]),
			Vector.<int>([0x0624, 0xFE85, 0xFE86]),
			Vector.<int>([0x0625, 0xFE87, 0xFE88]),
			Vector.<int>([0x0626, 0xFE89, 0xFE8A, 0xFE8B, 0xFE8C]),
			Vector.<int>([0x0627, 0xFE8D, 0xFE8E]),
			Vector.<int>([0x0628, 0xFE8F, 0xFE90, 0xFE91, 0xFE92]),
			Vector.<int>([0x0629, 0xFE93, 0xFE94]),
			Vector.<int>([0x062A, 0xFE95, 0xFE96, 0xFE97, 0xFE98]),
			Vector.<int>([0x062B, 0xFE99, 0xFE9A, 0xFE9B, 0xFE9C]),
			Vector.<int>([0x062C, 0xFE9D, 0xFE9E, 0xFE9F, 0xFEA0]),
			Vector.<int>([0x062D, 0xFEA1, 0xFEA2, 0xFEA3, 0xFEA4]),
			Vector.<int>([0x062E, 0xFEA5, 0xFEA6, 0xFEA7, 0xFEA8]), 
			Vector.<int>([0x062F, 0xFEA9, 0xFEAA]),
			Vector.<int>([0x0630, 0xFEAB, 0xFEAC]),
			Vector.<int>([0x0631, 0xFEAD, 0xFEAE]),
			Vector.<int>([0x0632, 0xFEAF, 0xFEB0]),
			Vector.<int>([0x0633, 0xFEB1, 0xFEB2, 0xFEB3, 0xFEB4]),
			Vector.<int>([0x0634, 0xFEB5, 0xFEB6, 0xFEB7, 0xFEB8]),
			Vector.<int>([0x0635, 0xFEB9, 0xFEBA, 0xFEBB, 0xFEBC]),
			Vector.<int>([0x0636, 0xFEBD, 0xFEBE, 0xFEBF, 0xFEC0]),
			Vector.<int>([0x0637, 0xFEC1, 0xFEC2, 0xFEC3, 0xFEC4]),
			Vector.<int>([0x0638, 0xFEC5, 0xFEC6, 0xFEC7, 0xFEC8]),
			Vector.<int>([0x0639, 0xFEC9, 0xFECA, 0xFECB, 0xFECC]),
			Vector.<int>([0x063A, 0xFECD, 0xFECE, 0xFECF, 0xFED0]),
			Vector.<int>([0x0640, 0x0640, 0x0640, 0x0640, 0x0640]),
			Vector.<int>([0x0641, 0xFED1, 0xFED2, 0xFED3, 0xFED4]),
			Vector.<int>([0x0642, 0xFED5, 0xFED6, 0xFED7, 0xFED8]),
			Vector.<int>([0x0643, 0xFED9, 0xFEDA, 0xFEDB, 0xFEDC]),
			Vector.<int>([0x0644, 0xFEDD, 0xFEDE, 0xFEDF, 0xFEE0]),
			Vector.<int>([0x0645, 0xFEE1, 0xFEE2, 0xFEE3, 0xFEE4]),
			Vector.<int>([0x0646, 0xFEE5, 0xFEE6, 0xFEE7, 0xFEE8]),
			Vector.<int>([0x0647, 0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC]),
			Vector.<int>([0x0648, 0xFEED, 0xFEEE]),
			Vector.<int>([0x0649, 0xFEEF, 0xFEF0, 0xFBE8, 0xFBE9]),
			Vector.<int>([0x064A, 0xFEF1, 0xFEF2, 0xFEF3, 0xFEF4]),
			Vector.<int>([0x0671, 0xFB50, 0xFB51]),
			Vector.<int>([0x0679, 0xFB66, 0xFB67, 0xFB68, 0xFB69]),
			Vector.<int>([0x067A, 0xFB5E, 0xFB5F, 0xFB60, 0xFB61]),
			Vector.<int>([0x067B, 0xFB52, 0xFB53, 0xFB54, 0xFB55]),
			Vector.<int>([0x067E, 0xFB56, 0xFB57, 0xFB58, 0xFB59]),
			Vector.<int>([0x067F, 0xFB62, 0xFB63, 0xFB64, 0xFB65]),
			Vector.<int>([0x0680, 0xFB5A, 0xFB5B, 0xFB5C, 0xFB5D]),
			Vector.<int>([0x0683, 0xFB76, 0xFB77, 0xFB78, 0xFB79]),
			Vector.<int>([0x0684, 0xFB72, 0xFB73, 0xFB74, 0xFB75]),
			Vector.<int>([0x0686, 0xFB7A, 0xFB7B, 0xFB7C, 0xFB7D]),
			Vector.<int>([0x0687, 0xFB7E, 0xFB7F, 0xFB80, 0xFB81]),
			Vector.<int>([0x0688, 0xFB88, 0xFB89]),
			Vector.<int>([0x068C, 0xFB84, 0xFB85]),
			Vector.<int>([0x068D, 0xFB82, 0xFB83]),
			Vector.<int>([0x068E, 0xFB86, 0xFB87]),
			Vector.<int>([0x0691, 0xFB8C, 0xFB8D]),
			Vector.<int>([0x0698, 0xFB8A, 0xFB8B]),
			Vector.<int>([0x06A4, 0xFB6A, 0xFB6B, 0xFB6C, 0xFB6D]),
			Vector.<int>([0x06A6, 0xFB6E, 0xFB6F, 0xFB70, 0xFB71]),
			Vector.<int>([0x06A9, 0xFB8E, 0xFB8F, 0xFB90, 0xFB91]),
			Vector.<int>([0x06AD, 0xFBD3, 0xFBD4, 0xFBD5, 0xFBD6]),
			Vector.<int>([0x06AF, 0xFB92, 0xFB93, 0xFB94, 0xFB95]),
			Vector.<int>([0x06B1, 0xFB9A, 0xFB9B, 0xFB9C, 0xFB9D]),
			Vector.<int>([0x06B3, 0xFB96, 0xFB97, 0xFB98, 0xFB99]),
			Vector.<int>([0x06BA, 0xFB9E, 0xFB9F]),
			Vector.<int>([0x06BB, 0xFBA0, 0xFBA1, 0xFBA2, 0xFBA3]),
			Vector.<int>([0x06BE, 0xFBAA, 0xFBAB, 0xFBAC, 0xFBAD]),
			Vector.<int>([0x06C0, 0xFBA4, 0xFBA5]),
			Vector.<int>([0x06C1, 0xFBA6, 0xFBA7, 0xFBA8, 0xFBA9]),
			Vector.<int>([0x06C5, 0xFBE0, 0xFBE1]),
			Vector.<int>([0x06C6, 0xFBD9, 0xFBDA]),
			Vector.<int>([0x06C7, 0xFBD7, 0xFBD8]),
			Vector.<int>([0x06C8, 0xFBDB, 0xFBDC]),
			Vector.<int>([0x06C9, 0xFBE2, 0xFBE3]),
			Vector.<int>([0x06CB, 0xFBDE, 0xFBDF]),
			Vector.<int>([0x06CC, 0xFBFC, 0xFBFD, 0xFBFE, 0xFBFF]),
			Vector.<int>([0x06D0, 0xFBE4, 0xFBE5, 0xFBE6, 0xFBE7]),
			Vector.<int>([0x06D2, 0xFBAE, 0xFBAF]),
			Vector.<int>([0x06D3, 0xFBB0, 0xFBB1])
		]);
		
		private static function isVowel( s: int ): Boolean
		{
			return ((s >= 0x064B) && (s <= 0x0655)) || (s == 0x0670);
		}
		
		private static function ligature( newchar: int, oldchar: charstruct ): int
		{
			var retval: int = 0;
			
			if (oldchar.basechar == 0)
				return 0;
			
			if (isVowel(newchar)) {
				retval = 1;
				if ((oldchar.vowel != 0) && (newchar != SHADDA)) {
					retval = 2;           /* we eliminate the old vowel .. */
				}
				switch (newchar) {
					case SHADDA:
						if (oldchar.mark1 == 0) {
							oldchar.mark1 = SHADDA;
						}
						else {
							return 0;         /* no ligature possible */
						}
						break;
					case HAMZABELOW:
						switch (oldchar.basechar) {
							case ALEF:
								oldchar.basechar = ALEFHAMZABELOW;
								retval = 2;
								break;
							case LAM_ALEF:
								oldchar.basechar = LAM_ALEFHAMZABELOW;
								retval = 2;
								break;
							default:
								oldchar.mark1 = HAMZABELOW;
								break;
						}
						break;
					case HAMZAABOVE:
						switch (oldchar.basechar) {
							case ALEF:
								oldchar.basechar = ALEFHAMZA;
								retval = 2;
								break;
							case LAM_ALEF:
								oldchar.basechar = LAM_ALEFHAMZA;
								retval = 2;
								break;
							case WAW:
								oldchar.basechar = WAWHAMZA;
								retval = 2;
								break;
							case YEH:
							case ALEFMAKSURA:
							case FARSIYEH:
								oldchar.basechar = YEHHAMZA;
								retval = 2;
								break;
							default:           /* whatever sense this may make .. */
								oldchar.mark1 = HAMZAABOVE;
								break;
						}
						break;
					case MADDA:
						switch (oldchar.basechar) {
							case ALEF:
								oldchar.basechar = ALEFMADDA;
								retval = 2;
								break;
						}
						break;
					default:
						oldchar.vowel = newchar;
						break;
				}
				if (retval == 1) {
					oldchar.lignum++;
				}
				return retval;
			}
			if (oldchar.vowel != 0) {  /* if we already joined a vowel, we can't join a Hamza */
				return 0;
			}
			
			switch (oldchar.basechar) {
				case LAM:
					switch (newchar) {
						case ALEF:
							oldchar.basechar = LAM_ALEF;
							oldchar.numshapes = 2;
							retval = 3;
							break;
						case ALEFHAMZA:
							oldchar.basechar = LAM_ALEFHAMZA;
							oldchar.numshapes = 2;
							retval = 3;
							break;
						case ALEFHAMZABELOW:
							oldchar.basechar = LAM_ALEFHAMZABELOW;
							oldchar.numshapes = 2;
							retval = 3;
							break;
						case ALEFMADDA:
							oldchar.basechar = LAM_ALEFMADDA;
							oldchar.numshapes = 2;
							retval = 3;
							break;
					}
					break;
				case 0:
					oldchar.basechar = newchar;
					oldchar.numshapes = shapecount(newchar);
					retval = 1;
					break;
			}
			return retval;
		}
		
		private static function shapecount( s: int ): int
		{
			var l: int, r: int, m: int;
			
			if ((s >= 0x0621) && (s <= 0x06D3) && !isVowel(s)) {
				l = 0;
				r = chartable.length - 1;
				while (l <= r) {
					m = (l + r) / 2;
					if (s == chartable[m][0]) {
						return chartable[m].length - 1;
					}
					else if (s < chartable[m][0]) {
						r = m - 1;
					}
					else {
						l = m + 1;
					}
				}
			}
			else if (s == ZWJ) {
				return 4;
			}
			return 1;
		}
		
		private static function shape( text: Vector.<int>, string: StringBuffer, level: int ): void
		{
			var join: int;
			var which: int;
			var nextletter: int;
			var p: int = 0;
			var oldchar: charstruct = new charstruct();
			var curchar: charstruct = new charstruct();
			var nc: int;
			
			while (p < text.length) 
			{
				nextletter = text[p++];
				join = ligature(nextletter, curchar);
				
				if (join == 0) {                       /* shape curchar */
					nc = shapecount(nextletter);
					if (nc == 1) {
						which = 0;        /* final or isolated */
					}
					else {
						which = 2;        /* medial or initial */
					}
					if (connects_to_left(oldchar)) {
						which++;
					}
					
					which = which % (curchar.numshapes);
					curchar.basechar = charshape(curchar.basechar, which);
					
					copycstostring(string, oldchar, level);
					oldchar = curchar;
					curchar = new charstruct();
					curchar.basechar = nextletter;
					curchar.numshapes = nc;
					curchar.lignum++;
				}
			}
			
			if (connects_to_left(oldchar))
				which = 1;
			else
				which = 0;
			which = which % (curchar.numshapes);
			curchar.basechar = charshape(curchar.basechar, which);
			
			copycstostring(string, oldchar, level);
			copycstostring(string, curchar, level);
		}
		
		private static function copycstostring( string: StringBuffer, s: charstruct, level: int ): void
		{
			if (s.basechar == 0)
				return;
			
			string.append(s.basechar);
			s.lignum--;
			if (s.mark1 != 0) {
				if ((level & AR_NOVOWEL) == 0) {
					string.append(s.mark1);
					s.lignum--;
				}
				else {
					s.lignum--;
				}
			}
			if (s.vowel != 0) {
				if ((level & AR_NOVOWEL) == 0) {
					string.append(s.vowel);
					s.lignum--;
				}
				else {
					s.lignum--;
				}
			}
		}
		
		private static function connects_to_left( a: charstruct ): Boolean
		{
			return a.numshapes > 2;
		}
		
		private static function charshape( s: int, which: int ): int
		{
			var l: int, r: int, m: int;
			if ((s >= 0x0621) && (s <= 0x06D3)) {
				l = 0;
				r = chartable.length - 1;
				while (l <= r) {
					m = (l + r) / 2;
					if (s == chartable[m][0]) {
						return chartable[m][which + 1];
					}
					else if (s < chartable[m][0]) {
						r = m - 1;
					}
					else {
						l = m + 1;
					}
				}
			}
			else if (s >= 0xfef5 && s <= 0xfefb)
				return (s + which);
			return s;
		}
		
		public static function arabic_shape( src: Vector.<int>, srcoffset: int, srclength: int, dest: Vector.<int>, destoffset: int, destlength: int, level: int ): int
		{
			var str: Vector.<int> = new Vector.<int>(srclength, true);
			for( var k: int = srclength + srcoffset - 1; k >= srcoffset; --k)
				str[k - srcoffset] = src[k];
			
			var string: StringBuffer = new StringBuffer("");
			shape(str, string, level);
			if ((level & (AR_COMPOSEDTASHKEEL | AR_LIG)) != 0)
			{
				//doublelig(string, level);
				trace('missing ligatures...');
			}
			
			var replacement: Vector.<int> = StringUtils.toCharArray( string.text );
			
			//dest.splice( destoffset, string.text.length );
			var index: int = 0;
			for( var a: int = 0; a < string.text.length; a++ )
			{
				dest[destoffset+a] = replacement[a];
			}
			
			return string.text.length;
		}

		static public function processNumbers( text: Vector.<int>, offset: int, length: int, options: int ): void
		{
			var limit: int = offset + length;
			var i: int;
			var ch: int;
			var digitTop: int;
			var digitDelta: int;
			var digitBase: int;

			if ( ( options & DIGITS_MASK ) != 0 )
			{
				digitBase = 48;

				switch ( options & DIGIT_TYPE_MASK )
				{
					case DIGIT_TYPE_AN:
						digitBase = 1632;
						break;
					case DIGIT_TYPE_AN_EXTENDED:
						digitBase = 1776;
						break;
					default:
						break;
				}

				switch ( options & DIGITS_MASK )
				{
					case DIGITS_EN2AN:
						digitDelta = digitBase - 48;
						for ( i = offset; i < limit; ++i )
						{
							ch = text[i];
							if ( ch <= 57 && ch >= 48 )
								text[i] += digitDelta;
						}
						break;
					
					case DIGITS_AN2EN:
						digitTop = ( digitBase + 9 );
						digitDelta = 48 - digitBase;

						for ( i = offset; i < limit; ++i )
						{
							ch = text[i];
							if ( ch <= digitTop && ch >= digitBase )
								text[i] += digitDelta;
						}
						break;
					
					case DIGITS_EN2AN_INIT_LR:
						throw new NonImplementatioError("DIGITS_EN2AN_INIT_LR not yet implemented");
						break;
					case DIGITS_EN2AN_INIT_AL:
						throw new NonImplementatioError("DIGITS_EN2AN_INIT_AL not yet implemented");
						break;
					default:
						break;
				}
			}
		}
	}
}

class charstruct {
	public var basechar: int;
	public var mark1: int;
	public var vowel: int;
	public var lignum: int;
	public var numshapes: int = 1;
};


class StringBuffer
{
	public var text: String;
	
	public function StringBuffer( s: String )
	{
		text = s;
	}
	
	public function append( value: int ): void
	{
		text += String.fromCharCode( value );
	}
}