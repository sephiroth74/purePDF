/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: GreekAlphabetFactory.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/factories/GreekAlphabetFactory.as $
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
package org.purepdf.factories
{
	import org.purepdf.lang.SpecialSymbol;

	public class GreekAlphabetFactory
	{
		static public function getLowerCaseString( index: int ): String
		{
			return getStringAtIndex( index );
		}

		static public function getString( index: int, lowercase: Boolean ): String
		{
			if ( index < 1 )
				return "";
			index--;
			var bytes: int = 1;
			var start: int = 0;
			var symbols: int = 24;

			while ( index >= symbols + start )
			{
				bytes++;
				start += symbols;
				symbols *= 24;
			}
			var c: int = index - start;
			var value: Vector.<String> = new Vector.<String>( bytes, true );
			var tmp: int;

			while ( bytes > 0 )
			{
				bytes--;
				
				tmp = c % 24;
				if( tmp > 16 )
					tmp++;
				tmp += lowercase ? 945 : 913;
				value[bytes] = SpecialSymbol.getCorrespondingSymbol( tmp );				
				c /= 24;
			}
			return value.join( "" );
		}

		static public function getStringAtIndex( index: int ): String
		{
			return getString( index, true );
		}

		static public function getUpperCaseString( index: int ): String
		{
			return getStringAtIndex( index ).toUpperCase();
		}
	}
}