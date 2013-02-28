/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: MetaDo.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/codecs/wmf/MetaDo.as $
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
	import flash.utils.ByteArray;
	
	import org.purepdf.pdf.codec.BmpImage;
	import org.purepdf.codecs.wmf.InputMeta;
	import org.purepdf.codecs.wmf.MetaState;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Meta;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.io.ByteArrayInputStream;
	import org.purepdf.io.InputStream;
	import org.purepdf.io.OutputStreamCounter;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.Bytes;

	public class MetaDo
	{
		public static const META_ANIMATEPALETTE:int = 0x0436;
		public static const META_ARC:int = 0x0817;
		public static const META_BITBLT:int = 0x0922;
		public static const META_CHORD:int = 0x0830;
		public static const META_CREATEBRUSHINDIRECT:int = 0x02FC;
		public static const META_CREATEFONTINDIRECT:int = 0x02FB;
		public static const META_CREATEPALETTE:int = 0x00f7;
		public static const META_CREATEPATTERNBRUSH:int = 0x01F9;
		public static const META_CREATEPENINDIRECT:int = 0x02FA;
		public static const META_CREATEREGION:int = 0x06FF;
		public static const META_DELETEOBJECT:int = 0x01f0;
		public static const META_DIBBITBLT:int = 0x0940;
		public static const META_DIBCREATEPATTERNBRUSH:int = 0x0142;
		public static const META_DIBSTRETCHBLT:int = 0x0b41;
		public static const META_ELLIPSE:int = 0x0418;
		public static const META_ESCAPE:int = 0x0626;
		public static const META_EXCLUDECLIPRECT:int = 0x0415;
		public static const META_EXTFLOODFILL:int = 0x0548;
		public static const META_EXTTEXTOUT:int = 0x0a32;
		public static const META_FILLREGION:int = 0x0228;
		public static const META_FLOODFILL:int = 0x0419;
		public static const META_FRAMEREGION:int = 0x0429;
		public static const META_INTERSECTCLIPRECT:int = 0x0416;
		public static const META_INVERTREGION:int = 0x012A;
		public static const META_LINETO:int = 0x0213;
		public static const META_MOVETO:int = 0x0214;
		public static const META_OFFSETCLIPRGN:int = 0x0220;
		public static const META_OFFSETVIEWPORTORG:int = 0x0211;
		public static const META_OFFSETWINDOWORG:int = 0x020F;
		public static const META_PAINTREGION:int = 0x012B;
		public static const META_PATBLT:int = 0x061D;
		public static const META_PIE:int = 0x081A;
		public static const META_POLYGON:int = 0x0324;
		public static const META_POLYLINE:int = 0x0325;
		public static const META_POLYPOLYGON:int = 0x0538;
		public static const META_REALIZEPALETTE:int = 0x0035;
		public static const META_RECTANGLE:int = 0x041B;
		public static const META_RESIZEPALETTE:int = 0x0139;
		public static const META_RESTOREDC:int = 0x0127;
		public static const META_ROUNDRECT:int = 0x061C;
		public static const META_SAVEDC:int = 0x001E;
		public static const META_SCALEVIEWPORTEXT:int = 0x0412;
		public static const META_SCALEWINDOWEXT:int = 0x0410;
		public static const META_SELECTCLIPREGION:int = 0x012C;
		public static const META_SELECTOBJECT:int = 0x012D;
		public static const META_SELECTPALETTE:int = 0x0234;

		public static const META_SETBKCOLOR:int = 0x0201;
		public static const META_SETBKMODE:int = 0x0102;
		public static const META_SETDIBTODEV:int = 0x0d33;
		public static const META_SETMAPMODE:int = 0x0103;
		public static const META_SETMAPPERFLAGS:int = 0x0231;
		public static const META_SETPALENTRIES:int = 0x0037;
		public static const META_SETPIXEL:int = 0x041F;
		public static const META_SETPOLYFILLMODE:int = 0x0106;
		public static const META_SETRELABS:int = 0x0105;
		public static const META_SETROP2:int = 0x0104;
		public static const META_SETSTRETCHBLTMODE:int = 0x0107;
		public static const META_SETTEXTALIGN:int = 0x012E;
		public static const META_SETTEXTCHAREXTRA:int = 0x0108;
		public static const META_SETTEXTCOLOR:int = 0x0209;
		public static const META_SETTEXTJUSTIFICATION:int = 0x020A;
		public static const META_SETVIEWPORTEXT:int = 0x020E;
		public static const META_SETVIEWPORTORG:int = 0x020D;
		public static const META_SETWINDOWEXT:int = 0x020C;
		public static const META_SETWINDOWORG:int = 0x020B;
		public static const META_STRETCHBLT:int = 0x0B23;
		public static const META_STRETCHDIB:int = 0x0f43;
		public static const META_TEXTOUT:int = 0x0521;

		public var cb: PdfContentByte;
		public var input: InputMeta;
		protected var bottom: int;
		protected var inch: int;
		protected var left: int;
		protected var right: int;
		protected var state: MetaState = new MetaState();
		protected var top: int;

		public function MetaDo( input: InputStream, cb: PdfContentByte )
		{
			this.cb = cb;
			this.input = new InputMeta( input );
		}

		public function isNullStrokeFill( isRectangle: Boolean ): Boolean
		{
			var pen: MetaPen = state.getCurrentPen();
			var brush: MetaBrush = state.getCurrentBrush();
			var noPen: Boolean = ( pen.style == MetaPen.PS_NULL );
			var style: int = brush.style;
			var isBrush: Boolean = ( style == MetaBrush.BS_SOLID || ( style == MetaBrush.BS_HATCHED && state.getBackgroundMode() == MetaState.OPAQUE ) );
			var result: Boolean = noPen && !isBrush;
			if ( !noPen )
			{
				if ( isRectangle )
					state.setLineJoinRectangle( cb );
				else
					state.setLineJoinPolygon( cb );
			}
			return result;
		}

		public function outputText( x: int, y: int, flag: int, x1: int, y1: int, x2: int, y2: int, text: String ): void
		{
			var font: MetaFont = state.getCurrentFont();
			var refX: Number = state.transformX( x );
			var refY: Number = state.transformY( y );
			var angle: Number = state.transformAngle( font.angle );
			var sin: Number = Math.sin( angle );
			var cos: Number = Math.cos( angle );
			var fontSize: Number = font.getFontSize( state );
			var bf: BaseFont = font.getFont();
			var align: int = state.getTextAlign();
			var textWidth: Number = bf.getWidthPoint( text, fontSize );
			var tx: Number = 0;
			var ty: Number = 0;
			var descender: Number = bf.getFontDescriptor( BaseFont.DESCENT, fontSize );
			var ury: Number = bf.getFontDescriptor( BaseFont.BBOXURY, fontSize );
			cb.saveState();
			cb.concatCTM( cos, sin, -sin, cos, refX, refY );
			if ( ( align & MetaState.TA_CENTER ) == MetaState.TA_CENTER )
				tx = -textWidth / 2;
			else if ( ( align & MetaState.TA_RIGHT ) == MetaState.TA_RIGHT )
				tx = -textWidth;
			if ( ( align & MetaState.TA_BASELINE ) == MetaState.TA_BASELINE )
				ty = 0;
			else if ( ( align & MetaState.TA_BOTTOM ) == MetaState.TA_BOTTOM )
				ty = -descender;
			else
				ty = -ury;
			var textColor: RGBColor;
			if ( state.getBackgroundMode() == MetaState.OPAQUE )
			{
				textColor = state.getCurrentBackgroundColor();
				cb.setColorFill( textColor );
				cb.rectangle( tx, ty + descender, textWidth, ury - descender );
				cb.fill();
			}
			textColor = state.getCurrentTextColor();
			cb.setColorFill( textColor );
			cb.beginText();
			cb.setFontAndSize( bf, fontSize );
			cb.setTextMatrix( tx, ty );
			cb.showText( text );
			cb.endText();
			if ( font.underline )
			{
				cb.rectangle( tx, ty - fontSize / 4, textWidth, fontSize / 15 );
				cb.fill();
			}
			if ( font.strikeout )
			{
				cb.rectangle( tx, ty + fontSize / 3, textWidth, fontSize / 15 );
				cb.fill();
			}
			cb.restoreState();
		}

		public function readAll(): void
		{
			if ( input.readInt() != -1698247209 )
			{
				throw new DocumentError( "not a placeable windows metafile" );
			}

			input.readWord();
			left = input.readShort();
			top = input.readShort();
			right = input.readShort();
			bottom = input.readShort();
			inch = input.readWord();
			state.setScalingX( Number( right - left ) / Number( inch ) * 72.0 );
			state.setScalingY( Number( bottom - top ) / Number( inch ) * 72.0 );
			state.setOffsetWx( left );
			state.setOffsetWy( top );
			state.setExtentWx( right - left );
			state.setExtentWy( bottom - top );
			input.readInt();
			input.readWord();
			input.skip( 18 );

			var tsize: int;
			var fn: int;
			var x: int;
			var y: int;
			var idx: int;
			var p: Point;
			var len: int;
			var k: int;
			var sx: int;
			var sy: int;
			var count: int;
			var c: int;

			var yend: Number;
			var xend: Number;
			var ystart: Number;
			var xstart: Number;
			var b: Number;
			var r: Number;
			var t: Number;
			var l: Number;
			var cx: Number;
			var cy: Number;
			var arc1: Number;
			var arc2: Number;
			var ar: Vector.<Vector.<Number>>;
			var pt: Vector.<Number>;
			var s: String;
			var text: Bytes;

			cb.setLineCap( 1 );
			cb.setLineJoin( JointStyle.MITER );
			for ( ;; )
			{
				var lenMarker: int = input.getLength();
				tsize = input.readInt();
				if ( tsize < 3 )
					break;
				fn = input.readWord();

				trace( "function: " + fn + ", available: " + input.getAvailable() );
				
				switch ( fn )
				{
					case 0:
						break;

					case META_CREATEPALETTE:
					case META_CREATEREGION:
					case META_DIBCREATEPATTERNBRUSH:
						state.addMetaObject( new MetaObject() );
						break;

					case META_CREATEPENINDIRECT:
						var pen: MetaPen = new MetaPen();
						pen.init( input );
						state.addMetaObject( pen );
						break;

					case META_CREATEBRUSHINDIRECT:
						var brush: MetaBrush = new MetaBrush();
						brush.init( input );
						state.addMetaObject( brush );
						break;

					case META_CREATEFONTINDIRECT:
						var font: Metafont = new MetaFont();
						font.init( input );
						state.addMetaObject( font );
						break;

					case META_SELECTOBJECT:
						idx = input.readWord();
						state.selectMetaObject( idx, cb );
						break;

					case META_DELETEOBJECT:
						idx = input.readWord();
						state.deleteMetaObject( idx );
						break;

					case META_SAVEDC:
						state.saveState( cb );
						break;

					case META_RESTOREDC:
						idx = input.readShort();
						state.restoreState( idx, cb );
						break;

					case META_SETWINDOWORG:
						state.setOffsetWy( input.readShort() );
						state.setOffsetWx( input.readShort() );
						break;

					case META_SETWINDOWEXT:
						state.setExtentWy( input.readShort() );
						state.setExtentWx( input.readShort() );
						break;

					case META_MOVETO:
						y = input.readShort();
						p = new Point( input.readShort(), y );
						state.setCurrentPoint( p );
						break;

					case META_LINETO:
						y = input.readShort();
						x = input.readShort();
						p = state.getCurrentPoint();
						cb.moveTo( state.transformX( p.x ), state.transformY( p.y ) );
						cb.lineTo( state.transformX( x ), state.transformY( y ) );
						cb.stroke();
						state.setCurrentPoint( new Point( x, y ) );
						break;

					case META_POLYLINE:
						state.setLineJoinPolygon( cb );
						len = input.readWord();
						x = input.readShort();
						y = input.readShort();
						cb.moveTo( state.transformX( x ), state.transformY( y ) );
						for ( k = 1; k < len; ++k )
						{
							x = input.readShort();
							y = input.readShort();
							cb.lineTo( state.transformX( x ), state.transformY( y ) );
						}
						cb.stroke();
						break;

					case META_POLYGON:
						if ( isNullStrokeFill( false ) )
							break;
						len = input.readWord();
						sx = input.readShort();
						sy = input.readShort();
						cb.moveTo( state.transformX( sx ), state.transformY( sy ) );
						for ( k = 1; k < len; ++k )
						{
							x = input.readShort();
							y = input.readShort();
							cb.lineTo( state.transformX( x ), state.transformY( y ) );
						}
						cb.lineTo( state.transformX( sx ), state.transformY( sy ) );
						strokeAndFill();
						break;

					case META_POLYPOLYGON:
						if ( isNullStrokeFill( false ) )
							break;
						var numPoly: int = input.readWord();
						var lens: Vector.<int> = new Vector.<int>( numPoly, true );

						for ( k = 0; k < lens.length; ++k )
						{
							lens[k] = input.readWord();
						}

						for ( var j: int = 0; j < lens.length; ++j )
						{
							len = lens[j];
							sx = input.readShort();
							sy = input.readShort();
							cb.moveTo( state.transformX( sx ), state.transformY( sy ) );
							for ( k = 1; k < len; ++k )
							{
								x = input.readShort();
								y = input.readShort();
								cb.lineTo( state.transformX( x ), state.transformY( y ) );
							}
							cb.lineTo( state.transformX( sx ), state.transformY( sy ) );
						}
						strokeAndFill();
						break;

					case META_ELLIPSE:
						if ( isNullStrokeFill( state.getLineNeutral() ) )
							break;
						var bi: int = input.readShort();
						var ri: int = input.readShort();
						var ti: int = input.readShort();
						var li: int = input.readShort();
						cb.arc( state.transformX( li ), state.transformY( bi ), state.transformX( ri ), state.transformY( ti ), 0, 360 );
						strokeAndFill();
						break;

					case META_ARC:
						if ( isNullStrokeFill( state.getLineNeutral() ) )
							break;
						yend = state.transformY( input.readShort() );
						xend = state.transformX( input.readShort() );
						ystart = state.transformY( input.readShort() );
						xstart = state.transformX( input.readShort() );
						b = state.transformY( input.readShort() );
						r = state.transformX( input.readShort() );
						t = state.transformY( input.readShort() );
						l = state.transformX( input.readShort() );
						cx = ( r + l ) / 2;
						cy = ( t + b ) / 2;
						arc1 = getArc( cx, cy, xstart, ystart );
						arc2 = getArc( cx, cy, xend, yend );
						arc2 -= arc1;
						if ( arc2 <= 0 )
							arc2 += 360;
						cb.arc( l, b, r, t, arc1, arc2 );
						cb.stroke();
						break;

					case META_PIE:
						if ( isNullStrokeFill( state.getLineNeutral() ) )
							break;
						yend = state.transformY( input.readShort() );
						xend = state.transformX( input.readShort() );
						ystart = state.transformY( input.readShort() );
						xstart = state.transformX( input.readShort() );
						b = state.transformY( input.readShort() );
						r = state.transformX( input.readShort() );
						t = state.transformY( input.readShort() );
						l = state.transformX( input.readShort() );
						cx = ( r + l ) / 2;
						cy = ( t + b ) / 2;
						arc1 = getArc( cx, cy, xstart, ystart );
						arc2 = getArc( cx, cy, xend, yend );
						arc2 -= arc1;
						if ( arc2 <= 0 )
							arc2 += 360;

						ar = PdfContentByte.bezierArc( l, b, r, t, arc1, arc2 );
						if ( ar.length == 0 )
							break;

						pt = ar[0];
						cb.moveTo( cx, cy );
						cb.lineTo( pt[0], pt[1] );
						for ( k = 0; k < ar.length; ++k )
						{
							pt = ar[k];
							cb.curveTo( pt[2], pt[3], pt[4], pt[5], pt[6], pt[7] );
						}
						cb.lineTo( cx, cy );
						strokeAndFill();
						break;

					case META_CHORD:
						if ( isNullStrokeFill( state.getLineNeutral() ) )
							break;
						yend = state.transformY( input.readShort() );
						xend = state.transformX( input.readShort() );
						ystart = state.transformY( input.readShort() );
						xstart = state.transformX( input.readShort() );
						b = state.transformY( input.readShort() );
						r = state.transformX( input.readShort() );
						t = state.transformY( input.readShort() );
						l = state.transformX( input.readShort() );
						cx = ( r + l ) / 2;
						cy = ( t + b ) / 2;
						arc1 = getArc( cx, cy, xstart, ystart );
						arc2 = getArc( cx, cy, xend, yend );
						arc2 -= arc1;
						if ( arc2 <= 0 )
							arc2 += 360;
						ar = PdfContentByte.bezierArc( l, b, r, t, arc1, arc2 );
						if ( ar.length == 0 )
							break;
						pt = ar[0];
						cx = pt[0];
						cy = pt[1];
						cb.moveTo( cx, cy );
						for ( k = 0; k < ar.length; ++k )
						{
							pt = ar[k];
							cb.curveTo( pt[2], pt[3], pt[4], pt[5], pt[6], pt[7] );
						}
						cb.lineTo( cx, cy );
						strokeAndFill();
						break;

					case META_RECTANGLE:
						if ( isNullStrokeFill( true ) )
							break;
						b = state.transformY( input.readShort() );
						r = state.transformX( input.readShort() );
						t = state.transformY( input.readShort() );
						l = state.transformX( input.readShort() );
						cb.rectangle( l, b, r - l, t - b );
						strokeAndFill();
						break;

					case META_ROUNDRECT:
						if ( isNullStrokeFill( true ) )
							break;
						var h: Number = state.transformY( 0 ) - state.transformY( input.readShort() );
						var w: Number = state.transformX( input.readShort() ) - state.transformX( 0 );
						b = state.transformY( input.readShort() );
						r = state.transformX( input.readShort() );
						t = state.transformY( input.readShort() );
						l = state.transformX( input.readShort() );
						cb.roundRectangle( l, b, r - l, t - b, ( h + w ) / 4 );
						strokeAndFill();
						break;

					case META_INTERSECTCLIPRECT:
						b = state.transformY( input.readShort() );
						r = state.transformX( input.readShort() );
						t = state.transformY( input.readShort() );
						l = state.transformX( input.readShort() );
						cb.rectangle( l, b, r - l, t - b );
						cb.clip( true );
						cb.newPath();
						break;

					case META_EXTTEXTOUT:
						y = input.readShort();
						x = input.readShort();
						count = input.readWord();
						var flag: int = input.readWord();
						var x1: int = 0;
						var y1: int = 0;
						var x2: int = 0;
						var y2: int = 0;
						if ( ( flag & ( MetaFont.ETO_CLIPPED | MetaFont.ETO_OPAQUE ) ) != 0 )
						{
							x1 = input.readShort();
							y1 = input.readShort();
							x2 = input.readShort();
							y2 = input.readShort();
						}
						text = new Bytes( count );

						for ( k = 0; k < count; ++k )
						{
							c = input.readByte();
							if ( c == 0 )
								break;
							text[k] = c;
						}

						s = "";
						s = text.readAsString( 0, k );
						outputText( x, y, flag, x1, y1, x2, y2, s );
						break;

					case META_TEXTOUT:
						count = input.readWord();
						text = new Bytes( count );

						for ( k = 0; k < count; ++k )
						{
							c = input.readByte();
							if ( c == 0 )
								break;
							text[k] = c;
						}

						s = text.readAsString( 0, k );

						count = ( count + 1 ) & 0xfffe;
						input.skip( count - k );
						y = input.readShort();
						x = input.readShort();
						outputText( x, y, 0, 0, 0, 0, 0, s );
						break;

					case META_SETBKCOLOR:
						state.setCurrentBackgroundColor( input.readColor() );
						break;

					case META_SETTEXTCOLOR:
						state.setCurrentTextColor( input.readColor() );
						break;

					case META_SETTEXTALIGN:
						state.setTextAlign( input.readWord() );
						break;

					case META_SETBKMODE:
						state.setBackgroundMode( input.readWord() );
						break;

					case META_SETPOLYFILLMODE:
						state.setPolyFillMode( input.readWord() );
						break;

					case META_SETPIXEL:
						var color: RGBColor = input.readColor();
						y = input.readShort();
						x = input.readShort();
						cb.saveState();
						cb.setColorFill( color );
						cb.rectangle( state.transformX( x ), state.transformY( y ), .2, .2 );
						cb.fill();
						cb.restoreState();
						break;


					case META_DIBSTRETCHBLT:
					case META_STRETCHDIB:
						var rop: int = input.readInt();
						if ( fn == META_STRETCHDIB )
						{
							/*int usage = */
							input.readWord();
						}

						var srcHeight: int = input.readShort();
						var srcWidth: int = input.readShort();
						var ySrc: int = input.readShort();
						var xSrc: int = input.readShort();
						var destHeight: Number = state.transformY( input.readShort() ) - state.transformY( 0 );
						var destWidth: Number = state.transformX( input.readShort() ) - state.transformX( 0 );
						var yDest: Number = state.transformY( input.readShort() );
						var xDest: Number = state.transformX( input.readShort() );
						var byte: Bytes = new Bytes( ( tsize * 2 ) - ( input.getLength() - lenMarker ) );

						for ( k = 0; k < byte.length; ++k )
							byte[k] = input.readByte();

						
						try
						{
							var inb: ByteArrayInputStream = new ByteArrayInputStream( byte.buffer );
							var bmp: ImageElement = BmpImage.getImage3( inb, true, byte.length );
							
							cb.saveState();
							cb.rectangle( xDest, yDest, destWidth, destHeight );
							cb.clip();
							cb.newPath();
							bmp.scaleAbsolute( destWidth * bmp.width / srcWidth, -destHeight * bmp.height / srcHeight );
							bmp.setAbsolutePosition( xDest - destWidth * xSrc / srcWidth, yDest + destHeight * ySrc / srcHeight - bmp.scaledHeight );
							cb.addImage( bmp );
							cb.restoreState();
						} catch ( e: Error )
						{
							// empty on purpose
						}
						break;
				}
				input.skip( ( tsize * 2 ) - ( input.getLength() - lenMarker ) );
			}
			state.cleanup( cb );
		}

		public function strokeAndFill(): void
		{
			var pen: MetaPen = state.getCurrentPen();
			var brush: MetaBrush = state.getCurrentBrush();
			var penStyle: int = pen.style;
			var brushStyle: int = brush.style;

			if ( penStyle == MetaPen.PS_NULL )
			{
				cb.closePath();
				if ( state.getPolyFillMode() == MetaState.ALTERNATE )
				{
					cb.fill( true );
				} else
				{
					cb.fill();
				}
			} else
			{
				var isBrush: Boolean = ( brushStyle == MetaBrush.BS_SOLID || ( brushStyle == MetaBrush.BS_HATCHED && state.getBackgroundMode() == MetaState.
						OPAQUE ) );
				if ( isBrush )
				{
					if ( state.getPolyFillMode() == MetaState.ALTERNATE )
						cb.closePathFillStroke( true );
					else
						cb.closePathFillStroke();
				} else
				{
					cb.closePathStroke();
				}
			}
		}

		public static function getArc( xCenter: Number, yCenter: Number, xDot: Number, yDot: Number ): Number
		{
			var s: Number = Math.atan2( yDot - yCenter, xDot - xCenter );
			if ( s < 0 )
				s += Math.PI * 2;
			return Number( s / Math.PI * 180 );
		}

		public static function writeDWord( os: ByteArray, v: int ): void
		{
			writeWord( os, v & 0xffff );
			writeWord( os, ( v >>> 16 ) & 0xffff );
		}

		public static function writeWord( os: ByteArray, v: int ): void
		{
			os.writeInt( v & 0xff );
			os.writeInt( ( v >>> 8 ) & 0xff );
		}
	}
}