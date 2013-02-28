/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: CMYKColor.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/colors/CMYKColor.as $
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
	import org.purepdf.utils.FloatUtils;

	public class CMYKColor extends ExtendedColor
	{
		private static const serialVersionID: Number = 5940378778276468452;
		private var _black: Number;
		private var _cyan: Number;
		private var _magenta: Number;
		private var _yellow: Number;

		/**
		 * Construct a CMYK Color.
		 * @param floatCyan			Number bewteen 0 and 1
		 * @param floatMagenta		Number bewteen 0 and 1
		 * @param floatYellow		Number bewteen 0 and 1
		 * @param floatBlack		Number bewteen 0 and 1
		 */
		public function CMYKColor( floatCyan: Number, floatMagenta: Number, floatYellow: Number, floatBlack: Number )
		{
			super( TYPE_CMYK );
			setValue( normalize( 1 - floatCyan - floatBlack ) * 255, normalize( 1 - floatMagenta - floatBlack ) * 255, normalize( 1 - floatYellow -
							floatBlack ) * 255 );
			_cyan = normalize( floatCyan );
			_magenta = normalize( floatMagenta );
			_yellow = normalize( floatYellow );
			_black = normalize( floatBlack );
		}

		public function get black(): Number
		{
			return _black;
		}

		public function get cyan(): Number
		{
			return _cyan;
		}

		override public function equals( obj: Object ): Boolean
		{
			if ( !( obj is CMYKColor ) )
				return false;
			var c2: CMYKColor = CMYKColor( obj );
			return ( cyan == c2.cyan && magenta == c2.magenta && yellow == c2.yellow && black == c2.black );
		}

		override public function hashCode(): int
		{
			return FloatUtils.floatToIntBits( _cyan ) ^ FloatUtils.floatToIntBits( _magenta ) ^ FloatUtils.
							floatToIntBits( _yellow ) ^ FloatUtils.floatToIntBits( _black );
		}

		public function get magenta(): Number
		{
			return _magenta;
		}

		public function get yellow(): Number
		{
			return _yellow;
		}
	}
}