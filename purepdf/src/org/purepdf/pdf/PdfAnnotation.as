/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfAnnotation.as 299 2010-02-07 15:47:43Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 299 $ $LastChangedDate: 2010-02-07 10:47:43 -0500 (Sun, 07 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfAnnotation.as $
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
	import flash.utils.ByteArray;
	
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.colors.ExtendedColor;
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.pdf_core;

	public class PdfAnnotation extends PdfDictionary
	{
		public static const AA_BLUR: PdfName = PdfName.BL;
		public static const AA_DOWN: PdfName = PdfName.D;
		public static const AA_ENTER: PdfName = PdfName.E;
		public static const AA_EXIT: PdfName = PdfName.X;
		public static const AA_FOCUS: PdfName = PdfName.FO;
		public static const AA_JS_CHANGE: PdfName = PdfName.V;
		public static const AA_JS_FORMAT: PdfName = PdfName.F;
		public static const AA_JS_KEY: PdfName = PdfName.K;
		public static const AA_JS_OTHER_CHANGE: PdfName = PdfName.C;
		public static const AA_UP: PdfName = PdfName.U;
		public static const APPEARANCE_DOWN: PdfName = PdfName.D;
		public static const APPEARANCE_NORMAL: PdfName = PdfName.N;
		public static const APPEARANCE_ROLLOVER: PdfName = PdfName.R;
		public static const FLAGS_HIDDEN: int = 2;
		public static const FLAGS_INVISIBLE: int = 1;
		public static const FLAGS_LOCKED: int = 128;
		public static const FLAGS_NOROTATE: int = 16;
		public static const FLAGS_NOVIEW: int = 32;
		public static const FLAGS_NOZOOM: int = 8;
		public static const FLAGS_PRINT: int = 4;
		public static const FLAGS_READONLY: int = 64;
		public static const FLAGS_TOGGLENOVIEW: int = 256;
		public static const HIGHLIGHT_INVERT: PdfName = PdfName.I;
		public static const HIGHLIGHT_NONE: PdfName = PdfName.N;
		public static const HIGHLIGHT_OUTLINE: PdfName = PdfName.O;
		public static const HIGHLIGHT_PUSH: PdfName = PdfName.P;
		public static const HIGHLIGHT_TOGGLE: PdfName = PdfName.T;
		public static const MARKUP_HIGHLIGHT: int = 0;
		public static const MARKUP_SQUIGGLY: int = 3;
		public static const MARKUP_STRIKEOUT: int = 2;
		public static const MARKUP_UNDERLINE: int = 1;

		protected var _form: Boolean = false;
		protected var _placeInPage: int = -1;
		protected var _writer: PdfWriter;
		protected var reference: PdfIndirectReference;
		protected var used: Boolean = false;
		internal var _annotation: Boolean = true;
		internal var _templates: HashMap;

		public function PdfAnnotation( $writer: PdfWriter, rect: RectangleElement = null, action: PdfAction = null )
		{
			_writer = $writer;

			if ( rect != null )
			{
				if ( action != null )
				{
					put( PdfName.SUBTYPE, PdfName.LINK );
					put( PdfName.RECT, PdfRectangle.createFromRectangle( rect ) );
					put( PdfName.A, action );
					put( PdfName.BORDER, new PdfBorderArray( 0, 0, 0 ) );
					put( PdfName.C, new PdfColor( 0x00, 0x00, 0xFF ) );
				} else
				{
					put( PdfName.RECT, PdfRectangle.createFromRectangle( rect ) );
				}
			}
		}

		public function set action( action: PdfAction ): void
		{
			put( PdfName.A, action );
		}

		public function get annotation(): Boolean
		{
			return _annotation;
		}

		public function set annotation( value: Boolean ): void
		{
			_annotation = value;
		}

		public function set appearanceState( state: String ): void
		{
			if ( state == null )
			{
				remove( PdfName.AS );
				return;
			}
			put( PdfName.AS, new PdfName( state ) );
		}

		public function set borderStyle( border: PdfBorderDictionary ): void
		{
			put( PdfName.BS, border );
		}

		public function set defaultAppearanceString( cb: PdfContentByte ): void
		{
			var b: Bytes = cb.getInternalBuffer().toByteArray();
			var len: int = b.length;

			for ( var k: int = 0; k < len; ++k )
			{
				if ( b[k] == 10 )
					b[k] = 32;
			}
			put( PdfName.DA, new PdfString( b ) );
		}

		public function set flags( flags: int ): void
		{
			if ( flags == 0 )
				remove( PdfName.F );
			else
				put( PdfName.F, new PdfNumber( flags ) );
		}

		public function get form(): Boolean
		{
			return _form;
		}

		public function set form( value: Boolean ): void
		{
			_form = value;
		}

		public function getUsed(): Boolean
		{
			return used;
		}
		
		public function set color( value: RGBColor ): void
		{
			put( PdfName.C, PdfColor.create( value ) );
		}

		/**
		 * Returns an indirect reference to the annotation
		 * @return the indirect reference
		 */
		public function get indirectReference(): PdfIndirectReference
		{
			if ( reference == null )
			{
				reference = _writer.pdfIndirectReference;
			}
			return reference;
		}

		public function get isAnnotation(): Boolean
		{
			return _annotation;
		}

		public function get isForm(): Boolean
		{
			return _form;
		}

		public function set mkBackgroundColor( color: RGBColor ): void
		{
			if ( color == null )
				mk.remove( PdfName.BG );
			else
				mk.put( PdfName.BG, getMKColor( color ) );
		}

		public function set mkBorderColor( color: RGBColor ): void
		{
			if ( color == null )
				mk.remove( PdfName.BC );
			else
				mk.put( PdfName.BC, getMKColor( color ) );
		}

		public function set mkRotation( value: int ): void
		{
			mk.put( PdfName.R, new PdfNumber( value ) );
		}

		public function get placeInPage(): int
		{
			return _placeInPage;
		}

		public function set popup( popup: PdfAnnotation ): void
		{
			put( PdfName.POPUP, popup.indirectReference );
			popup.put( PdfName.PARENT, indirectReference );
		}

		public function setAdditionalActions( key: PdfName, action: PdfAction ): void
		{
			var dic: PdfDictionary;
			var obj: PdfObject = getValue( PdfName.AA );
			if ( obj != null && obj.isDictionary() )
				dic = PdfDictionary( obj );
			else
				dic = new PdfDictionary();
			dic.put( key, action );
			put( PdfName.AA, dic );
		}

		public function setAppearance( ap: PdfName, template: PdfTemplate ): void
		{
			var dic: PdfDictionary = getValue( PdfName.AP ) as PdfDictionary;

			if ( dic == null )
				dic = new PdfDictionary();
			dic.put( ap, template.indirectReference );
			put( PdfName.AP, dic );

			if ( !form )
				return;

			if ( templates == null )
				templates = new HashMap();
			templates.put( template, null );
		}

		public function setAppearanceState( ap: PdfName, state: String, template: PdfTemplate ): void
		{
			var dicAp: PdfDictionary = getValue( PdfName.AP ) as PdfDictionary;

			if ( dicAp == null )
				dicAp = new PdfDictionary();
			var dic: PdfDictionary;
			var obj: PdfObject = dicAp.getValue( ap ) as PdfObject;

			if ( obj != null && obj.isDictionary() )
				dic = PdfDictionary( obj );
			else
				dic = new PdfDictionary();
			dic.put( new PdfName( state ), template.indirectReference );
			dicAp.put( ap, dic );
			put( PdfName.AP, dicAp );

			if ( !form )
				return;

			if ( templates == null )
				templates = new HashMap();
			templates.put( template, null );
		}

		public function setPage(): void
		{
			put( PdfName.P, writer.getCurrentPage() );
		}

		public function setUsed(): void
		{
			used = true;
		}

		public function get templates(): HashMap
		{
			return _templates;
		}

		public function set templates( value: HashMap ): void
		{
			_templates = value;
		}

		public function get writer(): PdfWriter
		{
			return _writer;
		}

		public function set writer( $writer: PdfWriter ): void
		{
			_writer = $writer;
		}

		protected function get mk(): PdfDictionary
		{
			var m: PdfDictionary = getValue( PdfName.MK ) as PdfDictionary;

			if ( m == null )
			{
				m = new PdfDictionary();
				put( PdfName.MK, m );
			}
			return m;
		}

		/**
		 *
		 * @param writer
		 * @param llx
		 * @param lly
		 * @param urx
		 * @param ury
		 * @param action
		 * @return
		 */
		public static function createAction( writer: PdfWriter, rect: RectangleElement, action: PdfAction ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer );
			annot.put( PdfName.SUBTYPE, PdfName.LINK );
			annot.put( PdfName.RECT, PdfRectangle.createFromRectangle( rect ) );
			annot.put( PdfName.A, action );
			annot.put( PdfName.BORDER, new PdfBorderArray( 0, 0, 0 ) );
			annot.put( PdfName.C, new PdfColor( 0x00, 0x00, 0xFF ) );
			return annot;
		}

		/**
		 * Creates a file attachment annotation.
		 * @param writer
		 * @param rect the dimensions in the page of the annotation
		 * @param contents the file description
		 * @param fileStore <code>ByteArray</code> of the file contents
		 * @param fileDisplay the actual file name stored in the pdf
		 *
		 * @return the annotation
		 */
		public static function createFileAttachment( writer: PdfWriter, rect: RectangleElement, contents: String, fileStore: ByteArray, fileDisplay: String ): PdfAnnotation
		{
			return _createFileAttachment( writer, rect, contents, PdfFileSpecification.fileEmbedded( writer, fileDisplay, fileStore, true ) );
		}

		/**
		 * Adds a line to the document. Move over the line and a tooltip is shown.
		 * @param writer
		 * @param rect
		 * @param contents
		 * @param x1
		 * @param y1
		 * @param x2
		 * @param y2
		 * @return A PdfAnnotation
		 */
		public static function createLine( writer: PdfWriter, rect: RectangleElement, contents: String, x1: Number, y1: Number, x2: Number, y2: Number ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer, rect );
			annot.put( PdfName.SUBTYPE, PdfName.LINE );
			annot.put( PdfName.CONTENTS, new PdfString( contents, PdfObject.TEXT_UNICODE ) );
			var array: PdfArray = new PdfArray( new PdfNumber( x1 ) );
			array.add( new PdfNumber( y1 ) );
			array.add( new PdfNumber( x2 ) );
			array.add( new PdfNumber( y2 ) );
			annot.put( PdfName.L, array );
			return annot;
		}

		/**
		 * Creates an Annotation with an Action.
		 * @param writer
		 * @param rect
		 * @param highlight
		 * @param action
		 * @return A PdfAnnotation
		 */
		public static function createLink( writer: PdfWriter, rect: RectangleElement, highlight: PdfName, action: PdfAction ): PdfAnnotation
		{
			var annot: PdfAnnotation = _createLink( writer, rect, highlight );
			annot.putEx( PdfName.A, action );
			return annot;
		}

		/**
		 * Creates an Annotation with an local destination.
		 * @param writer
		 * @param rect
		 * @param highlight
		 * @param namedDestination
		 * @return A PdfAnnotation
		 */
		public static function createLink2( writer: PdfWriter, rect: RectangleElement, highlight: PdfName, namedDestination: String ): PdfAnnotation
		{
			var annot: PdfAnnotation = _createLink( writer, rect, highlight );
			annot.put( PdfName.DEST, new PdfString( namedDestination ) );
			return annot;
		}

		/**
		 * Creates an Annotation with a PdfDestination.
		 * @param writer
		 * @param rect
		 * @param highlight
		 * @param page
		 * @param dest
		 * @return A PdfAnnotation
		 */
		public static function createLink3( writer: PdfWriter, rect: RectangleElement, highlight: PdfName, page: int, dest: PdfDestination ): PdfAnnotation
		{
			var annot: PdfAnnotation = _createLink( writer, rect, highlight );
			var ref: PdfIndirectReference = writer.getPageReference( page );
			dest.addPage( ref );
			annot.put( PdfName.DEST, dest );
			return annot;
		}

		/**
		 * Adds a popup to your document.
		 * @param writer
		 * @param rect
		 * @param contents
		 * @param open
		 * @return A PdfAnnotation
		 */
		public static function createPopup( writer: PdfWriter, rect: RectangleElement, contents: String, open: Boolean ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer, rect );
			annot.put( PdfName.SUBTYPE, PdfName.POPUP );
			if ( contents != null )
				annot.put( PdfName.CONTENTS, new PdfString( contents, PdfObject.TEXT_UNICODE ) );
			if ( open )
				annot.put( PdfName.OPEN, PdfBoolean.PDF_TRUE );
			return annot;
		}

		/**
		 * Creates a screen PdfAnnotation
		 * @param writer
		 * @param rect
		 * @param clipTitle
		 * @param fs
		 * @param mimeType
		 * @param playOnDisplay
		 * @return a screen PdfAnnotation
		 * @throws IOError
		 */
		public static function createScreen( writer: PdfWriter, rect: RectangleElement, clipTitle: String, fs: PdfFileSpecification, mimeType: String,
				playOnDisplay: Boolean ): PdfAnnotation
		{
			var ann: PdfAnnotation = new PdfAnnotation( writer, rect );
			ann.put( PdfName.SUBTYPE, PdfName.SCREEN );
			ann.put( PdfName.F, new PdfNumber( FLAGS_PRINT ) );
			ann.put( PdfName.TYPE, PdfName.ANNOT );
			ann.setPage();
			var ref: PdfIndirectReference = ann.indirectReference;
			var action: PdfAction = PdfAction.rendition( clipTitle, fs, mimeType, ref );
			var actionRef: PdfIndirectReference = writer.pdf_core::addToBody( action ).indirectReference;

			if ( playOnDisplay )
			{
				var aa: PdfDictionary = new PdfDictionary();
				aa.put( new PdfName( "PV" ), actionRef );
				ann.put( PdfName.AA, aa );
			}
			ann.put( PdfName.A, actionRef );
			return ann;
		}

		/**
		 * Adds a circle or a square that shows a tooltip when you pass over it.
		 * @param writer
		 * @param rect
		 * @param contents The tooltip
		 * @param square true if you want a square, false if you want a circle
		 * @return A PdfAnnotation
		 */
		public static function createSquareCircle( writer: PdfWriter, rect: RectangleElement, contents: String, square: Boolean ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer, rect );
			if ( square )
				annot.put( PdfName.SUBTYPE, PdfName.SQUARE );
			else
				annot.put( PdfName.SUBTYPE, PdfName.CIRCLE );
			annot.put( PdfName.CONTENTS, new PdfString( contents, PdfObject.TEXT_UNICODE ) );
			return annot;
		}

		public static function createText( writer: PdfWriter, rect: RectangleElement, title: String, contents: String, opened: Boolean, icon: String ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer, rect );
			annot.put( PdfName.SUBTYPE, PdfName.TEXT );

			if ( title != null )
				annot.put( PdfName.T, new PdfString( title, PdfObject.TEXT_UNICODE ) );

			if ( contents != null )
				annot.put( PdfName.CONTENTS, new PdfString( contents, PdfObject.TEXT_UNICODE ) );

			if ( opened )
				annot.put( PdfName.OPEN, PdfBoolean.PDF_TRUE );

			if ( icon != null )
				annot.put( PdfName.NAME, new PdfName( icon ) );
			return annot;
		}

		public static function getMKColor( color: RGBColor ): PdfArray
		{
			var array: PdfArray = new PdfArray();
			var type: int = ExtendedColor.getType( color );

			switch ( type )
			{
				case ExtendedColor.TYPE_GRAY:
					array.add( new PdfNumber( GrayColor( color ).gray ) );
					break;
				case ExtendedColor.TYPE_CMYK:
					var cmyk: CMYKColor = CMYKColor( color );
					array.add( new PdfNumber( cmyk.cyan ) );
					array.add( new PdfNumber( cmyk.magenta ) );
					array.add( new PdfNumber( cmyk.yellow ) );
					array.add( new PdfNumber( cmyk.black ) );
					break;
				case ExtendedColor.TYPE_SEPARATION:
				case ExtendedColor.TYPE_PATTERN:
				case ExtendedColor.TYPE_SHADING:
					throw new RuntimeError( "separations patterns and shadings not.allowed in mk dictionary" );
					break;
				default:
					array.add( new PdfNumber( color.red / 255 ) );
					array.add( new PdfNumber( color.green / 255 ) );
					array.add( new PdfNumber( color.blue / 255 ) );
			}
			return array;
		}

		/**
		 * Creates a link.
		 * @param writer
		 * @param rect
		 * @param highlight
		 * @return A PdfAnnotation
		 */
		protected static function _createLink( writer: PdfWriter, rect: RectangleElement, highlight: PdfName ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer, rect );
			annot.put( PdfName.SUBTYPE, PdfName.LINK );
			if ( !highlight.equals( HIGHLIGHT_INVERT ) )
				annot.put( PdfName.H, highlight );
			return annot;
		}

		private static function _createFileAttachment( writer: PdfWriter, rect: RectangleElement, contents: String, fs: PdfFileSpecification ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation( writer, rect );
			annot.put( PdfName.SUBTYPE, PdfName.FILEATTACHMENT );
			if ( contents != null )
				annot.put( PdfName.CONTENTS, new PdfString( contents, PdfObject.TEXT_UNICODE ) );
			annot.put( PdfName.FS, fs.reference );
			return annot;
		}
		
		/**
		 * Add some free text to the document.
		 * @param writer
		 * @param rect
		 * @param contents
		 * @param defaultAppearance
		 * @return A PdfAnnotation
		 */
		public static function createFreeText(writer: PdfWriter, rect: RectangleElement, contents: String, defaultAppearance: PdfContentByte ): PdfAnnotation
		{
			var annot: PdfAnnotation = new PdfAnnotation(writer, rect);
			annot.put(PdfName.SUBTYPE, PdfName.FREETEXT);
			annot.put(PdfName.CONTENTS, new PdfString(contents, PdfObject.TEXT_UNICODE));
			annot.defaultAppearanceString = defaultAppearance;
			return annot;
		}
	}
}