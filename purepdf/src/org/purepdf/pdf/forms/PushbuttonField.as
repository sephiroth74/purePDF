/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PushbuttonField.as 288 2010-02-07 10:40:16Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 288 $ $LastChangedDate: 2010-02-07 05:40:16 -0500 (Sun, 07 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/forms/PushbuttonField.as $
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
package org.purepdf.pdf.forms
{
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PRIndirectReference;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfBorderDictionary;
	import org.purepdf.pdf.PdfDashPattern;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfReader;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.pdf_core;

	public class PushbuttonField extends FieldBase
	{
		public static const LAYOUT_ICON_LEFT_LABEL_RIGHT: int = 5;
		public static const LAYOUT_ICON_ONLY: int = 2;
		public static const LAYOUT_ICON_TOP_LABEL_BOTTOM: int = 3;
		public static const LAYOUT_LABEL_LEFT_ICON_RIGHT: int = 6;
		public static const LAYOUT_LABEL_ONLY: int = 1;
		public static const LAYOUT_LABEL_OVER_ICON: int = 7;
		public static const LAYOUT_LABEL_TOP_ICON_BOTTOM: int = 4;
		public static const SCALE_ICON_ALWAYS: int = 1;
		public static const SCALE_ICON_IS_TOO_BIG: int = 3;
		public static const SCALE_ICON_IS_TOO_SMALL: int = 4;
		public static const SCALE_ICON_NEVER: int = 2;

		private var _iconFitToBounds: Boolean;

		private var _iconHorizontalAdjustment: Number = 0.5;
		private var _iconReference: PRIndirectReference;
		private var _iconVerticalAdjustment: Number = 0.5;
		private var _image: ImageElement;

		private var _layout: int = LAYOUT_LABEL_ONLY;
		private var _proportionalIcon: Boolean = true;
		private var _scaleIcon: int = SCALE_ICON_ALWAYS;
		private var _template: PdfTemplate;
		private var tp: PdfTemplate;

		public function PushbuttonField( $writer: PdfWriter, $box: RectangleElement, $fieldName: String )
		{
			super( $writer, $box, $fieldName );
		}

		/**
		 * Gets the pushbutton field.
		 * @throws IOException on error
		 * @throws DocumentException on error
		 * @return the pushbutton field
		 */
		public function getField(): PdfFormField
		{
			var field: PdfFormField = PdfFormField.createPushButton( writer );
			field.setWidget( box, PdfAnnotation.HIGHLIGHT_INVERT );
			if ( fieldName != null )
			{
				field.fieldName = fieldName;
				if ( ( options & READ_ONLY ) != 0 )
					field.setFieldFlags( PdfFormField.FF_READ_ONLY );
				if ( ( options & REQUIRED ) != 0 )
					field.setFieldFlags( PdfFormField.FF_REQUIRED );
			}
			if ( text != null )
				field.mkNormalCaption = text;
			if ( rotation != 0 )
				field.mkRotation = rotation;
			field.borderStyle = new PdfBorderDictionary( borderWidth, borderStyle, new PdfDashPattern( 3 ) );
			var tpa: PdfAppearance = getAppearance();
			field.setAppearance( PdfAnnotation.APPEARANCE_NORMAL, tpa );
			var da: PdfAppearance = PdfAppearance( tpa.duplicate() );
			da.setFontAndSize( getRealFont(), fontSize );
			if ( textColor == null )
				da.setGrayFill( 0 );
			else
				da.setColorFill( textColor );
			field.defaultAppearanceString = da;
			if ( borderColor != null )
				field.mkBorderColor = borderColor;
			if ( backgroundColor != null )
				field.mkBackgroundColor = backgroundColor;
			switch ( visibility )
			{
				case HIDDEN:
					field.flags = ( PdfAnnotation.FLAGS_PRINT | PdfAnnotation.FLAGS_HIDDEN );
					break;
				case VISIBLE_BUT_DOES_NOT_PRINT:
					break;
				case HIDDEN_BUT_PRINTABLE:
					field.flags = ( PdfAnnotation.FLAGS_PRINT | PdfAnnotation.FLAGS_NOVIEW );
					break;
				default:
					field.flags = PdfAnnotation.FLAGS_PRINT;
					break;
			}
			if ( tp != null )
				field.mkNormalIcon = tp;
			field.mkTextPosition = layout - 1;
			var scale: PdfName = PdfName.A;
			if ( scaleIcon == SCALE_ICON_IS_TOO_BIG )
				scale = PdfName.B;
			else if ( scaleIcon == SCALE_ICON_IS_TOO_SMALL )
				scale = PdfName.S;
			else if ( scaleIcon == SCALE_ICON_NEVER )
				scale = PdfName.N;
			field.setMKIconFit( scale, proportionalIcon ? PdfName.P : PdfName.A, iconHorizontalAdjustment, iconVerticalAdjustment, iconFitToBounds );
			return field;
		}

		/**
		 * Gets the button appearance.
		 * @throws IOException on error
		 * @throws DocumentException on error
		 * @return the button appearance
		 */
		public function getAppearance(): PdfAppearance
		{
			var app: PdfAppearance = getBorderAppearance();
			var box: RectangleElement = RectangleElement.clone( app.boundingBox );
			if ( ( text == null || text.length == 0 ) && ( layout == LAYOUT_LABEL_ONLY || ( image == null && template == null && iconReference == null ) ) )
			{
				return app;
			}
			if ( layout == LAYOUT_ICON_ONLY && image == null && template == null && iconReference == null )
				return app;
			var ufont: BaseFont = getRealFont();
			var borderExtra: Boolean = borderStyle == PdfBorderDictionary.STYLE_BEVELED || borderStyle == PdfBorderDictionary.STYLE_INSET;
			var h: Number = box.height - borderWidth * 2;
			var bw2: Number = borderWidth;
			if ( borderExtra )
			{
				h -= borderWidth * 2;
				bw2 *= 2;
			}
			var offsetX: Number = ( borderExtra ? 2 * borderWidth : borderWidth );
			offsetX = Math.max( offsetX, 1 );
			var offX: Number = Math.min( bw2, offsetX );
			tp = null;
			var textX: Number = Number.NaN;
			var textY: Number = 0;
			var fsize: Number = fontSize;
			var wt: Number = box.width - 2 * offX - 2;
			var ht: Number = box.height - 2 * offX;
			var adj: Number = ( iconFitToBounds ? 0 : offX + 1 );
			var nlayout: int = layout;
			if ( image == null && template == null && iconReference == null )
				nlayout = LAYOUT_LABEL_ONLY;
			var iconBox: RectangleElement = null;
			while ( true )
			{
				switch ( nlayout )
				{
					case LAYOUT_LABEL_ONLY:
					case LAYOUT_LABEL_OVER_ICON:
						if ( text != null && text.length > 0 && wt > 0 && ht > 0 )
						{
							fsize = calculateFontSize( wt, ht );
							textX = ( box.width - ufont.getWidthPoint( text, fsize ) ) / 2;
							textY = ( box.height - ufont.getFontDescriptor( BaseFont.ASCENT, fsize ) ) / 2;
						}
					case LAYOUT_ICON_ONLY:
						if ( nlayout == LAYOUT_LABEL_OVER_ICON || nlayout == LAYOUT_ICON_ONLY )
							iconBox = new RectangleElement( box.getLeft() + adj, box.getBottom() + adj, box.getRight() - adj, box.getTop() - adj );
						break;
					case LAYOUT_ICON_TOP_LABEL_BOTTOM:
						if ( text == null || text.length == 0 || wt <= 0 || ht <= 0 )
						{
							nlayout = LAYOUT_ICON_ONLY;
							continue;
						}
						var nht: Number = box.height * 0.35 - offX;
						if ( nht > 0 )
							fsize = calculateFontSize( wt, nht );
						else
							fsize = 4;
						textX = ( box.width - ufont.getWidthPoint( text, fsize ) ) / 2;
						textY = offX - ufont.getFontDescriptor( BaseFont.DESCENT, fsize );
						iconBox = new RectangleElement( box.getLeft() + adj, textY + fsize, box.getRight() - adj, box.getTop() - adj );
						break;
					case LAYOUT_LABEL_TOP_ICON_BOTTOM:
						if ( text == null || text.length == 0 || wt <= 0 || ht <= 0 )
						{
							nlayout = LAYOUT_ICON_ONLY;
							continue;
						}
						nht = box.height * 0.35 - offX;
						if ( nht > 0 )
							fsize = calculateFontSize( wt, nht );
						else
							fsize = 4;
						textX = ( box.width - ufont.getWidthPoint( text, fsize ) ) / 2;
						textY = box.height - offX - fsize;
						if ( textY < offX )
							textY = offX;
						iconBox = new RectangleElement( box.getLeft() + adj, box.getBottom() + adj, box.getRight() - adj, textY + ufont.getFontDescriptor( BaseFont.
								DESCENT, fsize ) );
						break;
					case LAYOUT_LABEL_LEFT_ICON_RIGHT:
						if ( text == null || text.length == 0 || wt <= 0 || ht <= 0 )
						{
							nlayout = LAYOUT_ICON_ONLY;
							continue;
						}
						var nw: Number = box.width * 0.35 - offX;
						if ( nw > 0 )
							fsize = calculateFontSize( wt, nw );
						else
							fsize = 4;
						if ( ufont.getWidthPoint( text, fsize ) >= wt )
						{
							nlayout = LAYOUT_LABEL_ONLY;
							fsize = fontSize;
							continue;
						}
						textX = offX + 1;
						textY = ( box.height - ufont.getFontDescriptor( BaseFont.ASCENT, fsize ) ) / 2;
						iconBox = new RectangleElement( textX + ufont.getWidthPoint( text, fsize ), box.getBottom() + adj, box.getRight() - adj, box.getTop() -
								adj );
						break;
					case LAYOUT_ICON_LEFT_LABEL_RIGHT:
						if ( text == null || text.length == 0 || wt <= 0 || ht <= 0 )
						{
							nlayout = LAYOUT_ICON_ONLY;
							continue;
						}
						nw = box.width * 0.35 - offX;
						if ( nw > 0 )
							fsize = calculateFontSize( wt, nw );
						else
							fsize = 4;
						if ( ufont.getWidthPoint( text, fsize ) >= wt )
						{
							nlayout = LAYOUT_LABEL_ONLY;
							fsize = fontSize;
							continue;
						}
						textX = box.width - ufont.getWidthPoint( text, fsize ) - offX - 1;
						textY = ( box.height - ufont.getFontDescriptor( BaseFont.ASCENT, fsize ) ) / 2;
						iconBox = new RectangleElement( box.getLeft() + adj, box.getBottom() + adj, textX - 1, box.getTop() - adj );
						break;
				}
				break;
			}
			if ( textY < box.getBottom() + offX )
				textY = box.getBottom() + offX;
			if ( iconBox != null && ( iconBox.width <= 0 || iconBox.height <= 0 ) )
				iconBox = null;
			var haveIcon: Boolean = false;
			var boundingBoxWidth: Number = 0;
			var boundingBoxHeight: Number = 0;
			var matrix: PdfArray = null;
			if ( iconBox != null )
			{
				if ( image != null )
				{
					tp = new PdfTemplate( writer );
					tp.boundingBox = RectangleElement.clone( image );
					writer.pdf_core::addDirectTemplateSimple( tp, PdfName.FRM );
					tp.addImage3( image, image.width, 0, 0, image.height, 0, 0 );
					haveIcon = true;
					boundingBoxWidth = tp.boundingBox.width;
					boundingBoxHeight = tp.boundingBox.height;
				} else if ( template != null )
				{
					tp = new PdfTemplate( writer );
					tp.boundingBox = new RectangleElement( 0, 0, template.width, template.height );
					writer.pdf_core::addDirectTemplateSimple( tp, PdfName.FRM );
					tp.addTemplate( template, template.boundingBox.getLeft(), template.boundingBox.getBottom() );
					haveIcon = true;
					boundingBoxWidth = tp.boundingBox.width;
					boundingBoxHeight = tp.boundingBox.height;
				} else if ( iconReference != null )
				{
					var dic: PdfDictionary = PdfReader.getPdfObject( iconReference ) as PdfDictionary;
					if ( dic != null )
					{
						var r2: RectangleElement = PdfReader.getNormalizedRectangle( dic.getAsArray( PdfName.BBOX ) );
						matrix = dic.getAsArray( PdfName.MATRIX );
						haveIcon = true;
						boundingBoxWidth = r2.width;
						boundingBoxHeight = r2.height;
					}
				}
			}
			if ( haveIcon )
			{
				var icx: Number = iconBox.width / boundingBoxWidth;
				var icy: Number = iconBox.height / boundingBoxHeight;
				if ( proportionalIcon )
				{
					switch ( scaleIcon )
					{
						case SCALE_ICON_IS_TOO_BIG:
							icx = Math.min( icx, icy );
							icx = Math.min( icx, 1 );
							break;
						case SCALE_ICON_IS_TOO_SMALL:
							icx = Math.min( icx, icy );
							icx = Math.max( icx, 1 );
							break;
						case SCALE_ICON_NEVER:
							icx = 1;
							break;
						default:
							icx = Math.min( icx, icy );
							break;
					}
					icy = icx;
				} else
				{
					switch ( scaleIcon )
					{
						case SCALE_ICON_IS_TOO_BIG:
							icx = Math.min( icx, 1 );
							icy = Math.min( icy, 1 );
							break;
						case SCALE_ICON_IS_TOO_SMALL:
							icx = Math.max( icx, 1 );
							icy = Math.max( icy, 1 );
							break;
						case SCALE_ICON_NEVER:
							icx = icy = 1;
							break;
						default:
							break;
					}
				}
				var xpos: Number = iconBox.getLeft() + ( iconBox.width - ( boundingBoxWidth * icx ) ) * iconHorizontalAdjustment;
				var ypos: Number = iconBox.getBottom() + ( iconBox.height - ( boundingBoxHeight * icy ) ) * iconVerticalAdjustment;
				app.saveState();
				app.rectangle( iconBox.getLeft(), iconBox.getBottom(), iconBox.width, iconBox.height );
				app.clip();
				app.newPath();
				if ( tp != null )
					app.addTemplate( tp, icx, 0, 0, icy, xpos, ypos );
				else
				{
					var cox: Number = 0;
					var coy: Number = 0;
					if ( matrix != null && matrix.size == 6 )
					{
						var nm: PdfNumber = matrix.getAsNumber( 4 );
						if ( nm != null )
							cox = nm.floatValue();
						nm = matrix.getAsNumber( 5 );
						if ( nm != null )
							coy = nm.floatValue();
					}
					app.addTemplateReference( iconReference, PdfName.FRM, icx, 0, 0, icy, xpos - cox * icx, ypos - coy * icy );
				}
				app.restoreState();
			}
			if ( !isNaN( textX ) )
			{
				app.saveState();
				app.rectangle( offX, offX, box.width - 2 * offX, box.height - 2 * offX );
				app.clip();
				app.newPath();
				if ( textColor == null )
					app.resetFill();
				else
					app.setColorFill( textColor );
				app.beginText();
				app.setFontAndSize( ufont, fsize );
				app.setTextMatrix( textX, textY );
				app.showText( text );
				app.endText();
				app.restoreState();
			}
			return app;
		}

		public function get iconFitToBounds(): Boolean
		{
			return _iconFitToBounds;
		}

		/**
		 * If <code>true</code> the icon will be scaled to fit fully within the bounds of the annotation,
		 * if <code>false</code> the border width will be taken into account. The default
		 * is <code>false</code>.
		 * @param value if <code>true</code> the icon will be scaled to fit fully within the bounds of the annotation,
		 * if <code>false</code> the border width will be taken into account
		 */
		public function set iconFitToBounds( value: Boolean ): void
		{
			_iconFitToBounds = value;
		}

		public function get iconHorizontalAdjustment(): Number
		{
			return _iconHorizontalAdjustment;
		}

		/**
		 * A number between 0 and 1 indicating the fraction of leftover space to allocate at the left of the icon.
		 * A value of 0 positions the icon at the left of the annotation rectangle.
		 * A value of 0.5 centers it within the rectangle. The default is 0.5.
		 * @param value a number between 0 and 1 indicating the fraction of leftover space to allocate at the left of the icon
		 */
		public function set iconHorizontalAdjustment( value: Number ): void
		{
			if ( value < 0 )
				value = 0;
			else if ( value > 1 )
				value = 1;
			_iconHorizontalAdjustment = value;
		}

		public function get iconReference(): PRIndirectReference
		{
			return _iconReference;
		}

		/**
		 * Sets the reference to an existing icon.
		 * @param value the reference to an existing icon
		 */
		public function set iconReference( value: PRIndirectReference ): void
		{
			_iconReference = value;
		}

		public function get iconVerticalAdjustment(): Number
		{
			return _iconVerticalAdjustment;
		}

		/**
		 * A number between 0 and 1 indicating the fraction of leftover space to allocate at the bottom of the icon.
		 * A value of 0 positions the icon at the bottom of the annotation rectangle.
		 * A value of 0.5 centers it within the rectangle. The default is 0.5.
		 * @param value a number between 0 and 1 indicating the fraction of leftover space to allocate at the bottom of the icon
		 */
		public function set iconVerticalAdjustment( value: Number ): void
		{
			if ( value < 0 )
				value = 0;
			else if ( value > 1 )
				value = 1;
			_iconVerticalAdjustment = value;
		}

		public function get image(): ImageElement
		{
			return _image;
		}

		public function set image( value: ImageElement ): void
		{
			_image = value;
			_template = null;
		}

		public function get layout(): int
		{
			return _layout;
		}

		/**
		 * Sets the icon and label layout. Possible values are <code>LAYOUT_LABEL_ONLY</code>,
		 * <code>LAYOUT_ICON_ONLY</code>, <code>LAYOUT_ICON_TOP_LABEL_BOTTOM</code>,
		 * <code>LAYOUT_LABEL_TOP_ICON_BOTTOM</code>, <code>LAYOUT_ICON_LEFT_LABEL_RIGHT</code>,
		 * <code>LAYOUT_LABEL_LEFT_ICON_RIGHT</code> and <code>LAYOUT_LABEL_OVER_ICON</code>.
		 * The default is <code>LAYOUT_LABEL_ONLY</code>.
		 * @param layout New value of property layout.
		 * @throws ArgumentError
		 */
		public function set layout( value: int ): void
		{
			if ( value < LAYOUT_LABEL_ONLY || value > LAYOUT_LABEL_OVER_ICON )
				throw new ArgumentError( "layout out of bounds" );
			_layout = value;
		}

		public function get proportionalIcon(): Boolean
		{
			return _proportionalIcon;
		}

		/**
		 * Sets the way the icon is scaled. If true the icon is scaled proportionally,
		 * if false the scaling is done anamorphicaly.
		 * @param proportionalIcon the way the icon is scaled
		 */
		public function set proportionalIcon( value: Boolean ): void
		{
			_proportionalIcon = value;
		}

		public function get scaleIcon(): int
		{
			return _scaleIcon;
		}

		/**
		 * Sets the way the icon will be scaled. Possible values are
		 * <code>SCALE_ICON_ALWAYS</code>, <code>SCALE_ICON_NEVER</code>,
		 * <code>SCALE_ICON_IS_TOO_BIG</code> and <code>SCALE_ICON_IS_TOO_SMALL</code>.
		 * The default is <code>SCALE_ICON_ALWAYS</code>.
		 * @param scaleIcon the way the icon will be scaled
		 */
		public function set scaleIcon( value: int ): void
		{
			if ( value < SCALE_ICON_ALWAYS || value > SCALE_ICON_IS_TOO_SMALL )
				value = SCALE_ICON_ALWAYS;
			_scaleIcon = value;
		}

		public function get template(): PdfTemplate
		{
			return _template;
		}

		public function set template( value: PdfTemplate ): void
		{
			_template = value;
			_image = null;
		}

		private function calculateFontSize( w: Number, h: Number ): Number
		{
			var ufont: BaseFont = getRealFont();
			var fsize: Number = fontSize;
			if ( fsize == 0 )
			{
				var bw: Number = ufont.getWidthPoint( text, 1 );
				if ( bw == 0 )
					fsize = 12;
				else
					fsize = w / bw;
				var nfsize: Number = h / ( 1 - ufont.getFontDescriptor( BaseFont.DESCENT, 1 ) );
				fsize = Math.min( fsize, nfsize );
				if ( fsize < 4 )
					fsize = 4;
			}
			return fsize;
		}
	}
}