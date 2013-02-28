/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Annotation.as 399 2011-01-16 08:56:15Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 399 $ $LastChangedDate: 2011-01-16 03:56:15 -0500 (Sun, 16 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Annotation.as $
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
	
	import org.purepdf.errors.DocumentError;
	import org.purepdf.pdf.PdfName;

	public class Annotation implements IElement
	{
		public static const APPLICATION: String = "application";
		public static const CONTENT: String = "content";
		public static const DEFAULTDIR: String = "defaultdir";
		public static const DESTINATION: String = "destination";
		public static const FILE: String = "file";
		public static const FILE_DEST: int = 3;
		public static const FILE_PAGE: int = 4;
		public static const LAUNCH: int = 6;
		public static const LLX: String = "llx";
		public static const LLY: String = "lly";
		public static const MIMETYPE: String = "mime";
		public static const NAMED: String = "named";
		public static const NAMED_DEST: int = 5;
		public static const OPERATION: String = "operation";
		public static const PAGE: String = "page";
		public static const PARAMETERS: String = "parameters";
		public static const SCREEN: int = 7;
		public static const TEXT: int = 0;
		public static const TITLE: String = "title";
		public static const URL: String = "url";
		public static const URL_AS_STRING: int = 2;
		public static const URL_NET: int = 1;
		public static const URX: String = "urx";
		public static const URY: String = "ury";
		protected var _annotationAttributes: HashMap = new HashMap();
		protected var _annotationtype: int;
		protected var _llx: Number = NaN;
		protected var _lly: Number = NaN;
		protected var _urx: Number = NaN;
		protected var _ury: Number = NaN;
		
		public function Annotation( annot: Annotation = null )
		{
			if( annot != null )
			{
				_annotationtype = annot._annotationtype;
				_annotationAttributes = annot._annotationAttributes;
				setDimensions( annot.llx, annot.llx, annot.urx, annot.ury );
			}
		}
		
		public function process( listener: IElementListener ): Boolean
		{
			try 
			{
				return listener.addElement( this );
			} catch ( de: DocumentError )
			{}
			return false;
		}

		
		public function get isNestable(): Boolean
		{
			return true;
		}
		
		public function get isContent(): Boolean
		{
			return true;
		}
		
		public function toString(): String
		{
			return "[Annotation]";
		}
		
		public function get type(): int
		{
			return Element.ANNOTATION;
		}
		
		public function getChunks(): Vector.<Object>
		{
			return new Vector.<Object>();
		}

		public function get annotationtype(): int
		{
			return _annotationtype;
		}

		public function get attributes(): HashMap
		{
			return _annotationAttributes;
		}

		public function get llx(): Number
		{
			return _llx;
		}

		public function get lly(): Number
		{
			return _lly;
		}
		
		public function getLlx( def: Number ): Number
		{
			if( isNaN( _llx ) )
				return def;
			return _llx;
		}
		
		public function getLly( def: Number ): Number
		{
			if( isNaN( _lly ) )
				return def;
			return _lly;
		}
		
		public function getUrx( def: Number ): Number
		{
			if( isNaN( _urx ) )
				return def;
			return _urx;
		}
		
		public function getUry( def: Number ): Number
		{
			if( isNaN( _ury ) )
				return def;
			return _ury;
		}

		public function setDimensions( $llx: Number, $lly: Number, $urx: Number, $ury: Number ): void
		{
			_llx = $llx;
			_lly = $lly;
			_urx = $urx;
			_ury = $ury;
		}

		public function get urx(): Number
		{
			return _urx;
		}

		public function get ury(): Number
		{
			return _ury;
		}
		
		/**
		 * Returns the title of this <CODE>Annotation</CODE>.
		 * @return a name
		 */
		public function get title(): String
		{
			var s: Object = _annotationAttributes.getValue( TITLE );
			if( s == null )
				return "";
			return s.toString();
		}
		
		/**
		 * Gets the content of this <CODE>Annotation</CODE>.
		 * @return a reference
		 */
		public function get content(): String
		{
			var s: Object = _annotationAttributes.getValue( CONTENT );
			if( s == null )
				return "";
			return s.toString();
		}
		
		
		// 
		// STATIC Initializers
		//
		
		/**
		 * Creates a Screen annotation to embed media clips
		 * 
		 * @param moviePath
		 *            path to the media clip file
		 * @param mimeType
		 *            mime type of the media
		 * @param showOnDisplay
		 *            if true play on display of the page
		 */
		public static function createScreen( moviePath: String, mimeType: String, showOnDisplay: Boolean ): Annotation
		{
			var annot: Annotation = new Annotation( null );
			annot._annotationtype = SCREEN;
			annot._annotationAttributes.put( FILE, moviePath );
			annot._annotationAttributes.put( MIMETYPE, mimeType );
			annot._annotationAttributes.put( PARAMETERS, Vector.<Boolean>( [ false /* embedded */, showOnDisplay ] ) );
			return annot;
		}
		
		/**
		 * Constructs an <CODE>Annotation</CODE>.
		 * 
		 * @param named
		 *            a named destination in this file
		 */
		public static function createNamed( named: int ): Annotation
		{
			var annot: Annotation = new Annotation( null );
			annot._annotationtype = NAMED_DEST;
			annot._annotationAttributes.put( NAMED, named );
			return annot;
		}
		
		/**
		 * Constructs an <CODE>Annotation</CODE> with a certain title and some
		 * text.
		 * 
		 * @param title
		 *            the title of the annotation
		 * @param text
		 *            the content of the annotation
		 */
		public static function createString( title: String, content: String ): Annotation
		{
			var annot: Annotation = new Annotation(null);
			annot._annotationtype = TEXT;
			annot._annotationAttributes.put( TITLE, title );
			annot._annotationAttributes.put( CONTENT, content );
			return annot;
		}
		
		/**
		 * Constructs an <CODE>Annotation</CODE>.
		 * 
		 * @param url
		 *            the external reference
		 */
		public static function createUrl( url: String ): Annotation
		{
			var annot: Annotation = new Annotation(null);
			annot._annotationtype = URL_AS_STRING;
			annot._annotationAttributes.put( FILE, url );
			return annot;
		}
		
	}
}