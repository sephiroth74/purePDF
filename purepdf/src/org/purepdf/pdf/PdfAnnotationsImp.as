/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfAnnotationsImp.as 394 2011-01-14 18:48:14Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 394 $ $LastChangedDate: 2011-01-14 13:48:14 -0500 (Fri, 14 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfAnnotationsImp.as $
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
	import flash.geom.Rectangle;
	
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.elements.Annotation;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.forms.PdfFormField;
	import org.purepdf.utils.pdf_core;

	public class PdfAnnotationsImp extends ObjectHash
	{
		protected var annotations: Vector.<PdfAnnotation>;
		protected var delayedAnnotations: Vector.<PdfAnnotation> = new Vector.<PdfAnnotation>();
		protected var _acroForm: PdfAcroForm;
		
		use namespace pdf_core;
		
		public function PdfAnnotationsImp( $writer: PdfWriter )
		{
			_acroForm = new PdfAcroForm( $writer );
		}
		
		public function get acroForm():PdfAcroForm
		{
			return _acroForm;
		}

		public function addAnnotation( annot: PdfAnnotation ): void
		{
			if( annot.isForm )
			{
				var field: PdfFormField = annot as PdfFormField;
				if( field.parent == null )
					addFormFieldRaw( field );
			} else
			{
				annotations.push( annot );
			}
		}
		
		public function addPlainAnnotation( annot: PdfAnnotation ): void
		{
			annotations.push( annot );
		}
		
		public function hasUnusedAnnotations(): Boolean
		{
			return !( annotations.length == 0 );
		}
		
		public function resetAnnotations(): void
		{
			annotations = delayedAnnotations;
			delayedAnnotations = new Vector.<PdfAnnotation>();
		}
		
		protected function addFormFieldRaw( field: PdfFormField ): void
		{
			annotations.push( field );
			var kids: Vector.<PdfFormField> = field.kids;
			
			if( kids != null )
			{
				for( var k: int = 0; k < kids.length; ++k )
					addFormFieldRaw( kids[k] as PdfFormField );
			}
		}
		
		internal static function convertAnnotation( writer: PdfWriter, annot: Annotation, defaultRect: RectangleElement ): PdfAnnotation
		{
			var rect: RectangleElement;
			
			switch( annot.annotationtype ) {
				case Annotation.URL_AS_STRING:
					rect = new RectangleElement( annot.llx, annot.lly, annot.urx, annot.ury );
					return new PdfAnnotation(writer, rect, PdfAction.fromURL( annot.attributes.getValue( Annotation.FILE ).toString(), false ) );
				
				case Annotation.FILE_DEST:
					rect = new RectangleElement( annot.llx, annot.lly, annot.urx, annot.ury );
					return PdfAnnotation.createAction( writer, rect, PdfAction.fromFileDestination( annot.attributes.getValue( Annotation.FILE ).toString(), annot.attributes.getValue( Annotation.DESTINATION ).toString() ) );					
					
				case Annotation.NAMED_DEST:
					rect = new RectangleElement( annot.llx, annot.lly, annot.urx, annot.ury );
					return new PdfAnnotation( writer, rect, PdfAction.fromNamed( int(annot.attributes.getValue( Annotation.NAMED ) ) ) );
					
				case Annotation.SCREEN:
					var sparams: Vector.<Boolean> = Vector.<Boolean>( annot.attributes.getValue( Annotation.PARAMETERS ) );
					var fname: String = annot.attributes.getValue( Annotation.FILE ).toString();
					var mimetype: String = annot.attributes.getValue( Annotation.MIMETYPE ).toString();
					
					var fs: PdfFileSpecification;
					
					if( sparams[0] )
						fs = PdfFileSpecification.fileEmbedded2( writer, fname, null );
					else
						fs = PdfFileSpecification.fileExtern(writer, fname);
					
					rect = new RectangleElement( annot.llx, annot.lly, annot.urx, annot.ury );
					var ann: PdfAnnotation = PdfAnnotation.createScreen( writer, rect, fname, fs, mimetype, sparams[1] );
					return ann;
					
				default:
					return PdfAnnotation.createText( writer, new RectangleElement( defaultRect.getLeft(), defaultRect.getBottom(), defaultRect.getRight(), defaultRect.getTop() ), annot.title, annot.content, false, null );
			}
		}
		
		public function hasValidAcroForm(): Boolean
		{
			return _acroForm.valid;
		}
		
		internal function rotateAnnotations( writer: PdfWriter, pageSize: RectangleElement ): PdfArray
		{
			var array: PdfArray = new PdfArray();
			var rotation: int = pageSize.rotation % 360;
			var currentPage: int = writer.getCurrentPageNumber();
			
			for( var k: int = 0; k < annotations.length; ++k )
			{
				var dic: PdfAnnotation = annotations[k];
				var page: int = dic.placeInPage;
				if( page > currentPage )
				{
					delayedAnnotations.push( dic );
					continue;
				}
				
				if( dic.isForm )
				{
					if( !dic.getUsed() )
					{
						var templates: HashMap = dic.templates;
						if( templates != null )
							_acroForm.addFieldTemplates( templates );
					}
					
					var field: PdfFormField = PdfFormField( dic );
					if( field.parent == null )
						_acroForm.addDocumentField( field.indirectReference );
				}
				
				if( dic.isAnnotation )
				{
					array.add( dic.indirectReference );
					if( !dic.getUsed() )
					{
						var rect: PdfRectangle = dic.getValue( PdfName.RECT ) as PdfRectangle;
						if( rect != null )
						{
							switch( rotation )
							{
								case 90:
									dic.put( PdfName.RECT, new PdfRectangle(
										pageSize.getTop() - rect.bottom,
										rect.left,
										pageSize.getTop() - rect.top,
										rect.right) );
									break;
								
								case 180:
									dic.put( PdfName.RECT, new PdfRectangle(
										pageSize.getRight() - rect.left,
										pageSize.getTop() - rect.bottom,
										pageSize.getRight() - rect.right,
										pageSize.getTop() - rect.top) );
									break;
								
								case 270:
									dic.put( PdfName.RECT, new PdfRectangle(
										rect.bottom,
										pageSize.getRight() - rect.left,
										rect.top,
										pageSize.getRight() - rect.right) );
									break;
							}
						}
					}
				}
				
				if( !dic.getUsed() )
				{
					dic.setUsed();
					writer.addToBody1( dic, dic.indirectReference );
				}
			}
			return array;
		}
	}
}