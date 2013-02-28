/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FloatUtils.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/utils/FloatUtils.as $
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
package org.purepdf.utils
{
	public class FloatUtils
	{
		private static const EXP_BIT_MASK: int = 2139095040;
		private static const SIGNIF_BIT_MASK: int = 8388607;
		
		/**
		 * Returns a representation of the specified floating-point value
		 * according to the IEEE 754 floating-point "single format" bit
		 * layout.
	 	 */
		public static function floatToIntBits( value: Number ): int
		{
			var result: int = AlchemyUtils.getLib().floatToRawIntBits( value );

			if ( ( ( result & EXP_BIT_MASK ) == EXP_BIT_MASK ) && ( result & SIGNIF_BIT_MASK ) != 0 )
				result = 0x7fc00000;
			return result;
		}
		
		public static function intBitsToFloat( value: int ): Number
		{
			var result: Number = AlchemyUtils.getLib().intBitsToFloat( value );
			return result;
		}
	}
}