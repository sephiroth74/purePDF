/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: RGBColor.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/colors/RGBColor.as $
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
package org.purepdf.colors
{
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.utils.assert_true;

	public class RGBColor extends ObjectHash
	{
		private static const FACTOR: Number = 0.7;
		
		public static const BLACK: RGBColor =       new RGBColor( 0, 0, 0 );
		public static const BLUE: RGBColor =        new RGBColor( 0, 0, 255 );
		public static const CYAN: RGBColor =        new RGBColor( 0, 255, 255 );
		public static const DARK_GRAY: RGBColor =   new RGBColor( 64, 64, 64 );
		public static const GRAY: RGBColor =        new RGBColor( 128, 128, 128 );
		public static const GREEN: RGBColor =       new RGBColor( 0, 255, 0 );
		public static const LIGHT_GRAY: RGBColor =  new RGBColor( 192, 192, 192 );
		public static const MAGENTA: RGBColor =     new RGBColor( 255, 0, 255 );
		public static const ORANGE: RGBColor =      new RGBColor( 255, 200, 0 );
		public static const PINK: RGBColor =        new RGBColor( 255, 175, 175 );
		public static const RED: RGBColor =         new RGBColor( 255, 0, 0 );
		public static const WHITE: RGBColor =       new RGBColor( 255, 255, 255 );
		public static const YELLOW: RGBColor =      new RGBColor( 255, 255, 0 );
		private var value: int;

		/**
		 * 
		 * @param red	an int value between 0 and 255
		 * @param green	an int value between 0 and 255
		 * @param blue	an int value between 0 and 255
		 * @param alpha	an int value between 0 and 255
		 */
		public function RGBColor( red: int=0, green: int=0, blue: int=0, alpha: int=255 )
		{
			setValue( red, green, blue, alpha );
		}
		
		public function darker(): RGBColor
		{
			return new RGBColor( Math.max( (red * FACTOR), 0), 
				Math.max( (green * FACTOR), 0),
				Math.max( (blue * FACTOR), 0) );
		}
		
		override public function hashCode(): int
		{
			return value;
		}

		public function get alpha(): int
		{
			return ( value >> 24 ) & 0xFF;
		}

		public function get blue(): int
		{
			return ( value >> 0 ) & 0xFF;
		}

		override public function equals( obj: Object ): Boolean
		{
			return obj is RGBColor && ( obj as RGBColor ).rgb == rgb;
		}

		public function get green(): int
		{
			return ( value >> 8 ) & 0xFF;
		}

		public function get red(): int
		{
			return ( value >> 16 ) & 0xFF;
		}

		public function get rgb(): int
		{
			return value;
		}

		public function setValue( red: int=0, green: int=0, blue: int=0, alpha: int=255 ): void
		{
			validate( red );
			validate( green );
			validate( blue );
			validate( alpha );
			value = ( ( alpha & 0xFF ) << 24 ) | ( ( red & 0xFF ) << 16 ) | ( ( green & 0xFF ) << 8 ) | ( ( blue & 0xFF ) << 0 );
		}

		public function validate( color: int ): void
		{
			assert_true( color >= 0 && color <= 255, "Color outside range 0 < 255" );
		}

		public static function fromARGB( value: int ): RGBColor
		{
			var c: RGBColor = new RGBColor();
			c.value = value;
			return c;
		}
	}
}