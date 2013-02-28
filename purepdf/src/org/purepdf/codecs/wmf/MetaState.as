/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: MetaState.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/codecs/wmf/MetaState.as $
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
package org.purepdf.codecs.wmf
{
	import flash.display.JointStyle;
	import flash.geom.Point;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;

	public class MetaState
	{

		public static const ALTERNATE: int = 1;
		public static const OPAQUE: int = 2;
		public static const TA_BASELINE: int = 24;
		public static const TA_BOTTOM: int = 8;
		public static const TA_CENTER: int = 6;
		public static const TA_LEFT: int = 0;
		public static const TA_NOUPDATECP: int = 0;
		public static const TA_RIGHT: int = 2;
		public static const TA_TOP: int = 0;
		public static const TA_UPDATECP: int = 1;
		public static const TRANSPARENT: int = 1;
		public static const WINDING: int = 2;

		public var metaObjects: Vector.<MetaObject>;
		public var backgroundMode: int = OPAQUE;
		public var currentBackgroundColor: RGBColor = RGBColor.WHITE;
		public var currentBrush: MetaBrush;
		public var currentFont: MetaFont;
		public var currentPen: MetaPen;
		public var currentPoint: Point;
		public var currentTextColor: RGBColor = RGBColor.BLACK;
		public var extentWx: int;
		public var extentWy: int;
		public var lineJoin: int = 1;
		public var offsetWx: int;
		public var offsetWy: int;
		public var polyFillMode: int = ALTERNATE;

		public var savedStates: Array;
		public var scalingX: Number;
		public var scalingY: Number;
		public var textAlign: int;

		public function MetaState( state: MetaState = null )
		{
			if ( state == null )
			{
				savedStates = new Array();
				metaObjects = new Vector.<MetaObject>();
				currentPoint = new Point( 0, 0 );
				currentPen = new MetaPen();
				currentBrush = new MetaBrush();
				currentFont = new MetaFont();
			} else
			{
				setMetaState( state );
			}
		}

		public function addMetaObject( object: MetaObject ): void
		{
			var k: int;
			for ( k = 0; k < metaObjects.length; ++k )
			{
				if ( metaObjects[k] == null )
				{
					metaObjects[k] = object;
					return;
				}
			}
			metaObjects.push( object );
		}

		public function cleanup( cb: PdfContentByte ): void
		{
			var k: int = savedStates.length
			while ( k-- > 0 )
				cb.restoreState();
		}

		public function deleteMetaObject( index: int ): void
		{
			metaObjects[index] = null;
		}

		/** Getter for property backgroundMode.
		 * @return Value of property backgroundMode.
		 */
		public function getBackgroundMode(): int
		{
			return backgroundMode;
		}

		/** Getter for property currentBackgroundColor.
		 * @return Value of property currentBackgroundColor.
		 */
		public function getCurrentBackgroundColor(): RGBColor
		{
			return currentBackgroundColor;
		}

		public function getCurrentBrush(): MetaBrush
		{
			return currentBrush;
		}

		public function getCurrentFont(): MetaFont
		{
			return currentFont;
		}

		public function getCurrentPen(): MetaPen
		{
			return currentPen;
		}

		public function getCurrentPoint(): Point
		{
			return currentPoint;
		}

		/** Getter for property currentTextColor.
		 * @return Value of property currentTextColor.
		 */
		public function getCurrentTextColor(): RGBColor
		{
			return currentTextColor;
		}

		public function getLineNeutral(): Boolean
		{
			return ( lineJoin == 0 );
		}

		/** Getter for property polyFillMode.
		 * @return Value of property polyFillMode.
		 */
		public function getPolyFillMode(): int
		{
			return polyFillMode;
		}

		/** Getter for property textAlign.
		 * @return Value of property textAlign.
		 */
		public function getTextAlign(): int
		{
			return textAlign;
		}

		public function restoreState( index: int, cb: PdfContentByte ): void
		{
			var pops: int;
			if ( index < 0 )
				pops = Math.min( -index, savedStates.length );
			else
				pops = Math.max( savedStates.length - index, 0 );
			if ( pops == 0 )
				return;
			var state: MetaState = null;
			while ( pops-- != 0 )
			{
				cb.restoreState();
				state = MetaState( savedStates.shift() );
			}
			setMetaState( state );
		}

		public function saveState( cb: PdfContentByte ): void
		{
			cb.saveState();
			var state: MetaState = new MetaState( this );
			savedStates.splice( 0, 0, state );
		}

		public function selectMetaObject( index: int, cb: PdfContentByte ): void
		{
			var obj: MetaObject = metaObjects[index];

			if ( obj == null )
				return;

			var color: RGBColor;
			var style: int;

			switch ( obj.type )
			{
				case MetaObject.META_BRUSH:
					currentBrush = MetaBrush( obj );
					style = currentBrush.style;
					if ( style == MetaBrush.BS_SOLID )
					{
						color = currentBrush.color;
						cb.setColorFill( color );
					} else if ( style == MetaBrush.BS_HATCHED )
					{
						color = currentBackgroundColor;
						cb.setColorFill( color );
					}
					break;

				case MetaObject.META_PEN:
					currentPen = MetaPen( obj );
					style = currentPen.style;
					if ( style != MetaPen.PS_NULL )
					{
						color = currentPen.color;
						cb.setColorStroke( color );
						cb.setLineWidth( Math.abs( currentPen.penWidth * scalingX / extentWx ) );
						switch ( style )
						{
							case MetaPen.PS_DASH:
								cb.setLineDash3( 18, 6, 0 );
								break;
							case MetaPen.PS_DASHDOT:
								cb.setLiteral( "[9 6 3 6]0 d\n" );
								break;
							case MetaPen.PS_DASHDOTDOT:
								cb.setLiteral( "[9 3 3 3 3 3]0 d\n" );
								break;
							case MetaPen.PS_DOT:
								cb.setLineDash2( 3, 0 );
								break;
							default:
								cb.setLineDash( 0 );
								break;
						}
					}
					break;

				case MetaObject.META_FONT:
					currentFont = MetaFont( obj );
					break;
			}
		}

		/** Setter for property backgroundMode.
		 * @param backgroundMode New value of property backgroundMode.
		 */
		public function setBackgroundMode( backgroundMode: int ): void
		{
			this.backgroundMode = backgroundMode;
		}

		/** Setter for property currentBackgroundColor.
		 * @param currentBackgroundColor New value of property currentBackgroundColor.
		 */
		public function setCurrentBackgroundColor( currentBackgroundColor: RGBColor ): void
		{
			this.currentBackgroundColor = currentBackgroundColor;
		}

		public function setCurrentPoint( p: Point ): void
		{
			currentPoint = p;
		}

		/** Setter for property currentTextColor.
		 * @param currentTextColor New value of property currentTextColor.
		 */
		public function setCurrentTextColor( currentTextColor: RGBColor ): void
		{
			this.currentTextColor = currentTextColor;
		}

		public function setExtentWx( extentWx: int ): void
		{
			this.extentWx = extentWx;
		}

		public function setExtentWy( extentWy: int ): void
		{
			this.extentWy = extentWy;
		}

		public function setLineJoinPolygon( cb: PdfContentByte ): void
		{
			if ( lineJoin == 0 )
			{
				lineJoin = 1;
				cb.setLineJoin( JointStyle.ROUND );
			}
		}

		public function setLineJoinRectangle( cb: PdfContentByte ): void
		{
			if ( lineJoin != 0 )
			{
				lineJoin = 0;
				cb.setLineJoin( JointStyle.MITER );
			}
		}

		public function setMetaState( state: MetaState ): void
		{
			savedStates = state.savedStates;
			metaObjects = state.metaObjects;
			currentPoint = state.currentPoint;
			currentPen = state.currentPen;
			currentBrush = state.currentBrush;
			currentFont = state.currentFont;
			currentBackgroundColor = state.currentBackgroundColor;
			currentTextColor = state.currentTextColor;
			backgroundMode = state.backgroundMode;
			polyFillMode = state.polyFillMode;
			textAlign = state.textAlign;
			lineJoin = state.lineJoin;
			offsetWx = state.offsetWx;
			offsetWy = state.offsetWy;
			extentWx = state.extentWx;
			extentWy = state.extentWy;
			scalingX = state.scalingX;
			scalingY = state.scalingY;
		}

		public function setOffsetWx( offsetWx: int ): void
		{
			this.offsetWx = offsetWx;
		}

		public function setOffsetWy( offsetWy: int ): void
		{
			this.offsetWy = offsetWy;
		}

		/** Setter for property polyFillMode.
		 * @param polyFillMode New value of property polyFillMode.
		 */
		public function setPolyFillMode( polyFillMode: int ): void
		{
			this.polyFillMode = polyFillMode;
		}

		public function setScalingX( scalingX: Number ): void
		{
			this.scalingX = scalingX;
		}

		public function setScalingY( scalingY: Number ): void
		{
			this.scalingY = scalingY;
		}

		/** Setter for property textAlign.
		 * @param textAlign New value of property textAlign.
		 */
		public function setTextAlign( textAlign: int ): void
		{
			this.textAlign = textAlign;
		}

		public function transformAngle( angle: Number ): Number
		{
			var ta: Number = scalingY < 0 ? -angle : angle;
			return Number( scalingX < 0 ? Math.PI - ta : ta );
		}

		public function transformX( x: int ): Number
		{
			return ( Number( x ) - offsetWx ) * scalingX / extentWx;
		}

		public function transformY( y: int ): Number
		{
			return ( 1.0 - ( Number( y ) - offsetWy ) / extentWy ) * scalingY;
		}
	}
}