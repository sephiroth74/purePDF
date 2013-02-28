/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: SpecialSymbol.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/lang/SpecialSymbol.as $
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
package org.purepdf.lang
{
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;

	public class SpecialSymbol
	{
		static public function getChunk( c: int, font: Font ): Chunk
		{
			var greek: String = getCorrespondingSymbol( c );

			if ( greek == ' ' )
			{
				return new Chunk( String.fromCharCode(c), font );
			}
			var symbol: Font = new Font( Font.SYMBOL, font.size, font.style, font.color );
			var s: String = greek;
			return new Chunk( s, symbol );
		}

		static public function getCorrespondingSymbol( c: int ): String
		{
			switch ( c )
			{
				case 913:
					return 'A'; // ALFA
				case 914:
					return 'B'; // BETA
				case 915:
					return 'G'; // GAMMA
				case 916:
					return 'D'; // DELTA
				case 917:
					return 'E'; // EPSILON
				case 918:
					return 'Z'; // ZETA
				case 919:
					return 'H'; // ETA
				case 920:
					return 'Q'; // THETA
				case 921:
					return 'I'; // IOTA
				case 922:
					return 'K'; // KAPPA
				case 923:
					return 'L'; // LAMBDA
				case 924:
					return 'M'; // MU
				case 925:
					return 'N'; // NU
				case 926:
					return 'X'; // XI
				case 927:
					return 'O'; // OMICRON
				case 928:
					return 'P'; // PI
				case 929:
					return 'R'; // RHO
				case 931:
					return 'S'; // SIGMA
				case 932:
					return 'T'; // TAU
				case 933:
					return 'U'; // UPSILON
				case 934:
					return 'F'; // PHI
				case 935:
					return 'C'; // CHI
				case 936:
					return 'Y'; // PSI
				case 937:
					return 'W'; // OMEGA
				case 945:
					return 'a'; // alfa
				case 946:
					return 'b'; // beta
				case 947:
					return 'g'; // gamma
				case 948:
					return 'd'; // delta
				case 949:
					return 'e'; // epsilon
				case 950:
					return 'z'; // zeta
				case 951:
					return 'h'; // eta
				case 952:
					return 'q'; // theta
				case 953:
					return 'i'; // iota
				case 954:
					return 'k'; // kappa
				case 955:
					return 'l'; // lambda
				case 956:
					return 'm'; // mu
				case 957:
					return 'n'; // nu
				case 958:
					return 'x'; // xi
				case 959:
					return 'o'; // omicron
				case 960:
					return 'p'; // pi
				case 961:
					return 'r'; // rho
				case 962:
					return 'V'; // sigma
				case 963:
					return 's'; // sigma
				case 964:
					return 't'; // tau
				case 965:
					return 'u'; // upsilon
				case 966:
					return 'f'; // phi
				case 967:
					return 'c'; // chi
				case 968:
					return 'y'; // psi
				case 969:
					return 'w'; // omega
				default:
					return ' ';
			}
		}

		static public function index( string: String ): int
		{
			var length: int = string.length;

			for ( var i: int = 0; i < length; i++ )
			{
				if ( getCorrespondingSymbol( string.charCodeAt( i ) ) != ' ' )
				{
					return i;
				}
			}
			return -1;
		}
	}
}