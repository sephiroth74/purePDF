/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ShadingUtils.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/utils/ShadingUtils.as $
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
package org.purepdf.utils
{
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfGState;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.PdfTransparencyGroup;

	public class ShadingUtils
	{
		/**
		 * Draws a rectangle with a multiple alpha gradient colors<br />
		 * Example:<br />
		 * <pre>
		 * var colors: Vector.&lt;RGBColor&gt; 	= Vector.&lt;RGBColor&gt;([ RGBColor.BLACK, RGBColor.YELLOW, RGBColor.RED, RGBColor.CYAN ] );
		 * var ratios: Vector.&lt;Number&gt;		= Vector.&lt;Number&gt;([0, 0.5, 0.7, 1]);
		 * var alphas: Vector.&lt;Number&gt;		= Vector.&lt;Number&gt;([ 0, 0.2, 0.3, 0.6 ]);
		 * ShadingUtils.drawRectangleGradient( cb, 100, 100, 100, PageSize.A4.height - 200, colors, ratios, alphas ); 
		 * </pre>
		 * 
		 * @param cb
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param colors		Vector of RGBColor
		 * @param ratios		Vector of numbers ( 0 to 1 )
		 * @param alpha			Vector of numbers ( 0 to 1 )
		 * @param extendStart
		 * @param extendEnd
		 */
		public static function drawRectangleGradient( cb: PdfContentByte, x: Number, y: Number, width: Number, height: Number, colors: Vector.<RGBColor>,
				ratios: Vector.<Number>, alpha: Vector.<Number>, extendStart: Boolean = true, extendEnd: Boolean = true ): void
		{
			assert_true( colors.length == alpha.length, "Colors and Alpha vectors must be same length" );

			var shading: PdfShading;
			var template: PdfTemplate;
			var gState: PdfGState;

			cb.moveTo( x, y );
			cb.lineTo( x + width, y );
			cb.lineTo( x + width, y + height );
			cb.lineTo( x, y + height );

			// Create template
			template = cb.createTemplate( x + width, y + height );

			var transGroup: PdfTransparencyGroup = new PdfTransparencyGroup();
			transGroup.put( PdfName.CS, PdfName.DEVICERGB );
			transGroup.isolated = true;
			transGroup.knockout = false;
			template.group = transGroup;

			gState = new PdfGState();
			var maskDict: PdfDictionary = new PdfDictionary();
			maskDict.put( PdfName.TYPE, PdfName.MASK );
			maskDict.put( PdfName.S, new PdfName( "Luminosity" ) );
			maskDict.put( new PdfName( "G" ), template.indirectReference );
			gState.put( PdfName.SMASK, maskDict );
			cb.setGState( gState );

			var alphas: Vector.<GrayColor> = new Vector.<GrayColor>( alpha.length, true );
			for ( var k: int = 0; k < alpha.length; ++k )
			{
				alphas[k] = new GrayColor( alpha[k] );
			}

			shading = PdfShading.complexAxial( cb.writer, 0, y, 0, height, Vector.<RGBColor>( alphas ), ratios );
			template.paintShading( shading );

			shading = PdfShading.complexAxial( cb.writer, 0, y, 0, height, colors, ratios );
			var axialPattern: PdfShadingPattern = new PdfShadingPattern( shading );
			cb.setShadingFill( axialPattern );
			cb.fill();
		}
		
		/**
		 * 
		 * @param cb
		 * @param x
		 * @param y
		 * @param r0
		 * @param r1
		 * @param colors
		 * @param ratios
		 * @param alpha
		 * @param extendStart
		 * @param extendEnd
		 */
		public static function drawRadialGradient( cb: PdfContentByte, x: Number, y: Number, r0: Number, r1: Number, 
												   colors: Vector.<RGBColor>, ratios: Vector.<Number>, alpha: Vector.<Number>, extendStart: Boolean = true, 
												   extendEnd: Boolean = true ): void
		{
			assert_true( colors.length == alpha.length, "Colors and Alpha vectors must be same length" );
			
			var shading: PdfShading;
			var template: PdfTemplate;
			var gState: PdfGState;
			
			cb.circle( x, y, r1 );
			
			// Create template
			template = cb.createTemplate( x+ r1*2, y + r1*2 );
			
			var transGroup: PdfTransparencyGroup = new PdfTransparencyGroup();
			transGroup.put( PdfName.CS, PdfName.DEVICERGB );
			transGroup.isolated = true;
			transGroup.knockout = false;
			template.group = transGroup;
			
			gState = new PdfGState();
			var maskDict: PdfDictionary = new PdfDictionary();
			maskDict.put( PdfName.TYPE, PdfName.MASK );
			maskDict.put( PdfName.S, new PdfName( "Luminosity" ) );
			maskDict.put( new PdfName( "G" ), template.indirectReference );
			gState.put( PdfName.SMASK, maskDict );
			cb.setGState( gState );
			
			var alphas: Vector.<GrayColor> = new Vector.<GrayColor>( alpha.length, true );
			for ( var k: int = 0; k < alpha.length; ++k )
			{
				alphas[k] = new GrayColor( alpha[k] );
			}
			
			shading = PdfShading.complexRadial( cb.writer, x, y, x, y, r0, r1, Vector.<RGBColor>( alphas ), ratios );
			template.paintShading( shading );
			
			shading = PdfShading.complexRadial( cb.writer, x, y, x, y, r0, r1, colors, ratios );
			var axialPattern: PdfShadingPattern = new PdfShadingPattern( shading );
			cb.setShadingFill( axialPattern );
			cb.fill();
		}
	}
}