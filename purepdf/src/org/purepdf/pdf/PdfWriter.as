/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfWriter.as 399 2011-01-16 08:56:15Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 399 $ $LastChangedDate: 2011-01-16 03:56:15 -0500 (Sun, 16 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfWriter.as $
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
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	
	import it.sephiroth.utils.Entry;
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.HashSet;
	import it.sephiroth.utils.ObjectHash;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.colors.ExtendedColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.colors.SpotColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.elements.images.ImageWMF;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.io.OutputStreamCounter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.DocumentFont;
	import org.purepdf.pdf.fonts.FontDetails;
	import org.purepdf.pdf.interfaces.IPdfOCG;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.assert_true;
	import org.purepdf.utils.pdf_core;

	public class PdfWriter extends ObjectHash
	{
		use namespace pdf_core;
		
		public static const RUN_DIRECTION_DEFAULT: int = 0;
		public static const RUN_DIRECTION_NO_BIDI: int = 1;
		public static const RUN_DIRECTION_LTR: int = 2;
		public static const RUN_DIRECTION_RTL: int = 3;
		
		public static const STANDARD_ENCRYPTION_40: int = 0;
		public static const STANDARD_ENCRYPTION_128: int = 1;
		public static const ENCRYPTION_AES_128: int = 2;
		
		public static const GENERATION_MAX: int = 65535;
		public static const NAME: String = 'purepdf';
		public static const NO_SPACE_CHAR_RATIO: Number = 10000000;

		public static const MAIN_VERSION: String = '0';
		public static const BUILD_NUMBER: String = '77';
		public static const BUILD_DATE: String = '20110116';
		public static const RELEASE: String = MAIN_VERSION + '.' + BUILD_NUMBER + '.' + BUILD_DATE;
		
		public static const SPACE_CHAR_RATIO_DEFAULT: Number = 2.5;
		public static const VERSION: String = NAME + ' ' + RELEASE;
		protected var OCGLocked: PdfArray = new PdfArray();
		protected var OCGRadioGroup: PdfArray = new PdfArray();
		protected var OCProperties: PdfOCProperties;
		protected var _rgbTransparencyBlending: Boolean;
		protected var runDirection: int = RUN_DIRECTION_NO_BIDI;

		protected var body: PdfBody;
		protected var colorNumber: int = 1;
		protected var _compressionLevel: int = PdfStream.BEST_COMPRESSION;
		internal var crypto: PdfEncryption;
		protected var currentPageNumber: int = 1;
		protected var defaultColorspace: PdfDictionary = new PdfDictionary();
		protected var defaultPageSize: PageSize;
		protected var directContent: PdfContentByte;
		protected var directContentUnder: PdfContentByte;
		protected var documentColors: HashMap = new HashMap();
		protected var documentExtGState: HashMap = new HashMap();
		protected var documentFonts: HashMap = new HashMap(); // LinkedHashMap
		protected var documentOCG: HashSet = new HashSet();
		protected var documentOCGOrder: Vector.<IPdfOCG> = new Vector.<IPdfOCG>();
		protected var documentPatterns: HashMap = new HashMap();
		protected var documentProperties: HashMap = new HashMap();
		protected var documentShadingPatterns: HashMap = new HashMap();
		protected var documentShadings: HashMap = new HashMap();
		protected var documentSpotPatterns: HashMap = new HashMap();
		protected var extraCatalog: PdfDictionary;

		protected var fontCount: int = 1;
		protected var formXObjects: HashMap = new HashMap();
		protected var formXObjectsCounter: int = 1;
		protected var fullCompression: Boolean = false;
		protected var group: PdfDictionary;
		protected var imageDictionary: PdfDictionary = new PdfDictionary();
		protected var images: HashMap = new HashMap();
		protected var opened: Boolean = false;

		protected var os: OutputStreamCounter;
		protected var pageReferences: Vector.<PdfIndirectReference> = new Vector.<PdfIndirectReference>();
		protected var patternColorspaceCMYK: ColorDetails;
		protected var patternColorspaceGRAY: ColorDetails;
		protected var patternColorspaceRGB: ColorDetails;
		protected var patternCounter: int = 1;
		protected var paused: Boolean = false;
		protected var pdf: PdfDocument;
		protected var pdf_version: PdfVersion = new PdfVersion();
		protected var prevxref: int = 0;
		protected var root: PdfPages;
		protected var tabs: PdfName = null;
		protected var xmpMetadata: Bytes = null;
		protected var _userunit: Number = 0;
		protected var _tagged: Boolean = false;
		protected var _structureTreeRoot: PdfStructureTreeRoot;
		
		private var _spaceCharRatio: Number = SPACE_CHAR_RATIO_DEFAULT;
		private var _userProperties: Boolean;

		public function PdfWriter( instance: Lock, output: ByteArray, pagesize: RectangleElement )
		{
			assert_true( instance != null && instance is Lock, "Use PdfWriter.create to initialize a new instance of purepdf" );

			os = new OutputStreamCounter( output );

			pdf = new PdfDocument( pagesize );
			pdf.addWriter( this );
			root = new PdfPages( this );

			directContent = new PdfContentByte( this );
			directContentUnder = new PdfContentByte( this );
		}

		public function get userProperties(): Boolean
		{
			return _userProperties;
		}

		/**
		 * Sets the flag indicating the presence of structure elements that contain user properties attributes.
		 */
		public function set userProperties( value: Boolean ): void
		{
			_userProperties = value;
		}

		/**
		 * Gets the structure tree root. 
		 * If the document is not marked for tagging it will return null.
		 */
		public function get structureTreeRoot():PdfStructureTreeRoot
		{
			if( _tagged && _structureTreeRoot == null )
				_structureTreeRoot = new PdfStructureTreeRoot(this);
			return _structureTreeRoot;
		}

		public function get tagged():Boolean
		{
			return _tagged;
		}

		public function set tagged(value:Boolean):void
		{
			if( opened )
				throw new IllegalOperationError("tagging must be set before opening a document");
			_tagged = value;
		}

		internal function get userunit():Number
		{
			return _userunit;
		}

		internal function set userunit(value:Number):void
		{
			if ( value < 1 || value > 75000 )
				throw new DocumentError( "userunit should must be a value between 1 and 75000" );
			_userunit = value;
			setAtLeastPdfVersion( PdfVersion.VERSION_1_6 );
		}

		internal function setAtLeastPdfVersion( version: String ): void
		{
			pdf_version.setAtLeastPdfVersion( version );
		}
		
		/**
		 * Returns the compression level used for streams written by this writer.
		 * @return the compression level (0 = best speed, 9 = best compression, -1 is default)
		 */
		public function get compressionLevel(): int
		{
			return _compressionLevel;
		}

		public function getCurrentPage(): PdfIndirectReference
		{
			return getPageReference( currentPageNumber );
		}

		public function getCurrentPageNumber(): int
		{
			return currentPageNumber;
		}

		public function getDefaultColorSpace(): PdfDictionary
		{
			return defaultColorspace;
		}

		public function getDirectContent(): PdfContentByte
		{
			if ( !opened )
				throw new Error( "Document is not open" );
			return directContent;
		}

		public function getDirectContentUnder(): PdfContentByte
		{
			if ( !opened )
				throw new Error( "Document is not open" );
			return directContentUnder;
		}

		public function getEncryption(): PdfEncryption
		{
			return crypto;
		}

		public function getExtraCatalog(): PdfDictionary
		{
			if ( extraCatalog == null )
				extraCatalog = new PdfDictionary();
			return extraCatalog;
		}

		public function getGroup(): PdfDictionary
		{
			return group;
		}

		public function getImageReference( name: PdfName ): PdfIndirectReference
		{
			return imageDictionary.getValue( name ) as PdfIndirectReference;
		}

		/**
		 * Use this method to get the info dictionary if you want to
		 * change it directly (add keys and values to the info dictionary).
		 * @return the info dictionary
		 */
		public function getInfo(): PdfDictionary
		{
			return pdf.getInfo();
		}

		public function getOs(): OutputStreamCounter
		{
			return os;
		}

		/**
		 * Gets the pagenumber of this document.
		 * This number can be different from the real pagenumber,
		 * if you have (re)set the page number previously.
		 * @return a page number
		 */

		public function get pageNumber(): int
		{
			return pdf.pageNumber;
		}

		/**
		 * Use this method to get a reference to a page existing or not.
		 * If the page does not exist yet the reference will be created
		 * in advance. If on closing the document, a page number greater
		 * than the total number of pages was requested, an exception
		 * is thrown.
		 * @param page the page number. The first page is 1
		 * @return the reference to the page
		 */
		public function getPageReference( page: int ): PdfIndirectReference
		{
			--page;

			if ( page < 0 )
				throw new ArgumentError( "page number must be >= 1" );

			var ref: PdfIndirectReference;

			if ( page < pageReferences.length )
			{
				ref = pageReferences[ page ] as PdfIndirectReference;

				if ( ref == null )
				{
					ref = body.pdfIndirectReference;
					pageReferences[ page ] = ref;
				}
			}
			else
			{
				var empty: int = page - pageReferences.length;

				for ( var k: int = 0; k < empty; ++k )
					pageReferences.push( null );

				ref = body.pdfIndirectReference;
				pageReferences.push( ref );
			}
			return ref;
		}

		public function getTabs(): PdfName
		{
			return tabs;
		}

		public function isFullCompression(): Boolean
		{
			return fullCompression;
		}
		
		/**
		 * Set the document compression to the PDF 1.5 mode
		 * with object streams ans xref streams.
		 * Once set it can't be unset anymore.
		 * 
		 */
		public function setFullCompression(): void
		{
			fullCompression = true;
			setAtLeastPdfVersion( PdfVersion.VERSION_1_5 );
		}


		public function isOpen(): Boolean
		{
			return opened;
		}

		public function isPaused(): Boolean
		{
			return paused;
		}

		/**
		 * Gets the transparency blending colorspace.
		 * @return <code>true</code> if the transparency blending colorspace is RGB, <code>false</code>
		 * if it is the default blending colorspace
		 */
		public function isRgbTransparencyBlending(): Boolean
		{
			return rgbTransparencyBlending;
		}

		public function get pdfDocument(): PdfDocument
		{
			return pdf;
		}

		/**
		 * Resets all the direct contents to empty.
		 * This happens when a new page is started.
		 */
		public function resetContent(): void
		{
			directContent.reset();
			directContentUnder.reset();
		}

		/**
		 * Gets the transparency blending colorspace
		 */
		public function get rgbTransparencyBlending(): Boolean
		{
			return _rgbTransparencyBlending;
		}

		/**
		 * Sets the transparency blending colorspace to RGB
		 */
		public function set rgbTransparencyBlending( value: Boolean ): void
		{
			_rgbTransparencyBlending = value;
		}

		/**
		 *
		 * @param key
		 * 		the name of the colorspace. It can be PdfName.DEFAULTGRAY, PdfName.DEFAULTRGB or PdfName.DEFAULTCMYK
		 */
		public function setDefaultColorSpace( key: PdfName, value: PdfObject ): void
		{
			if ( value == null || value.isNull() )
				defaultColorspace.remove( key );
			defaultColorspace.put( key, value );
		}

		public function setEncryption( value: PdfEncryption ): void
		{
			crypto = value;
		}

		public function setGroup( value: PdfDictionary ): void
		{
			group = value;
		}

		public function setTabs( value: PdfName ): void
		{
			tabs = value;
		}

		public function get spaceCharRatio(): Number
		{
			return _spaceCharRatio;
		}

		protected function addSharedObjectsToBody(): void
		{
			var it: Iterator;
			var objs: Vector.<Object>;
			var entry: Entry;

			// 3 add the fonts
			it = documentFonts.values().iterator();

			for ( it; it.hasNext();  )
			{
				var details: FontDetails = FontDetails( it.next() );
				details.writeFont( this );
			}

			// 4 add the form XObjects
			it = formXObjects.values().iterator();

			for ( it; it.hasNext();  )
			{
				objs = Vector.<Object>( it.next() );
				var template: PdfTemplate = objs[ 1 ] as PdfTemplate;

				if ( template != null && template.indirectReference is PRIndirectReference )
					continue;

				if ( template != null && template.type == PdfTemplate.TYPE_TEMPLATE )
					addToBody1( template.getFormXObject( _compressionLevel ), template.indirectReference );
			}

			// 5 add all the dependencies in the imported pages
			// 6 add the spotcolors
			it = documentColors.values().iterator();

			for ( it; it.hasNext();  )
			{
				var color: ColorDetails = ColorDetails( it.next() );
				addToBody1( color.getSpotColor( this ), color.indirectReference );
			}

			// 7 add the pattern
			it = documentPatterns.keySet().iterator();
			var pat: PdfPatternPainter;

			for ( it; it.hasNext();  )
			{
				pat = it.next() as PdfPatternPainter;
				addToBody1( pat.getPattern( _compressionLevel ), pat.indirectReference );
			}

			// 8 add the shading patterns
			it = documentShadingPatterns.keySet().iterator();

			for ( it; it.hasNext();  )
			{
				var shadingPattern: PdfShadingPattern = PdfShadingPattern( it.next() );
				shadingPattern.addToBody();
			}

			// 9 add the shadings
			it = documentShadings.keySet().iterator();

			for ( it; it.hasNext();  )
			{
				var shading: PdfShading = PdfShading( it.next() );
				shading.addToBody();
			}

			// 10 add the extgstate
			it = documentExtGState.entrySet().iterator();

			for ( it; it.hasNext();  )
			{
				entry = it.next();
				var gstate: PdfDictionary = entry.getKey() as PdfDictionary;
				var obj: Vector.<PdfObject> = Vector.<PdfObject>( entry.getValue() );
				addToBody1( gstate, PdfIndirectReference( obj[ 1 ] ) );
			}

			// 11 add the properties
			it = documentProperties.entrySet().iterator();
			for( it; it.hasNext();) {
				entry = it.next();
				var prop: Object = entry.key;
				objs = entry.value as Vector.<Object>;
				
				if( prop is PdfLayerMembership )
				{
					var layerM: PdfLayerMembership = PdfLayerMembership(prop);
					addToBody1( layerM.pdfObject, layerM.ref );
				}
				else if ((prop is PdfDictionary) && !(prop is PdfLayer))
				{
					addToBody1( PdfDictionary(prop), PdfIndirectReference(objs[1]) );
				}
			}
			
			// 13 add the OCG layers
			it = documentOCG.iterator();

			for ( it; it.hasNext();  )
			{
				var layer: IPdfOCG = IPdfOCG( it.next() );
				addToBody1( layer.pdfObject, layer.ref );
			}
		}
		
		protected function fillOCProperties( erase: Boolean ): void
		{
			var layer: PdfLayer;
			var k: int;
			var gr: PdfArray;
			var i: Iterator;

			if ( OCProperties == null )
				OCProperties = new PdfOCProperties();

			if ( erase )
			{
				OCProperties.remove( PdfName.OCGS );
				OCProperties.remove( PdfName.D );
			}

			if ( OCProperties.getValue( PdfName.OCGS ) == null )
			{
				gr = new PdfArray();

				for ( i = documentOCG.iterator(); i.hasNext();  )
				{
					layer = PdfLayer( i.next() );
					gr.add( layer.ref );
				}
				OCProperties.put( PdfName.OCGS, gr );
			}

			if ( OCProperties.getValue( PdfName.D ) != null )
				return;

			var docOrder: Vector.<IPdfOCG> = documentOCGOrder.concat();

			for ( k = 0; k < docOrder.length; ++k )
			{
				layer = PdfLayer( docOrder[ k ] );

				if ( layer.parent != null )
				{
					docOrder.splice( k, 1 );
					--k;
				}
			}

			var order: PdfArray = new PdfArray();

			for ( k = 0; k < docOrder.length; ++k )
			{
				layer = PdfLayer( docOrder[ k ] );
				getOCGOrder( order, layer );
			}

			var d: PdfDictionary = new PdfDictionary();
			OCProperties.put( PdfName.D, d );
			d.put( PdfName.ORDER, order );
			gr = new PdfArray();

			for ( i = documentOCG.iterator(); i.hasNext();  )
			{
				layer = PdfLayer( i.next() );

				if ( !layer.visible )
					gr.add( layer.ref );
			}

			if ( gr.size > 0 )
				d.put( PdfName.OFF, gr );

			if ( OCGRadioGroup.size > 0 )
				d.put( PdfName.RBGROUPS, OCGRadioGroup );

			if ( OCGLocked.size > 0 )
				d.put( PdfName.LOCKED, OCGLocked );

			addASEvent( PdfName.VIEW, PdfName.ZOOM );
			addASEvent( PdfName.VIEW, PdfName.VIEW );
			addASEvent( PdfName.PRINT, PdfName.PRINT );
			addASEvent( PdfName.EXPORT, PdfName.EXPORT );
			d.put( PdfName.LISTMODE, PdfName.VISIBLEPAGES );
		}

		/*
		 * The Catalog is also called the root object of the document.
		 * Whereas the Cross-Reference maps the objects number with the
		 * byte offset so that the viewer can find the objects, the
		 * Catalog tells the viewer the numbers of the objects needed
		 * to render the document.
		 */
		protected function getCatalog( rootObj: PdfIndirectReference ): PdfDictionary
		{
			var catalog: PdfDictionary = pdf.getCatalog( rootObj );

			if( _tagged ) 
			{
				try 
				{
					_structureTreeRoot.buildTree();
				}
				catch( e: Error )
				{
					throw new ConversionError( e );
				}
				
				catalog.put( PdfName.STRUCTTREEROOT, _structureTreeRoot.reference );
				var mi: PdfDictionary = new PdfDictionary();
				mi.put( PdfName.MARKED, PdfBoolean.PDF_TRUE );
				if( _userProperties )
					mi.put( PdfName.USERPROPERTIES, PdfBoolean.PDF_TRUE );
				catalog.put( PdfName.MARKINFO, mi );
			}
			
			if ( !documentOCG.isEmpty() )
			{
				fillOCProperties( false );
				catalog.put( PdfName.OCPROPERTIES, OCProperties );
			}

			trace( 'PdfWriter.getCatalog. to be implemented' );

			return catalog;
		}
		
		protected var newBookmarks: Array;
		
		public function setOutlines( outlines: Array ): void
		{
			newBookmarks = outlines;
		}

		pdf_core function propertyExists( prop: Object ): Boolean
		{
			return documentProperties.containsKey( prop );
		}

		protected function writeOutlines( catalog: PdfDictionary, namedAsNames: Boolean ): void
		{
			if (newBookmarks == null || newBookmarks.isEmpty())
				return;
			throw new NonImplementatioError();
		}

		internal function add( page: PdfPage, contents: PdfContents ): PdfIndirectReference
		{
			if ( !opened )
				throw new Error( "Document is not open" );

			var object: PdfIndirectObject;
			object = addToBody( contents );

			page.add( object.indirectReference );

			if ( group != null )
			{
				page.put( PdfName.GROUP, group );
				group = null;
			}
			else if ( _rgbTransparencyBlending )
			{
				var pp: PdfDictionary = new PdfDictionary();
				pp.put( PdfName.TYPE, PdfName.GROUP );
				pp.put( PdfName.S, PdfName.TRANSPARENCY );
				pp.put( PdfName.CS, PdfName.DEVICERGB );
				page.put( PdfName.GROUP, pp );
			}

			root.addPage( page );
			currentPageNumber++;
			return null;
		}

		pdf_core function addDirectImageSimple( image: ImageElement ): PdfName
		{
			return addDirectImageSimple2( image, null );
		}

		pdf_core function addDirectImageSimple2( image: ImageElement, fixedRef: PdfIndirectReference ): PdfName
		{
			var name: PdfName;

			if ( images.containsKey( image.mySerialId ) )
			{
				name = PdfName( images.getValue( image.mySerialId ) );
			}
			else
			{
				if ( image.isImgTemplate )
				{
					name = new PdfName("img" + images.size() );
					if(image is ImageWMF ) 
					{
						try
						{
							var wmf: ImageWMF = ImageWMF( image );
							wmf.readWMF( PdfTemplate.createTemplate( this, 0, 0 ) );
						} catch( e: Error )
						{
							throw new DocumentError(e);
						}
					}
				}
				else
				{
					var dref: PdfIndirectReference = image.directReference;

					if ( dref != null )
					{
						var rname: PdfName = new PdfName( "img" + images.size() );
						images.put( image.mySerialId, rname );
						imageDictionary.put( rname, dref );
						return rname;
					}

					var maskImage: ImageElement = image.imageMask;
					var maskRef: PdfIndirectReference = null;

					if ( maskImage != null )
					{
						var mname: PdfName = PdfName( images.getValue( maskImage.mySerialId ) );
						maskRef = getImageReference( mname );
					}

					var i: PdfImage = new PdfImage( image, "img" + images.size(), maskRef );

					add2( i, fixedRef );
					name = i.name;
				}

				images.put( image.mySerialId, name );
			}

			return name;
		}


		/**
		 * Adds a template to the document but not to the page resources.
		 * @param template the template to add
		 * @param forcedName the template name, rather than a generated one. Can be null
		 * @return the <CODE>PdfName</CODE> for this template
		 */

		pdf_core function addDirectTemplateSimple( template: PdfTemplate, forcedName: PdfName ): PdfName
		{
			var ref: PdfIndirectReference = template.indirectReference;
			var obj: Vector.<Object> = formXObjects.getValue( ref ) as Vector.<Object>;
			var name: PdfName = null;

			try
			{
				if ( obj == null )
				{
					if ( forcedName == null )
					{
						name = new PdfName( "Xf" + formXObjectsCounter );
						++formXObjectsCounter;
					}
					else
						name = forcedName;
	
					if ( template.type == PdfTemplate.TYPE_IMPORTED )
					{
						// If we got here from PdfCopy we'll have to fill importedPages
						throw new NonImplementatioError();
					}
					formXObjects.put( ref, Vector.<Object>( [ name, template ] ) );
				}
				else
					name = PdfName( obj[ 0 ] );
			} catch( e: Error )
			{
				throw new ConversionError(e);
			}

			return name;
		}

		internal function addLocalDestinations( dest: HashMap ): void
		{
			for ( var i: Iterator = dest.entrySet().iterator(); i.hasNext();  )
			{
				var entry: Entry = Entry( i.next() );
				var name: String = String( entry.getKey() );
				var obj: Vector.<Object> = Vector.<Object>( entry.getValue() );
				var destination: PdfDestination = obj[ 2 ] as PdfDestination;

				if ( obj[ 1 ] == null )
					obj[ 1 ] = pdfIndirectReference;

				if ( destination == null )
					addToBody1( new PdfString( "invalid_" + name ), PdfIndirectReference( obj[ 1 ] ) );
				else
					addToBody1( destination, PdfIndirectReference( obj[ 1 ] ) );
			}
		}

		pdf_core function addSimpleExtGState( gstate: PdfDictionary ): Vector.<PdfObject>
		{
			if ( !documentExtGState.containsKey( gstate ) )
			{
				var obj: Vector.<PdfObject> = Vector.<PdfObject>( [ new PdfName( "Pr" + ( documentExtGState.size() + 1 ) ), pdfIndirectReference ] );
				documentExtGState.put( gstate, obj );
			}
			return documentExtGState.getValue( gstate ) as Vector.<PdfObject>;
		}

		/**
		 * Adds a font to the document but not to the page resources.
		 * It is used for templates.
		 *
		 * @see org.purepdf.pdf.fonts.BaseFont
		 */
		pdf_core function addSimpleFont( bf: BaseFont ): FontDetails
		{
			if ( bf.fontType == BaseFont.FONT_TYPE_DOCUMENT )
				return new FontDetails( new PdfName( "F" + ( fontCount++ ) ), DocumentFont( bf ).indirectReference, bf );

			var ret: FontDetails = documentFonts.getValue( bf ) as FontDetails;

			if ( ret == null )
			{
				ret = new FontDetails( new PdfName( "F" + ( fontCount++ ) ), body.pdfIndirectReference, bf );
				documentFonts.put( bf, ret );
			}
			return ret;
		}

		pdf_core function addSimplePattern( painter: PdfPatternPainter ): PdfName
		{
			var name: PdfName = documentPatterns.getValue( painter ) as PdfName;

			if ( name == null )
			{
				name = new PdfName( "P" + patternCounter );
				++patternCounter;
				documentPatterns.put( painter, name );
			}

			return name;
		}

		pdf_core function addSimplePatternColorSpace( color: RGBColor ): ColorDetails
		{
			var type: int = ExtendedColor.getType( color );
			var array: PdfArray;

			if ( type == ExtendedColor.TYPE_PATTERN || type == ExtendedColor.TYPE_SHADING )
				throw new RuntimeError( "an uncolored tile pattern can not have another pattern or shading as color" );

			switch ( type )
			{
				case ExtendedColor.TYPE_RGB:
					if ( patternColorspaceRGB == null )
					{
						patternColorspaceRGB = new ColorDetails( getColorspaceName(), body.pdfIndirectReference, null );
						array = new PdfArray( PdfName.PATTERN );
						array.add( PdfName.DEVICERGB );
						addToBody1( array, patternColorspaceRGB.indirectReference );
					}
					return patternColorspaceRGB;

				case ExtendedColor.TYPE_CMYK:
					if ( patternColorspaceCMYK == null )
					{
						patternColorspaceCMYK = new ColorDetails( getColorspaceName(), body.pdfIndirectReference, null );
						array = new PdfArray( PdfName.PATTERN );
						array.add( PdfName.DEVICECMYK );
						addToBody1( array, patternColorspaceCMYK.indirectReference );
					}
					return patternColorspaceCMYK;
				case ExtendedColor.TYPE_GRAY:
					if ( patternColorspaceGRAY == null )
					{
						patternColorspaceGRAY = new ColorDetails( getColorspaceName(), body.pdfIndirectReference, null );
						array = new PdfArray( PdfName.PATTERN );
						array.add( PdfName.DEVICEGRAY );
						addToBody1( array, patternColorspaceGRAY.indirectReference );
					}
					return patternColorspaceGRAY;
				case ExtendedColor.TYPE_SEPARATION:
				{
					var details: ColorDetails = addSimpleSpotColor( SpotColor( color ).pdfSpotColor );
					var patternDetails: ColorDetails = documentSpotPatterns.getValue( details ) as ColorDetails;

					if ( patternDetails == null )
					{
						patternDetails = new ColorDetails( getColorspaceName(), body.pdfIndirectReference, null );
						array = new PdfArray( PdfName.PATTERN );
						array.add( details.indirectReference );
						addToBody1( array, patternDetails.indirectReference );
						documentSpotPatterns.put( details, patternDetails );
					}
					return patternDetails;
				}
				default:
					throw new RuntimeError( "invalid color type" );
			}
		}

		/**
		 * adding properties (OCG, marked content)
		 */
		pdf_core function addSimpleProperty( prop: Object, refi: PdfIndirectReference ): Vector.<PdfObject>
		{
			if ( !documentProperties.containsKey( prop ) )
				documentProperties.put( prop, Vector.<PdfObject>( [ new PdfName( "Pr" + ( documentProperties.size() + 1 ) ), refi ] ) );

			return documentProperties.getValue( prop ) as Vector.<PdfObject>;
		}

		pdf_core function addSimpleShading( value: PdfShading ): void
		{
			if ( !documentShadings.containsKey( value ) )
			{
				documentShadings.put( value, null );
				value.setName( documentShadings.size() );
			}
		}

		pdf_core function addSimpleShadingPattern( shading: PdfShadingPattern ): void
		{
			if ( !documentShadingPatterns.containsKey( shading ) )
			{
				shading.setName( patternCounter );
				++patternCounter;
				documentShadingPatterns.put( shading, null );
				addSimpleShading( shading.shading );
			}
		}

		/**
		 * Adds a SpotColor to the document but not to the page resources.
		 *
		 * @param spc the SpotColor
		 * @return a Vector of Objects where position 0 is a PdfName
		 * and position 1 is an PdfIndirectReference
		 *
		 */
		pdf_core function addSimpleSpotColor( spc: PdfSpotColor ): ColorDetails
		{
			var ret: ColorDetails = documentColors.getValue( spc ) as ColorDetails;

			if ( ret == null )
			{
				ret = new ColorDetails( getColorspaceName(), body.pdfIndirectReference, spc );
				documentColors.put( spc, ret );
			}
			return ret;
		}

		pdf_core function addToBody( object: PdfObject ): PdfIndirectObject
		{
			var iobj: PdfIndirectObject = body.add1( object );
			return iobj;
		}

		pdf_core function addToBody1( object: PdfObject, ref: PdfIndirectReference ): PdfIndirectObject
		{
			//var iobj: PdfIndirectObject = body.add3( object, ref );
			var iobj: PdfIndirectObject = body.add( object, ref.number, true );
			return iobj;
		}

		pdf_core function addToBody2( object: PdfObject, inObjStm: Boolean ): PdfIndirectObject
		{
			var iobj: PdfIndirectObject = body.add2( object, inObjStm );
			return iobj;
		}

		internal function close(): void
		{
			if ( opened )
			{
				if ( ( currentPageNumber - 1 ) != pageReferences.length )
					throw new Error( "The page " + pageReferences.length + " was requested, but the document has only " + ( currentPageNumber
						- 1 ) + " pages" );
				pdf.close();

				addSharedObjectsToBody();
				var rootRef: PdfIndirectReference = root.writePageTree();

				var catalog: PdfDictionary = getCatalog( rootRef );

				if ( xmpMetadata != null )
				{
					trace( 'PdfWriter.close. implement this' );
				}

				/*
				   if( isPdfX() )
				   {
				   pdfConformance.completeInfoDictionary( getInfo() );
				   pdfConformance.completeExtraCatalog( getExtraCatalog() );
				   }
				 */

				if ( extraCatalog != null )
					catalog.mergeDifferent( extraCatalog );

				writeOutlines( catalog, false );
				var indirectCatalog: PdfIndirectObject = addToBody2( catalog, false );
				var infoObj: PdfIndirectObject = addToBody2( getInfo(), false );

				// encryption
				var encryption: PdfIndirectReference = null;
				var fileID: PdfObject = null;
				body.flushObjStm();

				if ( crypto != null )
				{
					trace( 'PdfWriter.close. implement this' );
				}
				else
				{
					fileID = PdfEncryption.createInfoId( PdfEncryption.createDocumentId() );
				}

				// write the cross-reference table of the body
				body.writeCrossReferenceTable( os, indirectCatalog.indirectReference, infoObj.indirectReference, encryption
					, fileID, prevxref );

				// full compression
				if ( fullCompression )
				{
					os.writeBytes( getISOBytes( "startxref\n" ) );
					os.writeBytes( getISOBytes( body.offset.toString() ) );
					os.writeBytes( getISOBytes( "\n%%EOF\n" ) );
				}
				else
				{
					var trailer: PdfTrailer = new PdfTrailer( body.size, body.offset, indirectCatalog.indirectReference, infoObj
						.indirectReference, encryption, fileID, prevxref );
					trailer.toPdf( this, os );
				}
			}
		}


		pdf_core function eliminateFontSubset( fonts: PdfDictionary ): void
		{
			for ( var it: Iterator = documentFonts.values().iterator(); it.hasNext();  )
			{
				var ft: FontDetails = FontDetails( it.next() );

				if ( fonts.getValue( ft.fontName ) != null )
					ft.subset = false;
			}
		}


		internal function getColorspaceName(): PdfName
		{
			return new PdfName( "CS" + ( colorNumber++ ) );
		}

		internal function getOCProperties(): PdfOCProperties
		{
			fillOCProperties( true );
			return OCProperties;
		}

		/**
		 * Use this to get an <CODE>PdfIndirectReference</CODE> for an object that
		 * will be created in the future.
		 * Use this method only if you know what you're doing!
		 * @return the <CODE>PdfIndirectReference</CODE>
		 */

		internal function get pdfIndirectReference(): PdfIndirectReference
		{
			return body.pdfIndirectReference;
		}

		internal function getPdfVersion(): PdfVersion
		{
			return pdf_version;
		}

		internal function lockLayer( layer: PdfLayer ): void
		{
			OCGLocked.add( layer.ref );
		}

		internal function open(): PdfDocument
		{
			if ( !opened )
			{
				opened = true;
				pdf_version.writeHeader( os );
				body = new PdfBody( this );
			}

			return pdf;
		}

		internal function registerLayer( layer: IPdfOCG ): void
		{
			if ( layer is PdfLayer )
			{
				var la: PdfLayer = PdfLayer( layer );

				if ( la.title == null )
				{
					if ( !documentOCG.contains( layer ) )
					{
						documentOCG.add( layer );
						documentOCGOrder.push( layer );
					}
					else
					{
						documentOCG.add( layer );
					}
				}
			}
			else
			{
				throw new ArgumentError( "only PdfLayer is accepted" );
			}
		}

		internal function setPdfVersion( value: String ): void
		{
			pdf_version.setPdfVersion( value );
		}

		private function add2( pdfImage: PdfImage, fixedRef: PdfIndirectReference ): PdfIndirectReference
		{
			if ( !imageDictionary.contains( pdfImage.name ) )
			{
				if ( fixedRef is PRIndirectReference )
				{
					throw new NonImplementatioError();
				}

				if ( fixedRef == null )
					fixedRef = addToBody( pdfImage ).indirectReference;
				else
					addToBody1( pdfImage, fixedRef );

				imageDictionary.put( pdfImage.name, fixedRef );
				return fixedRef;
			}
			return imageDictionary.getValue( pdfImage.name ) as PdfIndirectReference;
		}

		private function addASEvent( event: PdfName, category: PdfName ): void
		{
			var arr: PdfArray = new PdfArray();

			for ( var i: Iterator = documentOCG.iterator(); i.hasNext();  )
			{
				var layer: PdfLayer = PdfLayer( i.next() );
				var usage: PdfDictionary = PdfDictionary( layer.getValue( PdfName.USAGE ) );

				if ( usage != null && usage.getValue( category ) != null )
					arr.add( layer.ref );
			}

			if ( arr.size == 0 )
				return;

			var d: PdfDictionary = PdfDictionary( OCProperties.getValue( PdfName.D ) );
			var arras: PdfArray = d.getValue( PdfName.AS ) as PdfArray;

			if ( arras == null )
			{
				arras = new PdfArray();
				d.put( PdfName.AS, arras );
			}

			var asd: PdfDictionary = new PdfDictionary();
			asd.put( PdfName.EVENT, event );
			asd.put( PdfName.CATEGORY, new PdfArray( category ) );
			asd.put( PdfName.OCGS, arr );
			arras.add( asd );
		}

		public static function create( output: ByteArray, pagesize: RectangleElement ): PdfWriter
		{
			trace('Welcome to ' + VERSION );
			var writer: PdfWriter = new PdfWriter( new Lock(), output, pagesize );
			return writer;
		}

		internal static function getISOBytes( text: String ): Bytes
		{
			if ( text == null )
				return null;
			var len: int = text.length;
			var byte: Bytes = new Bytes();

			for ( var k: int = 0; k < len; ++k )
				byte[ k ] = text.charCodeAt( k );
			return byte;
		}

		internal static function getVectorISOBytes( text: String ): Vector.<int>
		{
			if ( text == null )
				return null;
			var len: int = text.length;
			var byte: Vector.<int> = new Vector.<int>();

			for ( var k: int = 0; k < len; ++k )
				byte[ k ] = text.charCodeAt( k );
			return byte;
		}

		private static function getOCGOrder( order: PdfArray, layer: PdfLayer ): void
		{
			if ( !layer.onPanel )
				return;

			if ( layer.title == null )
				order.add( layer.ref );

			var children: Vector.<IPdfOCG> = layer.children;

			if ( children == null )
				return;

			var kids: PdfArray = new PdfArray();

			if ( layer.title != null )
				kids.add( new PdfString( layer.title, PdfObject.TEXT_UNICODE ) );

			for ( var k: int = 0; k < children.length; ++k )
			{
				getOCGOrder( kids, PdfLayer( children[ k ] ) );
			}

			if ( kids.size > 0 )
				order.add( kids );
		}
	}
}
