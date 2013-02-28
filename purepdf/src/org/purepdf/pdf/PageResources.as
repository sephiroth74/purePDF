/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PageResources.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PageResources.as $
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
	import it.sephiroth.utils.ObjectHash;
	import it.sephiroth.utils.collections.iterators.Iterator;

	public class PageResources extends ObjectHash
	{
		protected var colorDictionary: PdfDictionary = new PdfDictionary();
		protected var extGStateDictionary: PdfDictionary = new PdfDictionary();
		protected var fontDictionary: PdfDictionary = new PdfDictionary();
		protected var forbiddenNames: HashMap;
		protected var namePtr: Vector.<int> = Vector.<int>( [ 0 ] );
		protected var originalResources: PdfDictionary;
		protected var patternDictionary: PdfDictionary = new PdfDictionary();
		protected var propertyDictionary: PdfDictionary = new PdfDictionary();
		protected var shadingDictionary: PdfDictionary = new PdfDictionary();
		protected var usedNames: HashMap;
		protected var xObjectDictionary: PdfDictionary = new PdfDictionary();

		public function PageResources()
		{
		}

		public function addDefaultColorDiff( dic: PdfDictionary ): void
		{
			colorDictionary.mergeDifferent( dic );
		}

		public function getResources(): PdfDictionary
		{
			var resources: PdfResources = new PdfResources();

			if ( originalResources != null )
				resources.putAll( originalResources );
			resources.put( PdfName.PROCSET, new PdfLiteral( "[/PDF /Text /ImageB /ImageC /ImageI]" ) );
			resources.add( PdfName.FONT, fontDictionary );
			resources.add( PdfName.XOBJECT, xObjectDictionary );
			resources.add( PdfName.COLORSPACE, colorDictionary );
			resources.add( PdfName.PATTERN, patternDictionary );
			resources.add( PdfName.SHADING, shadingDictionary );
			resources.add( PdfName.EXTGSTATE, extGStateDictionary );
			resources.add( PdfName.PROPERTIES, propertyDictionary );
			return resources;
		}

		internal function addColor( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			colorDictionary.put( name, reference );
			return name;
		}

		internal function addDefaultColor( dic: PdfDictionary ): void
		{
			colorDictionary.merge( dic );
		}

		internal function addDefaultColor2( name: PdfName, obj: PdfObject ): void
		{
			if ( obj == null || obj.isNull() )
				colorDictionary.remove( name );
			else
				colorDictionary.put( name, obj );
		}

		internal function addExtGState( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			extGStateDictionary.put( name, reference );
			return name;
		}

		internal function addFont( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			fontDictionary.put( name, reference );
			return name;
		}

		internal function addPattern( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			patternDictionary.put( name, reference );
			return name;
		}

		internal function addProperty( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			propertyDictionary.put( name, reference );
			return name;
		}

		internal function addShading( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			shadingDictionary.put( name, reference );
			return name;
		}

		internal function addXObject( name: PdfName, reference: PdfIndirectReference ): PdfName
		{
			name = translateName( name );
			xObjectDictionary.put( name, reference );
			return name;
		}

		internal function setOriginalResources( resources: PdfDictionary, newNamePtr: Vector.<int> ): void
		{
			if ( newNamePtr != null )
				namePtr = newNamePtr;
			forbiddenNames = new HashMap();
			usedNames = new HashMap();

			if ( resources == null )
				return;
			originalResources = new PdfDictionary();
			originalResources.merge( resources );
			var i: Iterator = resources.getKeys().iterator();

			for ( i; i.hasNext();  )
			{
				var key: PdfName = PdfName( i.next() );
				var sub: PdfObject = PdfReader.getPdfObject( resources.getValue( key ) );

				if ( sub != null && sub.isDictionary() )
				{
					var dic: PdfDictionary = PdfDictionary( sub );
					var j: Iterator = dic.getKeys().iterator();

					for ( j; j.hasNext();  )
					{
						forbiddenNames.put( j.next(), null );
					}
					var dic2: PdfDictionary = new PdfDictionary();
					dic2.merge( dic );
					originalResources.put( key, dic2 );
				}
			}
		}

		private function translateName( name: PdfName ): PdfName
		{
			var translated: PdfName = name;

			if ( forbiddenNames != null )
			{
				translated = usedNames.getValue( name ) as PdfName;

				if ( translated == null )
				{
					while ( true )
					{
						throw new Error( "check namePtr[0]++" );
						translated = new PdfName( "Xi" + ( namePtr[ 0 ]++ ) );

						if ( !forbiddenNames.containsKey( translated ) )
							break;
					}
					usedNames.put( name, translated );
				}
			}
			return translated;
		}
	}
}