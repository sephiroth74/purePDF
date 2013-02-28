/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfTemplate.as 313 2010-02-09 23:55:49Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 313 $ $LastChangedDate: 2010-02-09 18:55:49 -0500 (Tue, 09 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfTemplate.as $
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
	import flash.geom.Matrix;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.interfaces.IPdfOCG;
	import org.purepdf.utils.pdf_core;

	public class PdfTemplate extends PdfContentByte
	{
		public static const TYPE_IMPORTED: int = 2;
		public static const TYPE_PATTERN: int = 3;
		public static const TYPE_TEMPLATE: int = 1;

		protected var _type: int;
		protected var bBox: RectangleElement = new RectangleElement( 0, 0, 0, 0 );
		protected var _group: PdfTransparencyGroup;
		protected var _matrix: PdfArray;
		protected var _pageResources: PageResources;
		protected var thisReference: PdfIndirectReference;
		private var _layer: IPdfOCG;
		
		use namespace pdf_core;

		public function PdfTemplate( $writer: PdfWriter=null )
		{
			super( $writer );
			_type = TYPE_TEMPLATE;

			if ( $writer != null )
			{
				_pageResources = new PageResources();
				_pageResources.addDefaultColor( $writer.getDefaultColorSpace() );
				thisReference = $writer.pdfIndirectReference;
			}
		}


		public function get boundingBox(): RectangleElement
		{
			return bBox;
		}

		public function set boundingBox( value: RectangleElement ): void
		{
			bBox = value;
		}

		public function get height(): Number
		{
			return bBox.height;
		}

		public function set height( value: Number ): void
		{
			bBox.setTop( value );
			bBox.setBottom( 0 );
		}

		public function get layer(): IPdfOCG
		{
			return _layer;
		}

		public function set layer( value: IPdfOCG ): void
		{
			_layer = value;
		}

		public function setMatrixValues( a: Number, b: Number, c: Number, d: Number, tx: Number, ty: Number ): void
		{
			_matrix = new PdfArray();
			_matrix.add( new PdfNumber( a ) );
			_matrix.add( new PdfNumber( b ) );
			_matrix.add( new PdfNumber( c ) );
			_matrix.add( new PdfNumber( d ) );
			_matrix.add( new PdfNumber( tx ) );
			_matrix.add( new PdfNumber( ty ) );
		}
		
		public function setMatrix( value: Matrix ): void
		{
			_matrix = new PdfArray();
			_matrix.add( new PdfNumber( value.a ) );
			_matrix.add( new PdfNumber( value.b ) );
			_matrix.add( new PdfNumber( value.c ) );
			_matrix.add( new PdfNumber( value.d ) );
			_matrix.add( new PdfNumber( value.tx ) );
			_matrix.add( new PdfNumber( value.ty ) );
		}
		
		public function get matrix(): PdfArray
		{
			return _matrix;
		}

		public function get type(): int
		{
			return _type;
		}

		public function get width(): Number
		{
			return bBox.width;
		}

		public function set width( value: Number ): void
		{
			bBox.setLeft( 0 );
			bBox.setRight( value );
		}
		
		public function get indirectReference(): PdfIndirectReference
		{
			if( thisReference == null )
				thisReference = writer.pdfIndirectReference;
			return thisReference;
		}
		
		public function beginVariableText(): void
		{
			content.append_string("/Tx BMC ");
		}
		
		public function endVariableText(): void
		{
			content.append_string("EMC ");
		}
		
		override public function get pageResources(): PageResources
		{
			return _pageResources;
		}
		
		public function set pageResources( value: PageResources ): void
		{
			_pageResources = value;
		}
		
		/**
		 * Constructs the resources used by this template.
		 *
		 * @return the resources used by this template
		 */
		
		public function get resources(): PdfObject {
			return pageResources.getResources();
		}
		
		/**
		 * Gets the stream representing this template.
		 *
		 * @param	compressionLevel	the compressionLevel
		 */
		
		public function getFormXObject( compressionLevel: int ): PdfStream
		{
			return new PdfFormXObject( this, compressionLevel );
		}
		
		override public function duplicate(): PdfContentByte
		{
			var tpl: PdfTemplate = new PdfTemplate( writer );
			tpl.pdf = pdf;
			tpl.thisReference = thisReference;
			tpl._pageResources = pageResources;
			tpl.bBox = RectangleElement.clone( bBox );
			tpl.group = group;
			tpl.layer = layer;
			if (_matrix != null) 
			{
				tpl._matrix = new PdfArray(_matrix);
			}
			tpl.separator = separator;
			return tpl;
		}
		
		public function get group(): PdfTransparencyGroup
		{
			return _group;
		}
		
		public function set group( value: PdfTransparencyGroup ): void
		{
			_group = value;
		}
			

		/**
		 * Creates a new template<br />
		 * Creates a new template that is nothing more than a form XObject
		 *
		 * @param writer the PdfWriter to use
		 * @param width the bounding box width
		 * @param height the bounding box height
		 *
		 */
		public static function createTemplate( writer: PdfWriter, w: Number, h: Number ): PdfTemplate
		{
			return createTemplate2( writer, w, h, null );
		}

		public static function createTemplate2( writer: PdfWriter, w: Number, h: Number, forcedName: PdfName ): PdfTemplate
		{
			var tpl: PdfTemplate = new PdfTemplate( writer );
			tpl.width = w;
			tpl.height = h;
			writer.addDirectTemplateSimple( tpl, forcedName );
			return tpl;
		}
	}
}