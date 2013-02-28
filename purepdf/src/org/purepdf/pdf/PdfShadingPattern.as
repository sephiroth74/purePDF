/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfShadingPattern.as 248 2010-02-01 21:58:20Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 248 $ $LastChangedDate: 2010-02-01 16:58:20 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfShadingPattern.as $
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
	
	import org.purepdf.utils.pdf_core;
	

	/**
	 * 
	 * @author alessandro
	 */
	public class PdfShadingPattern extends PdfDictionary
	{
		/**
		 * 
		 * @default 
		 */
		protected var _shading: PdfShading;
		/**
		 * 
		 * @default 
		 */
		protected var _writer: PdfWriter;
		/**
		 * 
		 * @default 
		 */
		protected var _matrix: Matrix = new Matrix();
		/**
		 * 
		 * @default 
		 */
		protected var _patternName: PdfName;
		/**
		 * 
		 * @default 
		 */
		protected var _patternReference: PdfIndirectReference;
		
		use namespace pdf_core;
		
		/**
		 * 
		 * @param sh
		 */
		public function PdfShadingPattern( sh: PdfShading )
		{
			_writer = sh.writer;
			put( PdfName.PATTERNTYPE, new PdfNumber(2) );
			_shading = sh;
		}
		
		/**
		 * 
		 * @return 
		 */
		internal function get patternName(): PdfName
		{
			return _patternName;
		}
		
		/**
		 * 
		 * @return 
		 */
		internal function get shadingName(): PdfName
		{
			return _shading.shadingName;
		}
		
		/**
		 * 
		 * @return 
		 */
		internal function get patternReference(): PdfIndirectReference
		{
			if( _patternReference == null )
				_patternReference = _writer.pdfIndirectReference;
			return _patternReference;
		}
		
		/**
		 * 
		 * @return 
		 */
		internal function get shadingReference(): PdfIndirectReference
		{
			return _shading.shadingReference;
		}
		
		/**
		 * 
		 * @param number
		 */
		internal function setName( number: int ): void
		{
			_patternName = new PdfName("P" + number);
		}
		
		/**
		 * 
		 */
		internal function addToBody(): void
		{
			var ar: Vector.<Number> = Vector.<Number>([ _matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty ] );
			put( PdfName.SHADING, shadingReference );
			put( PdfName.MATRIX, new PdfArray( ar ) );
			_writer.addToBody1( this, patternReference );
		}
		
		/**
		 * 
		 * @param value
		 */
		public function set matrix( value: Matrix ):void
		{
			_matrix = value;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get matrix(): Matrix
		{
			return _matrix;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get shading(): PdfShading
		{
			return _shading;
		}
		
		/**
		 * 
		 * @return 
		 */
		internal function get colorDetails(): ColorDetails
		{
			return _shading.colorDetails;
		}
		
	}
}