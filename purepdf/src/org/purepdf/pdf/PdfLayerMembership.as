/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfLayerMembership.as 269 2010-02-05 10:47:58Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 269 $ $LastChangedDate: 2010-02-05 05:47:58 -0500 (Fri, 05 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfLayerMembership.as $
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
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.HashSet;
	
	import org.purepdf.pdf.interfaces.IPdfOCG;

	public class PdfLayerMembership extends PdfDictionary implements IPdfOCG
	{
		/**
		 * Visible only if all of the entries are <b>OFF</b>.
		 */
		public static const ALLOFF: PdfName = new PdfName( "AllOff" );
		
		/**
		 * Visible only if all of the entries are <b>ON</b>.
		 */
		public static const ALLON: PdfName = new PdfName( "AllOn" );

		/**
		 * Visible if any of the entries are <b>OFF</b>.
		 */
		public static const ANYOFF: PdfName = new PdfName( "AnyOff" );
		
		/**
		 * Visible if any of the entries are <b>ON</b>.
		 */
		public static const ANYON: PdfName = new PdfName( "AnyOn" );

		private var _ref: PdfIndirectReference;
		private var _members: PdfArray = new PdfArray();
		private var _layers: HashSet = new HashSet();
		
		public function PdfLayerMembership( writer: PdfWriter )
		{
			super( PdfName.OCMD );
			put( PdfName.OCGS, _members );
			_ref = writer.pdfIndirectReference;
		}
		
		/**
		 * Add a new member to the layer
		 */
		public function addMember( layer: PdfLayer ): void
		{
			if( !_layers.contains( layer ) )
			{
				_members.add( layer.ref );
				_layers.add( layer );
			}
		}
		
		/**
		 * Set the visibility policy for content belonging to this
		 * membership dictionary.<br/>
		 * Allowed values are:<br />
		 * <ul>
		 * 	<li>ALLON</li>
		 * 	<li>ANYON</li>
		 * 	<li>ANYOFF</li>
		 * 	<li>ALLOFF</li>
		 * </ul>
		 * 
		 * The default value is <code>ANYON</code>
		 * 
		 * @param type	The visibility policy
		 * @see #ALLOFF
		 * @see #ALLON
		 * @see #ANYOFF
		 * @see #ANYON
		 */
		public function set visibilityPolicy( type: PdfName ): void
		{
			put( PdfName.P, type );
		}
		
		public function get layer(): HashSet
		{
			return _layers;
		}

		public function get pdfObject(): PdfObject
		{
			return this;
		}

		public function get ref(): PdfIndirectReference
		{
			return _ref;
		}
	}
}