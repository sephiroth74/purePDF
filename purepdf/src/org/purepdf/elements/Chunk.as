/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Chunk.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Chunk.as $
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
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.Font;
	import org.purepdf.ISplitCharacter;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.Utilities;

	public class Chunk implements IElement
	{

		public static const ACTION: String = "ACTION";
		public static const BACKGROUND: String = "BACKGROUND";
		public static const CHAR_SPACING: String = "CHAR_SPACING";
		public static const COLOR: String = "COLOR";
		public static const ENCODING: String = "ENCODING";
		public static const GENERICTAG: String = "GENERICTAG";
		public static const HSCALE: String = "HSCALE";
		public static const HYPHENATION: String = "HYPHENATION";
		public static const IMAGE: String = "IMAGE";
		public static const LOCALDESTINATION: String = "LOCALDESTINATION";
		public static const LOCALGOTO: String = "LOCALGOTO";
		public static const NEWLINE: Chunk = new Chunk( "\n", new Font() );
		public static const NEWPAGE: String = "NEWPAGE";
		public static const OBJECT_REPLACEMENT_CHARACTER: String = "\ufffc";
		public static const PDFANNOTATION: String = "PDFANNOTATION";
		public static const REMOTEGOTO: String = "REMOTEGOTO";
		public static const SEPARATOR: String = "SEPARATOR";
		public static const SKEW: String = "SKEW";
		public static const SPLITCHARACTER: String = "SPLITCHARACTER";
		public static const SUBSUPSCRIPT: String = "SUBSUPSCRIPT";
		public static const TAB: String = "TAB";
		public static const TEXTRENDERMODE: String = "TEXTRENDERMODE";
		public static const UNDERLINE: String = "UNDERLINE";
		public static var _NEXTPAGE: Chunk;

		protected var _attributes: HashMap = null;
		protected var _content: String;
		protected var _font: Font;

		public function Chunk( content: String, font: Font=null )
		{
			super();
			_content = content;
			_font = font != null ? font : new Font();
		}
		
		// TODO: implements a clone method in ImageElement
		public static function fromImage( image: ImageElement, offsetX: Number, offsetY: Number ): Chunk 
		{
			var result: Chunk = new Chunk( OBJECT_REPLACEMENT_CHARACTER, new Font() );
			var copyImage: ImageElement = ImageElement.getImageInstance(image);// = Image.getInstance( image );
			copyImage.setAbsolutePosition( Number.NaN, Number.NaN );
			result.setAttribute( IMAGE, Vector.<Object>([ copyImage, offsetX, offsetY, false ]) );
			return result;
		}
		
		public function append( value: String ): String
		{
			_content += value;
			return _content;
		}

		public function get attributes(): HashMap
		{
			return _attributes;
		}

		public function set attributes( value: HashMap ): void
		{
			_attributes = value;
		}

		public function get content(): String
		{
			return _content;
		}

		public function get font(): Font
		{
			return _font;
		}

		public function set font( value: Font ): void
		{
			_font = value;
		}

		public function getChunks(): Vector.<Object>
		{
			var tmp: Vector.<Object> = new Vector.<Object>();
			tmp.push( this );
			return tmp;
		}
		
		public function getImage(): ImageElement
		{
			if( _attributes == null )
				return null;
			
			var obj: Vector.<Object> = _attributes.getValue(Chunk.IMAGE) as Vector.<Object>;
			if (obj == null)
				return null;
			else {
				return ImageElement( obj[0] );
			}
		}
		
		/**
		 * Gets the width of the Chunk in points.
		 * 
		 * @return a width in points
		 */
		public function getWidthPoint(): Number
		{
			if( getImage() != null )
				return getImage().scaledWidth;
			
			return font.getCalculatedBaseFont( true ).getWidthPoint(_content, font.getCalculatedSize()) * getHorizontalScaling();
		}

		/**
		 * Gets the text displacement relative to the baseline
		 */
		public function getTextRise(): Number
		{
			if ( _attributes != null && _attributes.containsKey( SUBSUPSCRIPT ) )
			{
				var f: Number = Number( _attributes.getValue( SUBSUPSCRIPT ) );
				return f;
			}
			return 0;
		}

		public function get hasAttributes(): Boolean
		{
			return _attributes != null;
		}

		public function get isContent(): Boolean
		{
			return true;
		}

		public function get isEmpty(): Boolean
		{
			return ( StringUtils.trim( _content.toString() ).length == 0 ) && ( _content.toString().indexOf( "\n" ) == -1 ) && ( _attributes
				== null );
		}

		public function get isNestable(): Boolean
		{
			return true;
		}

		public function process( listener: IElementListener ): Boolean
		{
			try
			{
				return listener.addElement( this );
			}
			catch ( de: Error )
			{
				//return false;
				throw de;
			}
			return false;
		}
		
		/**
		 * Sets the generic tag Chunk.
		 * The text for this tag can be retrieved with ChunkEvent.
		 * 
		 * @see org.purepdf.events.ChunkEvent
		 */
		
		public function setGenericTag( text: String ): Chunk
		{
			return setAttribute( GENERICTAG, text );
		}
		
		/**
		 * Sets the text rendering mode. It can outline text, simulate bold and make
		 * text invisible.
		 * 
		 * @param mode	It can be PdfContentByte.TEXT_RENDER_MODE_FILL,
		 *            PdfContentByte.TEXT_RENDER_MODE_STROKE,
		 *            PdfContentByte.TEXT_RENDER_MODE_FILL_STROKE
		 *            and PdfContentByte.TEXT_RENDER_MODE_INVISIBLE
		 *            .
		 * @param strokeWidth
		 *            the stroke line width for the modes PdfContentByte.TEXT_RENDER_MODE_STROKE
		 *            and PdfContentByte.TEXT_RENDER_MODE_FILL_STROKE
		 * 
		 * @see org.purepdf.pdf.PdfContentByte
		 */
		public function setTextRenderMode( mode: int, strokeWidth: Number, strokeColor: RGBColor ): Chunk
		{
			return setAttribute( TEXTRENDERMODE, Vector.<Object>([ mode, strokeWidth, strokeColor]) );
		}

		public function setAnchor( url: String ): Chunk
		{
			return setAttribute( ACTION, PdfAction.fromURL( url ) );
		}
		
		public function setAction( action: PdfAction ): Chunk
		{
			return setAttribute( ACTION, action );
		}

		public function setAttribute( name: String, obj: Object ): Chunk
		{
			if ( _attributes == null )
				_attributes = new HashMap();
			_attributes.put( name, obj );
			return this;
		}
		
		public function setAnnotation( annotation: PdfAnnotation ): Chunk
		{
			return setAttribute( PDFANNOTATION, annotation );
		}
		
		/**
		 * Skews the text to simulate italic and other effects
		 * @param alpha	the first angle in degrees
		 * @param beta	the second angle in degrees
		 */
		public function setSkew( alpha: Number, beta: Number ): Chunk
		{
			alpha = Math.tan(alpha * Math.PI / 180);
			beta = Math.tan(beta * Math.PI / 180);
			return setAttribute(SKEW, Vector.<Number>([ alpha, beta ]) );
		}

		/**
		 * Set the color and size of the background color for this
		 * chunk element
		 *
		 */
		public function setBackground( color: RGBColor, extraLeft: Number=0, extraBottom: Number=0, extraRight: Number=0, extraTop: Number
			=0 ): Chunk
		{
			return setAttribute( BACKGROUND, Vector.<Object>( [ color, Vector.<Number>( [ extraLeft, extraBottom, extraRight, extraTop ] ) ] ) );
		}


		public function setLocalDestination( name: String ): Chunk
		{
			return setAttribute( LOCALDESTINATION, name );
		}

		public function setLocalGoto( name: String ): Chunk
		{
			return setAttribute( LOCALGOTO, name );
		}

		public function setNewPage(): Chunk
		{
			return setAttribute( NEWPAGE, null );
		}

		public function setTextRise( rise: Number ): Chunk
		{
			return setAttribute( SUBSUPSCRIPT, rise );
		}
		
		/**
		 * Sets the text horizontal scaling. A value of 1 is normal and a value of
		 * 0.5f shrinks the text to half it's width.
		 * 
		 */
		public function setHorizontalScaling( scale: Number ): Chunk
		{
			return setAttribute( HSCALE, scale );
		}
		
		public function getHorizontalScaling(): Number 
		{
			if( _attributes == null )
				return 1;
			var f: Object = _attributes.getValue(HSCALE);
			if (f == null)
				return 1;
			return Number(f);
		}

		/**
		 * @param color	the color of the line. null to use text color
		 * @param thickness	the weight of the line
		 * @param thicknessMul	thickness multiplication factor with the font size
		 * @param yPosition	absolute y position relative to the baseline
		 * @param yPositionMul	position multiplication factor with the font size
		 * @param cap	the end line cap. Allowed values are
		 *            PdfContentByte.LINE_CAP_BUTT, PdfContentByte.LINE_CAP_ROUND
		 *            and PdfContentByte.LINE_CAP_PROJECTING_SQUARE
		 *
		 * @see org.purepdf.pdf.PdfContentByte#LINE_CAP_BUTT
		 * @see org.purepdf.pdf.PdfContentByte#LINE_CAP_ROUND
		 * @see org.purepdf.pdf.PdfContentByte#LINE_CAP_PROJECTING_SQUARE
		 */
		public function setUnderline( color: RGBColor=null, thickness: Number=1, thicknessMul: Number=0, yPosition: Number=0, yPositionMul: Number
			=0, cap: int=0 ): Chunk
		{
			if ( _attributes == null )
				_attributes = new HashMap();
			var obj: Vector.<Object> = Vector.<Object>( [ color, Vector.<Number>( [ thickness, thicknessMul, yPosition, yPositionMul, cap ] ) ] );
			var unders: Vector.<Vector.<Object>> = Utilities.addToArray( attributes.getValue( UNDERLINE ) as Vector.<Vector.<Object>>
				, obj );
			return setAttribute( UNDERLINE, unders );
		}
		
		public function setSplitCharacter( value: ISplitCharacter ): Chunk
		{
			return setAttribute( SPLITCHARACTER, value );
		}

		public function toString(): String
		{
			return content;
		}

		public function get type(): int
		{
			return Element.CHUNK;
		}

		public static function get NEXTPAGE(): Chunk
		{
			if ( _NEXTPAGE == null )
			{
				_NEXTPAGE = new Chunk( "" );
				_NEXTPAGE.setNewPage();
			}
			return _NEXTPAGE;
		}
	}
}