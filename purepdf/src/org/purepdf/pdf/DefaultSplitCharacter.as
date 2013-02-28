/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: DefaultSplitCharacter.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/DefaultSplitCharacter.as $
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
	import org.purepdf.ISplitCharacter;
	
	public class DefaultSplitCharacter implements ISplitCharacter
	{
		public static const DEFAULT: ISplitCharacter = new DefaultSplitCharacter();
		
		public function DefaultSplitCharacter()
		{
		}
		
		public function isSplitCharacter( start: int, current: int, end: int, cc: Vector.<int>, ck: Vector.<PdfChunk> ): Boolean
		{
			var c: int = getCurrentCharacter( current, cc, ck );
			if (c <= ' '.charCodeAt(0) || c == '-'.charCodeAt(0) || c == 8208 /*'\u2010'*/ )
				return true;
			
			if( c < 0x2002 )
				return false;
			
			return ((c >= 0x2002 && c <= 0x200b)
				|| (c >= 0x2e80 && c < 0xd7a0)
				|| (c >= 0xf900 && c < 0xfb00)
				|| (c >= 0xfe30 && c < 0xfe50)
				|| (c >= 0xff61 && c < 0xffa0));
		}
		
		/**
		 * Returns the current character
		 * @param current current position in the array
		 * @param	cc		the character array that has to be checked
		 * @param ck chunk array
		 * @return	the current character
		 */
		protected function getCurrentCharacter( current: int, cc: Vector.<int>, ck: Vector.<PdfChunk> ): int
		{
			if( ck == null ) 
				return cc[current];
			
			return ck[ Math.min(current, ck.length - 1) ].getUnicodeEquivalent( cc[current] );
		}
	}
}