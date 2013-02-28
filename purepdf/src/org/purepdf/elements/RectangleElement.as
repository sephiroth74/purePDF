/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: RectangleElement.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/RectangleElement.as $
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
package org.purepdf.elements
{
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.utils.assert_true;

	public class RectangleElement implements IElement
	{
		public static const BOTTOM: int = 2;
		public static const LEFT: int = 4;
		public static const NO_BORDER: int = 0;
		public static const RIGHT: int = 8;
		public static const TOP: int = 1;
		public static const ALL: int = TOP | BOTTOM | LEFT | RIGHT;
		public static const BOX: int = TOP + BOTTOM + LEFT + RIGHT;
		public static const UNDEFINED: int = -1;
		protected var _backgroundColor: RGBColor = null;
		protected var _border: int = UNDEFINED;
		protected var _borderColor: RGBColor = null;
		protected var _borderColorBottom: RGBColor = null;
		protected var _borderColorLeft: RGBColor = null;
		protected var _borderColorRight: RGBColor = null;
		protected var _borderColorTop: RGBColor = null;
		protected var _borderWidth: Number = UNDEFINED;
		protected var _borderWidthBottom: Number = UNDEFINED;
		protected var _borderWidthLeft: Number = UNDEFINED;
		protected var _borderWidthRight: Number = UNDEFINED;
		protected var _borderWidthTop: Number = UNDEFINED;
		protected var llx: Number;
		protected var lly: Number;
		protected var _rotation: int = 0;
		protected var urx: Number;
		protected var ury: Number;
		protected var _useVariableBorders: Boolean = false;

		public function RectangleElement( $llx: Number, $lly: Number, $urx: Number, $ury: Number )
		{
			llx = $llx;
			lly = $lly;
			urx = $urx;
			ury = $ury;
		}
		
		public function get useVariableBorders():Boolean
		{
			return _useVariableBorders;
		}

		public function process( listener: IElementListener ): Boolean
		{
			try 
			{
				return listener.addElement( this );
			}
			catch ( error: DocumentError ) {}
			return false;
		}

		public function cloneNonPositionParameters( rect: RectangleElement ): void
		{
			_rotation = rect._rotation;
			_backgroundColor = rect._backgroundColor;
			_border = rect._border;
			_useVariableBorders = rect._useVariableBorders;
			_borderWidth = rect._borderWidth;
			_borderWidthBottom = rect._borderWidthBottom;
			_borderWidthLeft = rect._borderWidthLeft;
			_borderWidthRight = rect._borderWidthRight;
			_borderWidthTop = rect._borderWidthTop;
			_borderColor = rect._borderColor;
			_borderColorBottom = rect._borderColorBottom;
			_borderColorLeft = rect._borderColorLeft;
			_borderColorRight = rect._borderColorRight;
			_borderColorTop = rect._borderColorTop;
		}
		
		/**
		 * Copies each of the parameters, except the position
		 */
		public function softCloneNonPositionParameters( rect: RectangleElement ): void
		{
			if (rect.rotation != 0)
				_rotation = rect.rotation;
			if (rect.backgroundColor != null)
				backgroundColor = rect.backgroundColor;
			if (rect.border != UNDEFINED)
				border = rect.border;
			if ( _useVariableBorders )
				_useVariableBorders = rect._useVariableBorders;
			if (rect.borderWidth != UNDEFINED)
				borderWidth = rect.borderWidth;
			if (rect.borderWidthLeft != UNDEFINED)
				borderWidthLeft = rect.borderWidthLeft;
			if (rect.borderWidthRight != UNDEFINED)
				borderWidthRight = rect.borderWidthRight;
			if (rect.borderWidthTop != UNDEFINED)
				borderWidthTop = rect.borderWidthTop;
			if (rect.borderWidthBottom != UNDEFINED)
				borderWidthBottom = rect.borderWidthBottom;
			if (rect.borderColor != null)
				borderColor = rect.borderColor;
			if (rect.borderColorLeft != null)
				borderColorLeft = rect.borderColorLeft;
			if (rect.borderColorRight != null)
				borderColorRight = rect.borderColorRight;
			if (rect.borderColorTop != null)
				borderColorTop = rect.borderColorTop;
			if (rect.borderColorBottom != null)
				borderColorBottom = rect.borderColorBottom;
		}

		public function disableBorderSide( side: int ): void
		{
			if ( _border == UNDEFINED )
				_border = 0;
			_border &= ~side;
		}

		public function enableBorderSide( side: int ): void
		{
			if ( _border == UNDEFINED )
				_border = 0;
			_border != side;
		}

		public function get backgroundColor(): RGBColor
		{
			return _backgroundColor;
		}

		public function get border(): int
		{
			return _border;
		}
		
		public function set border( value: int ): void
		{
			_border = value;
		}

		public function get borderColor(): RGBColor
		{
			return _borderColor;
		}
		
		public function set borderColor( value: RGBColor ): void
		{
			_borderColor = value;
		}

		public function get borderColorBottom(): RGBColor
		{
			if ( _borderColorBottom == null )
				return _borderColor;
			return _borderColorBottom;
		}

		public function get borderColorLeft(): RGBColor
		{
			if ( _borderColorLeft == null )
				return _borderColor;
			return _borderColorLeft;
		}

		public function get borderColorRight(): RGBColor
		{
			if ( _borderColorRight == null )
				return _borderColor;
			return _borderColorRight;
		}

		public function get borderColorTop(): RGBColor
		{
			if ( _borderColorTop == null )
				return _borderColor;
			return _borderColorTop;
		}

		public function get borderWidth(): Number
		{
			return _borderWidth;
		}
		
		public function set borderWidth( value: Number ): void
		{
			_borderWidth = value;
		}

		public function get borderWidthBottom(): Number
		{
			return getVariableBorderWidth( _borderWidthBottom, BOTTOM );
		}

		public function get borderWidthLeft(): Number
		{
			return getVariableBorderWidth( _borderWidthLeft, LEFT );
		}

		public function get borderWidthRight(): Number
		{
			return getVariableBorderWidth( _borderWidthRight, RIGHT );
		}

		public function get borderWidthTop(): Number
		{
			return getVariableBorderWidth( _borderWidthTop, TOP );
		}

		public function getBottom( margin: Number=0 ): Number
		{
			return lly + margin;
		}

		public function getChunks(): Vector.<Object>
		{
			return new Vector.<Object>();
		}

		public function get grayFill(): Number
		{
			if ( _backgroundColor is GrayColor )
				return GrayColor( _backgroundColor ).gray;
			return 0;
		}

		public function get height(): Number
		{
			return ury - lly;
		}

		public function getLeft( margin: Number=0 ): Number
		{
			return llx + margin;
		}

		public function getRight( margin: Number=0 ): Number
		{
			return urx - margin;
		}

		public function get rotation(): int
		{
			return _rotation;
		}

		public function getTop( margin: Number=0 ): Number
		{
			return ury - margin;
		}

		public function get width(): Number
		{
			return urx - llx;
		}

		public function hasBorder( borderType: int ): Boolean
		{
			if ( _border == UNDEFINED )
				return false;
			return ( _border & borderType ) == borderType;
		}

		public function hasBorders(): Boolean
		{
			switch ( _border )
			{
				case UNDEFINED:
				case NO_BORDER:
					return false;
				default:
					return _borderWidth > 0 || _borderWidthLeft > 0 || _borderWidthRight > 0 || _borderWidthTop > 0 || _borderWidthBottom
						> 0;
			}
		}

		public function get isNestable(): Boolean
		{
			return false;
		}

		public function get isContent(): Boolean
		{
			return true;
		}

		/**
		 * Normalizes the rectangle.
		 * Switches lower left with upper right if necessary.
		 */
		public function normalize(): void
		{
			var a: Number;

			if ( llx > urx )
			{
				a = llx;
				llx = urx;
				urx = a;
			}

			if ( lly > ury )
			{
				a = lly;
				lly = ury;
				ury = a;
			}
		}

		public function rectangle( top: Number, bottom: Number ): RectangleElement
		{
			var tmp: RectangleElement = RectangleElement.clone( this );

			if ( getTop() > top )
			{
				tmp.setTop( top );
				tmp.disableBorderSide( TOP );
			}

			if ( getBottom() < bottom )
			{
				tmp.setBottom( bottom );
				tmp.disableBorderSide( BOTTOM );
			}
			return tmp;
		}

		
		/**
		 * Return a new rotated RectangleElement ( rotation of the current
		 * rectangle plus the value passed )
		 * 
		 * @param value
		 * @return the rotated RectangleElement
		 * @throws ArgumentError if value is not eq to 0, 90, 180, 270
		 */
		public function rotate( value: uint = 90 ): RectangleElement
		{
			assert_true( value % 90 == 0 || [0,90,180,270].indexOf(value) < 0, "Allowed rotation parameter must be 0, 90, 180 or 270");
			var rect: RectangleElement = new RectangleElement( lly, llx, ury, urx );
			rect._rotation = _rotation + value;
			rect._rotation %= 360;
			return rect;
		}

		public function set backgroundColor( value: RGBColor ): void
		{
			_backgroundColor = value;
		}

		public function set borderColorLeft( value: RGBColor ): void
		{
			_borderColorLeft = value;
		}

		public function set borderColorRight( value: RGBColor ): void
		{
			_borderColorRight = value;
		}

		public function set borderColorTop( value: RGBColor ): void
		{
			_borderColorTop = value;
		}
		
		public function set borderColorBottom( value: RGBColor ): void
		{
			_borderColorBottom = value;
		}

		/**
		 * Enables/Disables the border on the specified sides.
		 * The border is specified as an integer bitwise combination of
		 * the constants: <CODE>LEFT, RIGHT, TOP, BOTTOM, ALL</CODE>.
		 * <p>Example:</p>
		 * <pre>rect.borderSides = RectangleElement.LEFT | RectangleElement.TOP;</pre>  
		 * 
		 * @see #enableBorderSide
		 * @see #disableBorderSide
		 */
		public function set borderSides( borderType: int ): void
		{
			_border = borderType;
		}

		public function set borderWidthBottom( value: Number ): void
		{
			_borderWidthBottom = value;
			updateBorderBasedOnWidth( _borderWidthBottom, BOTTOM );
		}

		public function set borderWidthLeft( value: Number ): void
		{
			_borderWidthLeft = value;
			updateBorderBasedOnWidth( _borderWidthLeft, LEFT );
		}

		public function set borderWidthRight( value: Number ): void
		{
			_borderWidthRight = value;
			updateBorderBasedOnWidth( _borderWidthRight, RIGHT );
		}

		public function set borderWidthTop( value: Number ): void
		{
			_borderWidthTop = value;
			updateBorderBasedOnWidth( _borderWidthTop, TOP );
		}

		public function setBottom( $lly: Number ): void
		{
			lly = $lly;
		}

		public function set grayFill( value: Number ): void
		{
			_backgroundColor = new GrayColor( value );
		}

		public function setLeft( $llx: Number ): void
		{
			llx = $llx;
		}

		public function setRight( $urx: Number ): void
		{
			urx = $urx;
		}

		public function setTop( $ury: Number ): void
		{
			ury = $ury;
		}

		public function toString(): String
		{
			var buf: String = "Rectangle: ";
			buf += width + "x";
			buf += height + " (rot: ";
			buf += _rotation + " degrees)";
			return buf;
		}

		public function get type(): int
		{
			return Element.RECTANGLE;
		}

		private function getVariableBorderWidth( variableWithValue: Number, side: int ): Number
		{
			if ( ( _border & side ) != 0 )
				return variableWithValue != UNDEFINED ? variableWithValue : _borderWidth;
			return 0;
		}

		private function updateBorderBasedOnWidth( width: Number, side: int ): void
		{
			_useVariableBorders = true;

			if ( width > 0 )
				enableBorderSide( side );
			else
				disableBorderSide( side );
		}

		public static function clone( other: RectangleElement ): RectangleElement
		{
			var tmp: RectangleElement = new RectangleElement( other.llx, other.lly, other.urx, other.ury );
			tmp.cloneNonPositionParameters( other );
			return tmp;
		}
	}
}