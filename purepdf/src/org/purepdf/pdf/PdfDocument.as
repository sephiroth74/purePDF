/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfDocument.as 394 2011-01-14 18:48:14Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 394 $ $LastChangedDate: 2011-01-14 13:48:14 -0500 (Fri, 14 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfDocument.as $
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
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.IObject;
	import it.sephiroth.utils.collections.iterators.Iterator;
	import it.sephiroth.utils.hashLib;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Anchor;
	import org.purepdf.elements.Annotation;
	import org.purepdf.elements.ChapterAutoNumber;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.HeaderFooter;
	import org.purepdf.elements.IElement;
	import org.purepdf.elements.IElementListener;
	import org.purepdf.elements.ILargeElement;
	import org.purepdf.elements.List;
	import org.purepdf.elements.ListItem;
	import org.purepdf.elements.Meta;
	import org.purepdf.elements.MultiColumnText;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.Section;
	import org.purepdf.elements.SimpleTable;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.events.ChapterEvent;
	import org.purepdf.events.ChunkEvent;
	import org.purepdf.events.DocumentEvent;
	import org.purepdf.events.PageEvent;
	import org.purepdf.events.SectionEvent;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.forms.PdfFormField;
	import org.purepdf.utils.iterators.VectorIterator;
	import org.purepdf.utils.pdf_core;

	[Event( name="documentClose",	type="org.purepdf.events.PageEvent" )]
	[Event( name="pageEnd", 		type="org.purepdf.events.PageEvent" )]
	[Event( name="pageStart", 		type="org.purepdf.events.PageEvent" )]
	[Event( name="documentOpen", 	type="org.purepdf.events.PageEvent" )]
	[Event( name="chapterStart", 	type="org.purepdf.events.ChapterEvent" )]
	[Event( name="chapterEnd", 		type="org.purepdf.events.ChapterEvent" )]
	[Event( name="sectionStart", 	type="org.purepdf.events.SectionEvent" )]
	[Event( name="sectionEnd", 		type="org.purepdf.events.SectionEvent" )]
	[Event( name="paragraphStart", 	type="org.purepdf.events.ParagraphEvent" )]
	[Event( name="paragraphEnd", 	type="org.purepdf.events.ParagraphEvent" )]
	[Event( name="genericTag", 		type="org.purepdf.events.ChunkEvent" )]
	
	[Event( name="saveStart", 		type="org.purepdf.events.DocumentEvent" )]
	[Event( name="saveComplete", 	type="org.purepdf.events.DocumentEvent" )]
	[Event( name="progress", 		type="flash.events.ProgressEvent" )]

	/**
	 * 
	 * @see org.purepdf.events.SectionEvent
	 * @see org.purepdf.events.ChapterEvent
	 * @see org.purepdf.events.ParagraphEvent
	 * @see org.purepdf.events.PageEvent
	 */
	public class PdfDocument extends EventDispatcher implements IObject, IElementListener
	{
		public static var compress: Boolean = true;
		internal static const hangingPunctuation: String = ".,;:'";
		use namespace pdf_core;
		
		public static const DOCUMENT_CLOSE: PdfName = PdfName.WC;
		public static const WILL_SAVE: PdfName = PdfName.WS;
		public static const DID_SAVE: PdfName = PdfName.DS;
		public static const WILL_PRINT: PdfName = PdfName.WP;
		public static const DID_PRINT: PdfName = PdfName.DP;

		public static const wmfFontCorrection: Number = 0.86;
		
		protected var _duration: int = -1;
		protected var _hashCode: int;
		protected var _pageResources: PageResources;
		protected var _pageSize: RectangleElement;
		protected var _transition: PdfTransition = null;
		protected var _writer: PdfWriter;
		protected var alignment: int = Element.ALIGN_LEFT;
		protected var anchorAction: PdfAction = null;
		protected var annotationsImp: PdfAnnotationsImp;
		protected var boxSize: HashMap = new HashMap();
		protected var closed: Boolean;
		protected var currentHeight: Number = 0;
		protected var currentOutline: PdfOutline;
		protected var firstPageEvent: Boolean = true;
		protected var graphics: PdfContentByte;
		protected var imageEnd: Number = -1;
		protected var imageWait: ImageElement;
		protected var indentation: Indentation = new Indentation();
		protected var info: PdfInfo = new PdfInfo();
		protected var isSectionTitle: Boolean = false;
		protected var lastElementType: int = -1;
		protected var leading: Number = 0;
		protected var leadingCount: int = 0;
		protected var line: PdfLine = null;
		protected var lines: Vector.<PdfLine> = new Vector.<PdfLine>();
		protected var _marginBottom: Number = 36.0;
		protected var _marginLeft: Number = 36.0;
		protected var _marginMirroring: Boolean = false;
		protected var marginMirroringTopBottom: Boolean = false;
		protected var _marginRight: Number = 36.0;
		protected var _marginTop: Number = 36.0;
		protected var markPoint: int = 0;
		protected var nextMarginBottom: Number = 36.0;
		protected var nextMarginLeft: Number = 36.0;
		protected var nextMarginRight: Number = 36.0;
		protected var nextMarginTop: Number = 36.0;
		protected var _nextPageSize: RectangleElement;
		protected var _opened: Boolean;
		protected var pageEmpty: Boolean = true;
		protected var pageN: int = 0;
		protected var rootOutline: PdfOutline;
		protected var strictImageSequence: Boolean = false;
		protected var text: PdfContentByte;
		protected var textEmptySize: int;
		protected var thisBoxSize: HashMap = new HashMap();
		protected var viewerPreferences: PdfViewerPreferencesImp = new PdfViewerPreferencesImp();
		protected var chapternumber: int = 0;
		protected var header: HeaderFooter = null;
		protected var footer: HeaderFooter = null;
		private var jsCount: int = 0;
		protected var documentLevelJS: HashMap = new HashMap();
		protected var documentFileAttachment: HashMap = new HashMap();
		protected var additionalActions: PdfDictionary;
		protected var thumb: PdfIndirectReference;
		protected var pageLabels: PdfPageLabels;

		public function PdfDocument( size: RectangleElement )
		{
			_pageSize = size;
			super();
			addProducer();
			addCreationDate();
		}
		
		pdf_core function getMarkPoint(): int
		{
			return markPoint;
		}
		
		pdf_core function incMarkPoint(): void
		{
			++markPoint;
		}

		public function get marginMirroring():Boolean
		{
			return _marginMirroring;
		}

		public function set marginMirroring(value:Boolean):void
		{
			_marginMirroring = value;
		}

		public function get marginTop():Number
		{
			return _marginTop;
		}

		public function get marginRight():Number
		{
			return _marginRight;
		}

		public function get marginLeft():Number
		{
			return _marginLeft;
		}

		public function get marginBottom():Number
		{
			return _marginBottom;
		}
		
		public function getCurrentPage(): PdfIndirectReference
		{
			return _writer.getCurrentPage();
		}
		
		/**
		 * @see PdfWriter#getPageReference()
		 */
		public function getPageReference( page: int ): PdfIndirectReference
		{
			return _writer.getPageReference( page );
		}
	

		/**
		 * Don't use this directly if you are 100% sure what
		 * you're doing. Use add() instead
		 *  
		 * @see addElement()
		 */
		
		
		
		public function addElement( element: IElement ): Boolean
		{
			if ( _writer != null && _writer.isPaused() )
				return false;

			var ptable: PdfPTable;
			var e_type: int = element.type;
			
			switch ( e_type )
			{
				case Element.PRODUCER:
					info.addProducer();
					break;
				case Element.CREATIONDATE:
					info.addCreationDate();
					break;
				case Element.AUTHOR:
					info.addAuthor( Meta( element ).getContent() );
					break;
				case Element.TITLE:
					info.addTitle( Meta( element ).getContent() );
					break;
				case Element.SUBJECT:
					info.addSubject( Meta( element ).getContent() );
					break;
				case Element.CREATOR:
					info.addCreator( Meta( element ).getContent() );
					break;
				case Element.KEYWORDS:
					info.addKeywords( Meta( element ).getContent() );
					break;
				case Element.RECTANGLE:
					var rectangle: RectangleElement = RectangleElement( element );
					graphics.rectangle( rectangle );
					pageEmpty = false;
					break;
				case Element.JPEG:
				case Element.JPEG2000:
				case Element.JBIG2:
				case Element.IMGRAW:
				case Element.IMGTEMPLATE:
					addImage( ImageElement( element ) );
					break;

				case Element.PARAGRAPH:
					leadingCount++;
					var paragraph: Paragraph = Paragraph( element );
					addSpacing( paragraph.spacingBefore, leading, paragraph.font );
					alignment = paragraph.alignment;
					leading = paragraph.totalLeading;
					carriageReturn();

					if ( currentHeight + line.height + leading > indentTop - indentBottom )
						newPage();

					indentation.indentLeft += paragraph.indentationLeft;
					indentation.indentRight += paragraph.indentationRight;
					carriageReturn();

					if ( paragraph.keeptogether )
					{
						throw new NonImplementatioError();
					}
					else
					{
						line.extraIndent = paragraph.firstLineIndent;
						element.process( this );
						carriageReturn();
						addSpacing( paragraph.spacingAfter, paragraph.totalLeading, paragraph.font );
					}

					alignment = Element.ALIGN_LEFT;
					indentation.indentLeft -= paragraph.indentationLeft;
					indentation.indentRight -= paragraph.indentationRight;
					carriageReturn();
					leadingCount--;
					break;
				
				case Element.ANNOTATION:
					if( line == null ) 
						carriageReturn();
					
					var annot: Annotation = element as Annotation;
					var rect: RectangleElement = new RectangleElement( 0, 0, 0, 0 );
					if (line != null)
						rect = new RectangleElement( 
							annot.getLlx( indentRight - line.widthLeft ), 
							annot.getUry(indentTop - currentHeight - 20), 
							annot.getUrx(indentRight - line.widthLeft + 20), 
							annot.getLly(indentTop - currentHeight));
					
					var an: PdfAnnotation = PdfAnnotationsImp.convertAnnotation( writer, annot, rect );
					annotationsImp.addPlainAnnotation( an );
					pageEmpty = false;
					break;

				case Element.PHRASE:
					leadingCount++;
					leading = Phrase( element ).leading;
					element.process( this );
					leadingCount--;
					break;

				case Element.CHUNK:
					if ( line == null )
						carriageReturn();

					var chunk: PdfChunk = PdfChunk.fromChunk( Chunk( element ), anchorAction );
					var overflow: PdfChunk;

					while ( ( overflow = line.add( chunk ) ) != null )
					{
						carriageReturn();
						chunk = overflow;
						chunk.trimFirstSpace();
					}
					pageEmpty = false;

					if ( chunk.isAttribute( Chunk.NEWPAGE ) )
						newPage();
					break;
				
				case Element.LIST:
					_addList( List( element ) );
					break;
				
				case Element.LISTITEM:
					_addListItem( ListItem( element ) );
					break;
				
				case Element.SECTION:
				case Element.CHAPTER:
					_addSection( Section(element) );
					break;
				
				case Element.ANCHOR:
					_addAnchor( Anchor(element) );
					break;

				case Element.PTABLE:
					ptable = PdfPTable(element);
					if( ptable.size <= ptable.headerRows )
						break;
					
					ensureNewLine();
					flushLines();
					
					_addPTable( ptable );
					pageEmpty = false;
					newLine();
					break;
				
				case Element.TABLE:
					if (element is SimpleTable )
					{
						ptable = SimpleTable(element).createPdfPTable();
						if( ptable.size <= ptable.headerRows )
							break;
						
						ensureNewLine();
						flushLines();
						_addPTable( ptable );
						pageEmpty = false;
						break;
					}
					break;
				
				case Element.MULTI_COLUMN_TEXT:
					ensureNewLine();
					flushLines();
					var multiText: MultiColumnText = MultiColumnText( element );
					var height: Number = multiText.write( writer.getDirectContent(), this, indentTop - currentHeight );
					currentHeight += height;
					text.moveText(0, -1* height);
					pageEmpty = false;
					break;
				
				default:
					throw new DocumentError( 'PdfDocument.add. Invalid type: ' + e_type );
			}
			lastElementType = element.type;
			return true;
		}

		public function addAnnotation( annot: PdfAnnotation ): void
		{
			pageEmpty = false;

			if ( annot.writer == null )
				annot.writer = _writer;
			annotationsImp.addAnnotation( annot );
		}
		
		/**
		 * Gets the current vertical page position.
		 * @param ensureNewLine Tells whether a new line shall be enforced
		 */
		public function getVerticalPosition( ensurenewline: Boolean ): Number
		{
			if( ensurenewline )
				ensureNewLine();
			
			return top() -  currentHeight - indentation.indentTop;
		}
		
		/**
		 * Add a JavaScript action at the document level.
		 * When the document opens, all this JavaScript runs.
		 * @param code the JavaScript code
		 * @param unicode select JavaScript unicode
		 * 
		 */
		public function addJavaScript( code: String, unicode: Boolean = false ): void
		{
			var action: PdfAction = PdfAction.javaScript( code, writer, unicode );
			
			if( action.getValue( PdfName.JS ) == null )
				throw new RuntimeError("only javascript actions are allowed");
			
			try 
			{
				documentLevelJS.put( (jsCount++).toFixed(16), _writer.addToBody(action).indirectReference );
			} catch( e: Error )
			{
				throw new ConversionError( e );
			}
		}
		
		/**
		 * Add a file attachment at the document level
		 * @param description	the file description
		 * @param file			file contents
		 * @param fileName		file name
		 */
		public function addFileAttachment( description: String, file: ByteArray, fileName: String ): void
		{
			var fs: PdfFileSpecification = PdfFileSpecification.fileEmbedded( _writer, fileName, file, false, null, null );

			if (description == null || description.length == 0)
				description = "Unnamed";
			
			fs.addDescription(description, true);
			
			var fn: String = PdfEncodings.convertToString(new PdfString(description, PdfObject.TEXT_UNICODE).getBytes(), null);
			var k: int = 0;
			
			while (documentFileAttachment.containsKey(fn)) {
				++k;
				fn = PdfEncodings.convertToString(new PdfString(description + " " + k, PdfObject.TEXT_UNICODE).getBytes(), null);
			}
			documentFileAttachment.put( fn, fs.reference );
		}
		
		/**
		 * Adds additional javascript action to the document
		 * 
		 * @see PdfDocument#DOCUMENT_CLOSE
		 * @see PdfDocument#WILL_SAVE
		 * @see PdfDocument#DID_SAVE
		 * @see PdfDocument#WILL_PRINT
		 * @see PdfDocument#DID_PRINT
		 */
		public function addAdditionalAction( actionType: PdfName, action: PdfAction ): void
		{
			if( !(actionType.equals(DOCUMENT_CLOSE) ||
					actionType.equals(WILL_SAVE) ||
					actionType.equals(DID_SAVE) ||
					actionType.equals(WILL_PRINT) ||
					actionType.equals(DID_PRINT)))
			{
				throw new DocumentError("invalid additional action type");
			}
			_addAdditionalAction(actionType, action);
		}
		
		private function _addAdditionalAction( actionType: PdfName, action: PdfAction ): void
		{
			if(additionalActions == null)  {
				additionalActions = new PdfDictionary();
			}
			if (action == null)
				additionalActions.remove(actionType);
			else
				additionalActions.put(actionType, action);
			if (additionalActions.size == 0)
				additionalActions = null;
		}

		public function addAuthor( value: String ): Boolean
		{
			return addElement( new Meta( Element.AUTHOR, value ) );
		}

		public function addCreator( creator: String ): Boolean
		{
			return addElement( new Meta( Element.CREATOR, creator ) );
		}

		/**
		 * Add a new element to the current pdf document
		 *
		 * @return true if the element was succesfully added to the documnet
		 * @see org.purepdf.elements.IElement
		 */
		public function add( element: IElement ): Boolean
		{
			if ( closed )
				throw new Error( "document is closed" );

			if ( !_opened && element.isContent )
				throw new Error( "document is not opened" );
			
			if( element is ChapterAutoNumber )
				chapternumber = ChapterAutoNumber(element).setAutomaticNumber( chapternumber );
			
			var success: Boolean = false;
			success = addElement( element );

			if ( element is ILargeElement )
			{
				var e: ILargeElement = ( element as ILargeElement );

				if ( !e.complete )
					e.flushContent();
			}
			return success;
		}

		public function addKeywords( keywords: String ): Boolean
		{
			return addElement( new Meta( Element.KEYWORDS, keywords ) );
		}

		public function addSubject( subject: String ): Boolean
		{
			return addElement( new Meta( Element.SUBJECT, subject ) );
		}

		public function addTitle( title: String ): Boolean
		{
			return addElement( new Meta( Element.TITLE, title ) );
		}

		public function bottom( margin: Number=0 ): Number
		{
			return _pageSize.getBottom( _marginBottom + margin );
		}

		/**
		 * Close the document
		 */
		public function close(): void
		{
			if ( closed )
				return;
			
			var wasImage: Boolean = imageWait != null;
			newPage();

			if ( imageWait != null || wasImage )
				newPage();

			if ( annotationsImp.hasUnusedAnnotations() )
			{
				throw new RuntimeError( "not all annotation could be added to the document" );
			}

			dispatchEvent( new DocumentEvent( DocumentEvent.SAVE_START ) );
			dispatchEvent( new PageEvent( PageEvent.DOCUMENT_CLOSE ) );

			writer.addLocalDestinations( localDestinations );
			
			calculateOutlineCount();
			
			writeOutlines();

			if ( !closed )
			{
				_opened = false;
				closed = true;
			}
			_writer.close();
		}

		/**
		 * Sets the display duration for the page (for presentations)
		 * @param seconds   the number of seconds to display the page
		 */
		public function set duration( seconds: int ): void
		{
			if ( seconds > 0 )
				_duration = seconds;
			else
				_duration = -1;
		}

		internal function getCatalog( pages: PdfIndirectReference ): PdfCatalog
		{
			trace( 'PdfDocument.getCatalog. to be implemented' );
			var catalog: PdfCatalog = new PdfCatalog( pages, _writer );

			// 1 outlines
			if( rootOutline.kids.length > 0 )
			{
				catalog.put( PdfName.PAGEMODE, PdfName.USEOUTLINES );
				catalog.put( PdfName.OUTLINES, rootOutline.indirectReference );
			}
			
			// 2 version
			_writer.getPdfVersion().addToCatalog( catalog );

			// 3 preferences
			viewerPreferences.addToCatalog( catalog );

			// 4 pagelables
			if( pageLabels != null )
				catalog.put( PdfName.PAGELABELS, pageLabels.getDictionary( _writer ) );
			
			// 5 named objects
			catalog.addNames( localDestinations, documentLevelJS, documentFileAttachment, _writer );
			
			// 6 actions
			if (additionalActions != null)   {
				catalog.setAdditionalActions(additionalActions);
			}
			
			// 7 portable collections
			// 8 acroform
			if (annotationsImp.hasValidAcroForm()) {
				try {
					catalog.put(PdfName.ACROFORM, writer.addToBody(annotationsImp.acroForm).indirectReference );
				}
				catch (e: Error ) {
					throw new ConversionError(e);
				}
			}
			
			return catalog;
		}
		
		/**
		 * Assign a thumbnail to the current page
		 * Acrobat/Reader 9 no longer use the embedded thumbnail.
		 * 
		 * @param image
		 * @throws DocumentError
		 */
		[Deprecated]
		public function setThumbnail( image: ImageElement ): void
		{
			thumb = writer.getImageReference( writer.addDirectImageSimple( image ) );
		}
		
		/**
		 * Sets the page labels
		 * @param pageLabels the page labels
		 */
		public function setPageLabels( pageLabels: PdfPageLabels ): void
		{
			this.pageLabels = pageLabels;
		}
		
		public function setHeader( value: HeaderFooter ): void
		{
			header = value;
		}
		
		public function setFooter( value: HeaderFooter ): void
		{
			footer = value;
		}
		
		public function resetHeader(): void
		{
			header = null;
		}
		
		public function resetFooter(): void
		{
			footer = null;
		}
		
		public function resetPageCount(): void
		{
			pageN = 0;
		}

		public function getDefaultColorSpace(): PdfDictionary
		{
			return _writer.getDefaultColorSpace();
		}

		public function getDirectContent(): PdfContentByte
		{
			return _writer.getDirectContent();
		}
		
		public function getDirectContentUnder(): PdfContentByte
		{
			return _writer.getDirectContentUnder();
		}

		public function getInfo(): PdfInfo
		{
			return info;
		}

		public function get pageNumber(): int
		{
			return pageN;
		}

		public function hashCode(): int
		{
			if ( isNaN( _hashCode ) )
				_hashCode = hashLib.hashCode( getQualifiedClassName( this ), 36 );
			return _hashCode;
		}

		/**
		 * Return true if the document is already opened
		 */
		public function get opened(): Boolean
		{
			return _opened;
		}

		public function get isPageEmpty(): Boolean
		{
			return _writer == null || ( _writer.getDirectContent().size == 0 && _writer.getDirectContentUnder().size == 0 && ( pageEmpty
				|| _writer.isPaused() ) );
		}

		public function left( margin: Number=0 ): Number
		{
			return _pageSize.getLeft( _marginLeft + margin );
		}

		/**
		 * Use this method to lock a content group
		 * The state of a locked group can not be changed using the user
		 * interface of a viewer application
		 */
		public function lockLayer( layer: PdfLayer ): void
		{
			_writer.lockLayer( layer );
		}

		/**
		 * make a new page
		 */
		public function newPage(): Boolean
		{
			lastElementType = -1;

			if ( isPageEmpty )
			{
				setNewPageSizeAndMargins();
				return false;
			}

			if ( !_opened || closed )
			{
				throw new Error( "Document is not opened" );
			}
			dispatchEvent( new PageEvent( PageEvent.PAGE_END ) );

			// flush the arraylist with recently written lines
			flushLines();

			// prepare the elements of the page dictionary
			
			// [U1] page size and rotation
			var rotation: int = _pageSize.rotation;
			
			// [C10]
			// writer.isPdfX(): not yet implemented

			// [M1]
			pageResources.addDefaultColorDiff( writer.getDefaultColorSpace() );

			if ( writer.isRgbTransparencyBlending() )
			{
				var dcs: PdfDictionary = new PdfDictionary();
				dcs.put( PdfName.CS, PdfName.DEVICERGB );
				pageResources.addDefaultColorDiff( dcs );
			}

			var resources: PdfDictionary = _pageResources.getResources();

			// create the page dictionary
			var page: PdfPage = new PdfPage( PdfRectangle.create( _pageSize, rotation ), thisBoxSize, resources, rotation );
			page.put( PdfName.TABS, _writer.getTabs() );
			
			// complete the page dictionary
			
			// [C9] if there is XMP data to add: add it
			// xmpMetadata: not yet implemented

			// [U3] page actions: transition, duration, additional actions
			if ( _transition != null )
			{
				page.put( PdfName.TRANS, _transition.getTransitionDictionary() );
				_transition = null;
			}

			if ( _duration > 0 )
			{
				page.put( PdfName.DUR, new PdfNumber( _duration ) );
				_duration = 0;
			}
			
			// [U4] we add the thumbs
			if( thumb != null )
			{
				page.put( PdfName.THUMB, thumb );
				thumb = null;
			}

			// [U8] we check if the userunit is defined
			if( writer.userunit > 0 )
				page.put( PdfName.USERUNIT, new PdfNumber( writer.userunit ) );

			// [C5] and [C8] we add the annotations
			if ( annotationsImp.hasUnusedAnnotations() )
			{
				var array: PdfArray = annotationsImp.rotateAnnotations( _writer, _pageSize );

				if ( array.size != 0 )
					page.put( PdfName.ANNOTS, array );
			}
			
			// [F12] we add tag info
			if( _writer.tagged )
				page.put( PdfName.STRUCTPARENTS, new PdfNumber( _writer.getCurrentPageNumber() - 1 ) );
			
			if ( text.size > textEmptySize )
				text.endText();
			else
				text = null;

			_writer.add( page, new PdfContents( _writer.getDirectContentUnder(), graphics, text, _writer.getDirectContent(), _pageSize ) );
			// initialize the new page
			initPage();
			return true;
		}

		/**
		 * open the document
		 *
		 */
		public function open(): void
		{
			if ( !_opened )
			{
				_opened = true;
				pageSize = _pageSize;
				setMargins( _marginLeft, _marginRight, _marginTop, _marginBottom );
				_writer.open();
				rootOutline = new PdfOutline( _writer );
				currentOutline = rootOutline;
				initPage();
			}
			else
			{
				throw new Error( "Document is already opened" );
			}
		}

		public function get pageResources(): PageResources
		{
			return _pageResources;
		}

		/**
		 * Return the current pagesize
		 *
		 */
		public function get pageSize(): RectangleElement
		{
			return _pageSize;
		}

		/**
		 * Set the pagesize
		 *
		 */
		public function set pageSize( value: RectangleElement ): void
		{
			if ( _writer != null && _writer.isPaused() )
				return;
			
			if( !opened )
				_pageSize = RectangleElement.clone( value );
			
			_nextPageSize = RectangleElement.clone( value );
		}

		public function right( margin: Number=0 ): Number
		{
			return _pageSize.getRight( _marginRight + margin );
		}

		public function setDefaultColorSpace( key: PdfName, value: PdfObject ): void
		{
			_writer.setDefaultColorSpace( key, value );
		}

		public function setMargins( marginLeft: Number, marginRight: Number, marginTop: Number, marginBottom: Number ): Boolean
		{
			if ( _writer != null && _writer.isPaused() )
			{
				return false;
			}
			
			if( !_opened )
			{
				_marginBottom = marginBottom;
				_marginLeft = marginLeft;
				_marginRight = marginRight;
				_marginTop = marginTop;
			}
			
			nextMarginLeft = marginLeft;
			nextMarginRight = marginRight;
			nextMarginTop = marginTop;
			nextMarginBottom = marginBottom;
			return true;
		}

		public function setPdfVersion( value: String ): void
		{
			_writer.setPdfVersion( value );
		}

		
		/**
		 * <p>Use this method to set the user unit</p>
		 * <p>A UserUnit is a value that defines the default user space unit</p>
		 * <p>The minimum UserUnit is 1 (1 unit = 1/72 inch).</p>
		 * <p>The maximum UserUnit is 75,000.</p>
		 * <p>Remember that you need to set the pdf version to 1.6</p>
		 * @throws DocumentError
		 * @since 1.6
		 */
		public function set userunit( value: Number ): void
		{
			writer.userunit = value;
		}
		
		public function get userunit(): Number
		{
			return writer.userunit;
		}
		
		/**
		 * Set the view preferences for this document
		 *
		 * @see org.purepdf.pdf.PdfViewPreferences
		 */
		public function setViewerPreferences( preferences: int ): void
		{
			viewerPreferences.setViewerPreferences( preferences );
		}

		public function top( margin: Number=0 ): Number
		{
			return _pageSize.getTop( _marginTop + margin );
		}

		/**
		 * Set the transition for the page
		 */
		public function set transition( value: PdfTransition ): void
		{
			_transition = value;
		}

		public function get writer(): PdfWriter
		{
			return _writer;
		}


		/**
		 * Adds extra space.
		 * This method should probably be rewritten.
		 */
		protected function addSpacing( extraspace: Number, oldleading: Number, f: Font ): void
		{
			if ( extraspace == 0 )
				return;

			if ( pageEmpty )
				return;

			if ( currentHeight + line.height + leading > indentTop - indentBottom )
				return;
			leading = extraspace;
			carriageReturn();

			if ( f.isUnderline || f.isStrikethru )
			{
				f = f.clone() as Font;
				var style: int = f.style;
				style &= ~Font.UNDERLINE;
				style &= ~Font.STRIKETHRU;
				f.style = style;
			}
			var space: Chunk = new Chunk( " ", f );
			space.process( this );
			carriageReturn();
			leading = oldleading;
		}

		protected function carriageReturn(): void
		{
			if ( lines == null )
				lines = new Vector.<PdfLine>();

			if ( line != null )
			{
				if ( currentHeight + line.height + leading < indentTop - indentBottom )
				{
					if ( line.size > 0 )
					{
						currentHeight += line.height;
						lines.push( line );
						pageEmpty = false;
					}
				}
				else
				{
					newPage();
				}
			}

			if ( imageEnd > -1 && currentHeight > imageEnd )
			{
				imageEnd = -1;
				indentation.imageIndentRight = 0;
				indentation.imageIndentLeft = 0;
			}
			line = new PdfLine( indentLeft, indentRight, alignment, leading );
		}

		/**
		 * Ensure a new line is started
		 */
		protected function ensureNewLine(): void
		{
			try 
			{
				if( ( lastElementType == Element.PHRASE ) || (lastElementType == Element.CHUNK) )
				{
					newLine();
					flushLines();
				}
			} catch ( ex: DocumentError ) {
				throw new ConversionError(ex);
			}
		}
		
		protected function flushLines(): Number
		{
			if ( lines == null )
				return 0;

			if ( line != null && line.size > 0 )
			{
				lines.push( line );
				line = new PdfLine( indentLeft, indentRight, alignment, leading );
			}

			if ( lines.length == 0 )
				return 0;


			var currentValues: Vector.<Object> = new Vector.<Object>( 2 );
			var currentFont: PdfFont = null;
			var displacement: Number = 0;
			var l: PdfLine;
			var lastBaseFactor: Number = 0;
			currentValues[ 1 ] = lastBaseFactor;

			for ( var i: Iterator = new VectorIterator( Vector.<Object>( lines ) ); i.hasNext();  )
			{
				l = PdfLine( i.next() );

				var moveTextX: Number = l.indentLeft - indentLeft + indentation.indentLeft + indentation.listIndentLeft + indentation.sectionIndentLeft;
				text.moveText( moveTextX, -l.height );

				if ( l.listSymbol != null )
				{
					//throw new NonImplementatioError();
					ColumnText.showTextAligned( graphics, Element.ALIGN_LEFT, Phrase.fromChunk( l.listSymbol ), text.xTLM - l.listIndent, text.yTLM, 0 );
				}

				currentValues[ 0 ] = currentFont;
				writeLineToContent( l, text, graphics, currentValues, _writer.spaceCharRatio );

				currentFont = PdfFont( currentValues[ 0 ] );
				displacement += l.height;
				text.moveText( -moveTextX, 0 );

			}

			lines = new Vector.<PdfLine>();
			return displacement;
		}

		protected function get indentBottom(): Number
		{
			return bottom( indentation.indentBottom );
		}

		protected function get indentLeft(): Number
		{
			return left( indentation.indentLeft + indentation.listIndentLeft + indentation.imageIndentLeft + indentation.sectionIndentLeft );
		}

		protected function get indentRight(): Number
		{
			return right( indentation.indentRight + indentation.sectionIndentRight + indentation.imageIndentRight );
		}

		protected function get indentTop(): Number
		{
			return top( indentation.indentTop );
		}

		protected function initPage(): void
		{
			pageN++;
			annotationsImp.resetAnnotations();
			_pageResources = new PageResources();
			_writer.resetContent();
			graphics = new PdfContentByte( _writer );
			text = new PdfContentByte( _writer );
			text.reset();
			text.beginText();
			textEmptySize = text.size;
			markPoint = 0;
			setNewPageSizeAndMargins();
			imageEnd = -1;
			currentHeight = 0;
			thisBoxSize = new HashMap();

			if ( _pageSize.backgroundColor != null || _pageSize.hasBorders() || _pageSize.borderColor != null )
			{
				addElement( _pageSize );
			}
			var oldleading: Number = leading;
			var oldAlignment: int = alignment;
			doFooter();
			text.moveText( left(), top() );
			doHeader();
			pageEmpty = true;

			try
			{
				if ( imageWait != null )
				{
					addElement( imageWait );
					imageWait = null;
				}
			}
			catch ( e: Error )
			{
				throw new ConversionError( e );
			}
			leading = oldleading;
			alignment = oldAlignment;
			carriageReturn();

			if ( firstPageEvent )
				dispatchEvent( new PageEvent( PageEvent.DOCUMENT_OPEN ) );
			dispatchEvent( new PageEvent( PageEvent.PAGE_START ) );
			firstPageEvent = false;
		}

		/**
		 * Adds the current line to the list of lines and also adds an empty line.
		 */
		protected function newLine(): void
		{
			lastElementType = -1;
			carriageReturn();

			if ( lines != null && !( lines.length == 0 ) )
			{
				lines.push( line );
				currentHeight += line.height;
			}
			line = new PdfLine( indentLeft, indentRight, alignment, leading );
		}

		protected function setNewPageSizeAndMargins(): void
		{
			_pageSize = _nextPageSize;

			if ( _marginMirroring && ( pageN & 1 ) == 0 )
			{
				_marginRight = nextMarginLeft;
				_marginLeft = nextMarginRight;
			}
			else
			{
				_marginLeft = nextMarginLeft;
				_marginRight = nextMarginRight;
			}

			if ( marginMirroringTopBottom && ( pageN & 1 ) == 0 )
			{
				_marginTop = nextMarginBottom;
				_marginBottom = nextMarginTop;
			}
			else
			{
				_marginTop = nextMarginTop;
				_marginBottom = nextMarginBottom;
			}
		}


		internal function addCreationDate(): Boolean
		{
			return addElement( new Meta( Element.CREATIONDATE, null ) );
		}

		internal function addProducer(): Boolean
		{
			return addElement( new Meta( Element.PRODUCER, PdfWriter.VERSION ) );
		}

		internal function addWriter( w: PdfWriter ): void
		{
			if ( _writer == null )
			{
				_writer = w;
				annotationsImp = new PdfAnnotationsImp( _writer );
			}
		}

		internal function calculateOutlineCount(): void
		{
			if ( rootOutline.kids.length == 0 )
				return;
			traverseOutlineCount( rootOutline );
		}

		internal function outlineTree( outline: PdfOutline ): void
		{
			outline.indirectReference = _writer.pdfIndirectReference;

			if ( outline.parent != null )
				outline.put( PdfName.PARENT, outline.parent.indirectReference );
			var kids: Vector.<Object> = Vector.<Object>( outline.kids );
			var k: int;
			var size: int = kids.length;

			for ( k = 0; k < size; ++k )
				outlineTree( PdfOutline( kids[ k ] ) );

			for ( k = 0; k < size; ++k )
			{
				if ( k > 0 )
					PdfOutline( kids[ k ] ).put( PdfName.PREV, PdfOutline( kids[ k - 1 ] ).indirectReference );

				if ( k < size - 1 )
					PdfOutline( kids[ k ] ).put( PdfName.NEXT, PdfOutline( kids[ k + 1 ] ).indirectReference );
			}

			if ( size > 0 )
			{
				outline.put( PdfName.FIRST, PdfOutline( kids[ 0 ] ).indirectReference );
				outline.put( PdfName.LAST, PdfOutline( kids[ size - 1 ] ).indirectReference );
			}

			for ( k = 0; k < size; ++k )
			{
				var kid: PdfOutline = PdfOutline( kids[ k ] );
				_writer.addToBody1( kid, kid.indirectReference );
			}
		}

		internal function traverseOutlineCount( outline: PdfOutline ): void
		{
			var kids: Vector.<PdfOutline> = outline.kids;
			var parent: PdfOutline = outline.parent;

			if ( kids.length == 0 )
			{
				if ( parent != null )
					parent.count = parent.count + 1;
			}
			else
			{
				for ( var k: int = 0; k < kids.length; ++k )
					traverseOutlineCount( PdfOutline( kids[ k ] ) );

				if ( parent != null )
				{
					if ( outline.opened )
					{
						parent.count = outline.count + parent.count + 1;
					}
					else
					{
						parent.count = parent.count + 1;
						outline.count = -outline.count;
					}
				}
			}
		}

		/**
		 * Writes a text line to the document. It takes care of all the attributes.
		 * @throws DocumentError
		 * @throws Error
		 */
		pdf_core function writeLineToContent( line: PdfLine, text: PdfContentByte, graphics: PdfContentByte, currentValues: Vector.<Object>
			, ratio: Number ): void
		{
			var currentFont: PdfFont = PdfFont( currentValues[ 0 ] );
			var lastBaseFactor: Number = Number( currentValues[ 1 ] );
			var chunk: PdfChunk;
			var numberOfSpaces: int;
			var lineLen: int;
			var isJustified: Boolean;
			var hangingCorrection: Number = 0;
			var hScale: Number = 1;
			var lastHScale: Number = Number.NaN;
			var baseWordSpacing: Number = 0;
			var baseCharacterSpacing: Number = 0;
			var glueWidth: Number = 0;

			numberOfSpaces = line.numberOfSpaces
			lineLen = line.lengthUtf32;
			isJustified = line.hasToBeJustified && ( numberOfSpaces != 0 || lineLen > 1 );
			var separatorCount: int = line.separatorCount;

			if ( separatorCount > 0 )
			{
				glueWidth = line.widthLeft / separatorCount;
			}
			else if ( isJustified )
			{
				if( line.isNewlineSplit && line.widthLeft >= ( lastBaseFactor * ( ratio * numberOfSpaces + lineLen - 1) ) )
				{
					if( line.isRTL )
						text.moveText( line.widthLeft - lastBaseFactor * (ratio * numberOfSpaces + lineLen - 1), 0);
					
					baseWordSpacing = ratio * lastBaseFactor;
					baseCharacterSpacing = lastBaseFactor;
				} else {
					width = line.widthLeft;
					var last: PdfChunk = line.getChunk(line.size - 1);
					if (last != null) {
						var s: String = last.toString();
						var cs1: String;
						if( s.length > 0 && hangingPunctuation.indexOf( (cs1 = s.charAt( s.length - 1 ) ) ) >= 0)
						{
							var oldWidth: Number = width;
							width += last.font.getWidth(cs1) * 0.4;
							hangingCorrection = width - oldWidth;
						}
					}
					var baseFactor: Number = width / (ratio * numberOfSpaces + lineLen - 1);
					baseWordSpacing = ratio * baseFactor;
					baseCharacterSpacing = baseFactor;
					lastBaseFactor = baseFactor;
				}
			}

			var lastChunkStroke: int = line.lastStrokeChunk;
			var chunkStrokeIdx: int = 0;
			var xMarker: Number = text.xTLM;
			var baseXMarker: Number = xMarker;
			var yMarker: Number = text.yTLM;
			var adjustMatrix: Boolean = false;
			var tabPosition: Number = 0;
			var subtract: Number;
			var obj: Vector.<Object>;
			var k: int;

			for ( var j: Iterator = line.iterator(); j.hasNext();  )
			{
				
				
				chunk = PdfChunk( j.next() );
				var color: RGBColor = chunk.color;
				hScale = 1;

				if ( chunkStrokeIdx <= lastChunkStroke )
				{
					var width: Number = 0;
					if( isJustified )
					{
						throw new NonImplementatioError();
					} else
					{
						width = chunk.width;
					}
					
					if( chunk.isStroked() )
					{
						var nextChunk: PdfChunk = line.getChunk( chunkStrokeIdx + 1);
						if( chunk.isSeparator() )
						{
							throw new NonImplementatioError();						
						}
						
						if( chunk.isTab() )
						{
							throw new NonImplementatioError();
						}
						
						if( chunk.isAttribute( Chunk.BACKGROUND ) )
						{
							subtract = lastBaseFactor;
							if (nextChunk != null && nextChunk.isAttribute(Chunk.BACKGROUND))
								subtract = 0;
							if (nextChunk == null)
								subtract += hangingCorrection;
							var fontSize: Number = chunk.font.size;
							var ascender: Number = chunk.font.font.getFontDescriptor( BaseFont.ASCENT, fontSize);
							var descender: Number = chunk.font.font.getFontDescriptor( BaseFont.DESCENT, fontSize);
							var bgr: Vector.<Object> = Vector.<Object>( chunk.getAttribute(Chunk.BACKGROUND) );
							graphics.setColorFill( bgr[0] as RGBColor );
							var extra: Vector.<Number> = Vector.<Number>(bgr[1]);
							graphics.rectangle( xMarker - extra[0],
								yMarker + descender - extra[1] + chunk.getTextRise(),
								width - subtract + extra[0] + extra[2],
								ascender - descender + extra[1] + extra[3]);
							graphics.fill();
							graphics.setGrayFill(0);
						}
						
						if( chunk.isAttribute( Chunk.UNDERLINE ) )
						{
							subtract = lastBaseFactor;
							if( nextChunk != null && nextChunk.isAttribute(Chunk.UNDERLINE))
								subtract = 0;
							if (nextChunk == null)
								subtract += hangingCorrection;
							var unders: Vector.<Vector.<Object>> = Vector.<Vector.<Object>>( chunk.getAttribute(Chunk.UNDERLINE) );
							var scolor: RGBColor = null;
							for( k = 0; k < unders.length; ++k )
							{
								obj = unders[k];
								scolor = RGBColor(obj[0]);
								var ps: Vector.<Number> = Vector.<Number>(obj[1]);
								if (scolor == null)
									scolor = color;
								if (scolor != null)
									graphics.setColorStroke( scolor );
								var fsize: Number = chunk.font.size;
								graphics.setLineWidth( ps[0] + fsize * ps[1] );
								var shift: Number = ps[2] + fsize * ps[3];
								var cap2: int = ps[4];
								if (cap2 != 0)
									graphics.setLineCap( cap2 );
								graphics.moveTo( xMarker, yMarker + shift );
								graphics.lineTo( xMarker + width - subtract, yMarker + shift );
								graphics.stroke();
								if (scolor != null)
									graphics.resetStroke();
								if (cap2 != 0)
									graphics.setLineCap( 0 );
							}
							graphics.setLineWidth(1);
						}
						
						if( chunk.isAttribute( Chunk.ACTION ) )
						{
							subtract = lastBaseFactor;
							if( nextChunk != null && nextChunk.isAttribute( Chunk.ACTION ) )
								subtract = 0;
							if( nextChunk == null )
								subtract += hangingCorrection;
							text.addAnnotation( PdfAnnotation.createAction( _writer, new RectangleElement( xMarker, yMarker, xMarker + width - subtract, yMarker + chunk.font.size ), PdfAction(chunk.getAttribute( Chunk.ACTION )) ) );
						}
						
						if( chunk.isAttribute( Chunk.REMOTEGOTO ) )
						{
							throw new NonImplementatioError();
						}
						
						if( chunk.isAttribute( Chunk.LOCALGOTO ) )
						{
							subtract = lastBaseFactor;
							if( nextChunk != null && nextChunk.isAttribute( Chunk.LOCALGOTO ) )
								subtract = 0;
							if (nextChunk == null)
								subtract += hangingCorrection;
							localGoto( String(chunk.getAttribute(Chunk.LOCALGOTO)), xMarker, yMarker, xMarker + width - subtract, yMarker + chunk.font.size);
						}
						
						if( chunk.isAttribute( Chunk.LOCALDESTINATION ) )
						{
							subtract = lastBaseFactor;
							if (nextChunk != null && nextChunk.isAttribute(Chunk.LOCALDESTINATION))
								subtract = 0;
							if (nextChunk == null)
								subtract += hangingCorrection;
							localDestination( String( chunk.getAttribute(Chunk.LOCALDESTINATION) ), PdfDestination.create2( xMarker, yMarker + chunk.font.size, 0 ) );
						}
						
						if( chunk.isAttribute( Chunk.GENERICTAG ) )
						{
							_writeLineToContent_GenericTag( lastBaseFactor, chunk, nextChunk, hangingCorrection, xMarker, yMarker, width );
						}
						
						if( chunk.isAttribute( Chunk.PDFANNOTATION ) )
						{
							_writeLineToContent_PdfAnnotation( lastBaseFactor, chunk, nextChunk, text, hangingCorrection, xMarker, yMarker, width );
						}
						
						var params: Vector.<Number> = chunk.getAttribute( Chunk.SKEW ) as Vector.<Number>;
						var hs: Object =  chunk.getAttribute(Chunk.HSCALE);
						
						if( params != null || hs != null )
						{
							var b: Number = 0, c: Number = 0;
							if (params != null)
							{
								b = params[0];
								c = params[1];
							}
							
							if( hs != null )
								hScale = Number( hs );
							text.setTextMatrix( hScale, b, c, 1, xMarker, yMarker );
						}
						
						if( chunk.isAttribute(Chunk.CHAR_SPACING) )
						{
							var cs: Number = Number( chunk.getAttribute(Chunk.CHAR_SPACING) );
							text.setCharacterSpacing(cs);
						}
						
						if( chunk.isImage() )
						{
							var image: ImageElement = chunk.image;
							var matrix: Vector.<Number> = image.matrix;
							matrix[ImageElement.CX] = xMarker + chunk.imageOffsetX - matrix[ImageElement.CX];
							matrix[ImageElement.CY] = yMarker + chunk.imageOffsetY - matrix[ImageElement.CY];
							
							graphics.addImage3( image, matrix[0], matrix[1], matrix[2], matrix[3], matrix[4], matrix[5]);
							text.moveText( xMarker + lastBaseFactor + image.scaledWidth - text.xTLM, 0 );
						}
					}
					
					xMarker += width;
					++chunkStrokeIdx;
				}

				if ( chunk.font.compareTo( currentFont ) != 0 )
				{
					currentFont = chunk.font;
					text.setFontAndSize( currentFont.font, currentFont.size );
				}

				var rise: Number = 0;
				var textRender: Vector.<Object> = chunk.getAttribute( Chunk.TEXTRENDERMODE ) as Vector.<Object>;
				var tr: int = 0;
				var strokeWidth: Number = 1;
				var strokeColor: RGBColor = null;
				var fr: Object = ( chunk.getAttribute( Chunk.SUBSUPSCRIPT ) );

				if( textRender != null )
				{
					tr = int(textRender[0]) & 3;
					if( tr != PdfContentByte.TEXT_RENDER_MODE_FILL )
						text.setTextRenderingMode( tr );
					if( tr == PdfContentByte.TEXT_RENDER_MODE_STROKE || tr == PdfContentByte.TEXT_RENDER_MODE_FILL_STROKE )
					{
						strokeWidth = Number(textRender[1]);
						if (strokeWidth != 1)
							text.setLineWidth( strokeWidth );
						strokeColor = textRender[2] as RGBColor;
						if( strokeColor == null )
							strokeColor = color;
						if( strokeColor != null )
							text.setColorStroke( strokeColor );
					}
				}

				if ( fr != null )
					rise = Number( fr );

				if ( color != null )
					text.setColorFill( color );

				if ( rise != 0 )
					text.setTextRise( rise );

				if ( chunk.isImage() )
					adjustMatrix = true;
				else if ( chunk.isHorizontalSeparator() )
				{
					throw new NonImplementatioError();
				}
				else if ( chunk.isTab() )
				{
					throw new NonImplementatioError();
				}
				else if ( isJustified && numberOfSpaces > 0 && chunk.isSpecialEncoding() )
				{
					throw new NonImplementatioError();
				}
				else
				{
					if ( isJustified && hScale != lastHScale )
					{
						lastHScale = hScale;
						text.setWordSpacing( baseWordSpacing / hScale );
						text.setCharacterSpacing( baseCharacterSpacing / hScale + text.getCharacterSpacing() );
					}
					text.showText( chunk.toString() );
				}

				if ( rise != 0 )
					text.setTextRise( 0 );

				if ( color != null )
					text.resetFill();

				if ( tr != PdfContentByte.TEXT_RENDER_MODE_FILL )
					text.setTextRenderingMode( PdfContentByte.TEXT_RENDER_MODE_FILL );

				if ( strokeColor != null )
					text.resetStroke();

				if ( strokeWidth != 1 )
					text.setLineWidth( 1 );

				if ( chunk.isAttribute( Chunk.SKEW ) || chunk.isAttribute( Chunk.HSCALE ) )
				{
					adjustMatrix = true;
					text.setTextMatrix( 1, 0, 0, 1, xMarker, yMarker );
				}

				if ( chunk.isAttribute( Chunk.CHAR_SPACING ) )
				{
					text.setCharacterSpacing( baseCharacterSpacing );
				}
				
				
				
			}

			if ( isJustified )
			{
				text.setWordSpacing( 0 );
				text.setCharacterSpacing( 0 );

				if ( line.isNewlineSplit )
					lastBaseFactor = 0;
			}

			if ( adjustMatrix )
				text.moveText( baseXMarker - text.xTLM, 0 );
			currentValues[ 0 ] = currentFont;
			currentValues[ 1 ] = lastBaseFactor;
		}

		internal function writeOutlines(): void
		{
			if ( rootOutline.kids.length == 0 )
				return;

			outlineTree( rootOutline );
			_writer.addToBody1( rootOutline, rootOutline.indirectReference );
		}

		private function addImage( image: ImageElement ): void
		{
			if ( image.hasAbsoluteY )
			{
				graphics.addImage( image );
				pageEmpty = false;
				return;
			}

			if ( currentHeight != 0 && indentTop - currentHeight - image.scaledHeight < indentBottom )
			{
				if ( !strictImageSequence && imageWait == null )
				{
					imageWait = image;
					return;
				}
				newPage();

				if ( currentHeight != 0 && indentTop - currentHeight - image.scaledHeight < indentBottom )
				{
					imageWait = image;
					return;
				}
			}
			pageEmpty = false;

			if ( image == imageWait )
				imageWait = null;
			var textwrap: Boolean = ( image.alignment & ImageElement.TEXTWRAP ) == ImageElement.TEXTWRAP && !( ( image.alignment & ImageElement
				.MIDDLE ) == ImageElement.MIDDLE );
			var underlying: Boolean = ( image.alignment & ImageElement.UNDERLYING ) == ImageElement.UNDERLYING;
			var diff: Number = leading / 2;

			if ( textwrap )
				diff += leading;
			var lowerleft: Number = indentTop - currentHeight - image.scaledHeight - diff;
			var mt: Vector.<Number> = image.matrix;
			var startPosition: Number = indentLeft - mt[ 4 ];

			if ( ( image.alignment & ImageElement.RIGHT ) == ImageElement.RIGHT )
				startPosition = indentRight - image.scaledWidth - mt[ 4 ];

			if ( ( image.alignment & ImageElement.MIDDLE ) == ImageElement.MIDDLE )
				startPosition = indentLeft + ( ( indentRight - indentLeft - image.scaledWidth ) / 2 ) - mt[ 4 ];

			if ( image.hasAbsoluteX )
				startPosition = image.absoluteX;

			if ( textwrap )
			{
				if ( imageEnd < 0 || imageEnd < currentHeight + image.scaledHeight + diff )
					imageEnd = currentHeight + image.scaledHeight + diff;

				if ( ( image.alignment & ImageElement.RIGHT ) == ImageElement.RIGHT )
					indentation.imageIndentRight += image.scaledWidth + image.indentationLeft;
				else
					indentation.imageIndentLeft += image.scaledWidth + image.indentationRight;
			}
			else
			{
				if ( ( image.alignment & ImageElement.RIGHT ) == ImageElement.RIGHT )
					startPosition -= image.indentationRight;
				else if ( ( image.alignment & ImageElement.MIDDLE ) == ImageElement.MIDDLE )
					startPosition += image.indentationLeft - image.indentationRight;
				else
					startPosition += image.indentationLeft;
			}
			graphics.addImage3( image, mt[ 0 ], mt[ 1 ], mt[ 2 ], mt[ 3 ], startPosition, lowerleft - mt[ 5 ] );

			if ( !( textwrap || underlying ) )
			{
				currentHeight += image.scaledHeight + diff;
				flushLines();
				text.moveText( 0, -( image.scaledHeight + diff ) );
				newLine();
			}
		}

		private function addViewerPreference( key: PdfName, value: PdfObject ): void
		{
			viewerPreferences.addViewerPreference( key, value );
		}
		
		/**
		 * Implements a link to other part of the document. The jump will
		 * be made to a local destination with the same name, that must exist.
		 * @param name the name for this link
		 * @param llx the lower left x corner of the activation area
		 * @param lly the lower left y corner of the activation area
		 * @param urx the upper right x corner of the activation area
		 * @param ury the upper right y corner of the activation area
		 */
		internal function localGoto( name: String, llx: Number, lly: Number, urx: Number, ury: Number ): void
		{
			var action: PdfAction = getLocalGotoAction( name );
			annotationsImp.addPlainAnnotation( PdfAnnotation.createAction( _writer, new RectangleElement( llx, lly, urx, ury ), action ) );
		}

		/**
		 * The local destination to where a local goto with the same
		 * name will jump to.
		 * @param name the name of this local destination
		 * @param destination the <CODE>PdfDestination</CODE> with the jump coordinates
		 * @return <CODE>true</CODE> if the local destination was added,
		 * <CODE>false</CODE> if a local destination with the same name
		 * already existed
		 */
		internal function localDestination( name: String, destination: PdfDestination ): Boolean
		{
			var obj: Vector.<Object> = localDestinations.getValue( name ) as Vector.<Object>;

			if ( obj == null )
				obj = new Vector.<Object>( 3, true );

			if ( obj[ 2 ] != null )
				return false;
			obj[ 2 ] = destination;
			localDestinations.put( name, obj );

			if ( !destination.hasPage )
				destination.addPage( _writer.getCurrentPage() );
			return true;
		}
		
		protected var localDestinations: HashMap = new HashMap();
		
		private function getLocalGotoAction( name: String ): PdfAction
		{
			var action: PdfAction;
			var obj: Vector.<Object> = localDestinations.getValue(name) as Vector.<Object>;
			if (obj == null)
				obj = new Vector.<Object>(3, true);
			if (obj[0] == null) {
				if (obj[1] == null) {
					obj[1] = _writer.pdfIndirectReference;
				}
				action = PdfAction.fromDestination( obj[1] as PdfIndirectReference );
				obj[0] = action;
				localDestinations.put(name, obj);
			} else 
			{
				action = obj[0] as PdfAction;
			}
			return action;
		}
		
		// --------------------
		// Helper for writeLineToContent
		// --------------------
		
		private function _writeLineToContent_GenericTag( lastBaseFactor: Number, chunk: PdfChunk, nextChunk: PdfChunk, hangingCorrection: Number, xMarker: Number, yMarker: Number, width: Number ): void
		{
			var subtract: Number = lastBaseFactor;
			if( nextChunk != null && nextChunk.isAttribute( Chunk.GENERICTAG ) )
				subtract = 0;
			if( nextChunk == null )
				subtract += hangingCorrection;
			var rect: RectangleElement = new RectangleElement( xMarker, yMarker, xMarker + width - subtract, yMarker + chunk.font.size );

			dispatchEvent( new ChunkEvent( ChunkEvent.GENERIC_TAG, rect, String(chunk.getAttribute( Chunk.GENERICTAG )) ) );
		}
		
		private function _writeLineToContent_PdfAnnotation( lastBaseFactor: Number, chunk: PdfChunk, nextChunk: PdfChunk, text: PdfContentByte, hangingCorrection: 
															Number, xMarker: Number, yMarker: Number, width: Number ): void
		{
			var subtract: Number = lastBaseFactor;
			if (nextChunk != null && nextChunk.isAttribute(Chunk.PDFANNOTATION))
				subtract = 0;
			if (nextChunk == null)
				subtract += hangingCorrection;
			var fontSize: Number = chunk.font.size;
			var ascender: Number = chunk.font.font.getFontDescriptor(BaseFont.ASCENT, fontSize);
			var descender: Number = chunk.font.font.getFontDescriptor(BaseFont.DESCENT, fontSize);
			var annot: PdfAnnotation = PdfFormField.shallowDuplicate( PdfAnnotation( chunk.getAttribute(Chunk.PDFANNOTATION) ) );
			
			annot.put( PdfName.RECT, new PdfRectangle(xMarker, yMarker + descender, xMarker + width - subtract, yMarker + ascender));
			text.addAnnotation( annot );
		}
		
		/**
		 * Draw the document footer
		 * 
		 * @throws DocumentError
		 */
		protected function doFooter(): void
		{
			if (footer == null) return;
			
			var tmpIndentLeft: Number = indentation.indentLeft;
			var tmpIndentRight: Number = indentation.indentRight;
			
			var tmpListIndentLeft: Number = indentation.listIndentLeft;
			var tmpImageIndentLeft: Number = indentation.imageIndentLeft;
			var tmpImageIndentRight: Number = indentation.imageIndentRight;
			
			indentation.indentLeft = indentation.indentRight = 0;
			indentation.listIndentLeft = 0;
			indentation.imageIndentLeft = 0;
			indentation.imageIndentRight = 0;
			footer.pageNumber = pageN;
			
			var p: Paragraph = footer.paragraph;
			
			leading = p.totalLeading;
			add( p );
			
			indentation.indentBottom = currentHeight;
			text.moveText(left(), indentBottom );
			flushLines();
			text.moveText(-left(), -bottom());
			footer.setTop(bottom(currentHeight));
			footer.setBottom(bottom() - (0.75 * leading));
			footer.setLeft(left());
			footer.setRight(right());
			graphics.rectangle(footer);
			indentation.indentBottom = currentHeight + leading * 2;
			currentHeight = 0;
			indentation.indentLeft = tmpIndentLeft;
			indentation.indentRight = tmpIndentRight;
			indentation.listIndentLeft = tmpListIndentLeft;
			indentation.imageIndentLeft = tmpImageIndentLeft;
			indentation.imageIndentRight = tmpImageIndentRight;
		}
		
		/**
		 * Draw the document headers
		 * @throws DocumentError
		 */
		protected function doHeader(): void
		{
			if (header == null) return;
			var tmpIndentLeft: Number = indentation.indentLeft;
			var tmpIndentRight: Number = indentation.indentRight;
			
			var tmpListIndentLeft: Number = indentation.listIndentLeft;
			var tmpImageIndentLeft: Number = indentation.imageIndentLeft;
			var tmpImageIndentRight: Number = indentation.imageIndentRight;
			indentation.indentLeft = indentation.indentRight = 0;
			indentation.listIndentLeft = 0;
			indentation.imageIndentLeft = 0;
			indentation.imageIndentRight = 0;
			header.pageNumber = pageN;
			
			var p: Paragraph = header.paragraph;
			leading = p.totalLeading;
			text.moveText( 0, leading );
			add( p );
			newLine();
			indentation.indentTop = currentHeight - leading;
			header.setTop(top() + leading);
			header.setBottom( indentTop + leading * 2 / 3);
			header.setLeft(left());
			header.setRight(right());
			graphics.rectangle(header);
			flushLines();
			currentHeight = 0;
			indentation.indentLeft = tmpIndentLeft;
			indentation.indentRight = tmpIndentRight;
			indentation.listIndentLeft = tmpListIndentLeft;
			indentation.imageIndentLeft = tmpImageIndentLeft;
			indentation.imageIndentRight = tmpImageIndentRight;
		}
		
		// -------------
		// Helper methods for the main method add
		// -------------
		
		
		// Element.ANCHOR
		private function _addAnchor( anchor: Anchor ): void
		{
			leadingCount++;
			var url: String = anchor.reference;
			leading = anchor.leading;
			if( url != null )
				anchorAction = PdfAction.fromURL( url );
			anchor.process( this );
			anchorAction = null;
			leadingCount--;
		}
		
		private function _addListItem( item: ListItem ): void
		{
			leadingCount++;
			addSpacing( item.spacingBefore, leading, item.font );
			
			alignment = item.alignment;
			indentation.listIndentLeft += item.indentationLeft;
			indentation.indentRight += item.indentationRight;
			leading = item.totalLeading;
			carriageReturn();
			
			line.listItem = item;
			item.process(this);
			
			addSpacing( item.spacingAfter, item.totalLeading, item.font );
			
			if( line.hasToBeJustified )
				line.resetAlignment();
			
			
			carriageReturn();
			indentation.listIndentLeft -= item.indentationLeft;
			indentation.indentRight -= item.indentationRight;
			leadingCount--;
		}
		
		private function _addList( list: List ): void
		{
			if( list.alignindent )
				list.normalizeIndentation();
			
			indentation.listIndentLeft += list.indentationLeft;
			indentation.indentRight += list.indentationRight;
			list.process( this );
			indentation.listIndentLeft -= list.indentationLeft;
			indentation.indentRight -= list.indentationRight;
			carriageReturn();
		}
		
		private function _addSection( section: Section ): void
		{
			var hasTitle: Boolean = section.notAddedYet && section.title != null;
			
			if( section.triggerNewPage )
				newPage();
			
			if( hasTitle )
			{
				var fith: Number = indentTop - currentHeight;
				var rotation: int = pageSize.rotation;
				if( rotation == 90 || rotation == 180 )
					fith = pageSize.height - fith;
				
				var destination: PdfDestination = PdfDestination.create( PdfDestination.FITH, fith );
				while( currentOutline.level >= section.depth )
					currentOutline = currentOutline.parent;
				
				var outline: PdfOutline = PdfOutline.create( currentOutline, destination, section.getBookmarkTitle(), section.bookmarkOpen );
				currentOutline = outline;
			}
			
			carriageReturn();
			indentation.sectionIndentLeft += section.indentationLeft;
			indentation.sectionIndentRight += section.indentationRight;
			
			if( section.notAddedYet )
				if( section.type == Element.CHAPTER )
					dispatchEvent( new ChapterEvent( ChapterEvent.CHAPTER_START, indentTop - currentHeight, section.title ) );
				else
					dispatchEvent( new SectionEvent( SectionEvent.SECTION_START, indentTop - currentHeight, section.depth, section.title ) );
			
			if( hasTitle )
			{
				isSectionTitle = true;
				addElement( section.title );
				isSectionTitle = false;
			}
			
			indentation.sectionIndentLeft += section.indentation;
			section.process( this );
			flushLines();
			
			
			indentation.sectionIndentLeft -= (section.indentationLeft + section.indentation);
			indentation.sectionIndentRight -= section.indentationRight;
			
			if( section.complete )
				if( section.type == Element.CHAPTER )
					dispatchEvent( new ChapterEvent( ChapterEvent.CHAPTER_END, indentTop - currentHeight, null ) );
				else
					dispatchEvent( new SectionEvent( SectionEvent.SECTION_END, indentTop - currentHeight, section.depth, null ) );
		}
		
		
		
		/** 
		 * Adds a PdfPTable to the document
		 * @throws DocumentError
		 */
		private function _addPTable( ptable: PdfPTable ): void
		{
			var ct: ColumnText = new ColumnText( _writer.getDirectContent() );

			if( ptable.keepTogether && !_fitsPage( ptable, 0 ) && currentHeight > 0)
				newPage();

			if (currentHeight > 0) {
				var p: Paragraph = new Paragraph(null);
				p.leading = 0;
				ct.addElement( p );
			}
			
			ct.addElement(ptable);
			var he: Boolean = ptable.headersInEvent;
			ptable.headersInEvent = true;
			var loop: int = 0;
			while (true) 
			{
				ct.setSimpleColumn( indentLeft, indentBottom, indentRight, indentTop - currentHeight );
				var status: int = ct.go();
				if( (status & ColumnText.NO_MORE_TEXT) != 0 )
				{
					text.moveText(0, ct.yLine - indentTop + currentHeight);
					currentHeight = indentTop - ct.yLine;
					break;
				}
				if (indentTop - currentHeight == ct.yLine)
					++loop;
				else
					loop = 0;
				if (loop == 3) {
					add( new Paragraph("ERROR: Infinite table loop") );
					break;
				}
				newPage();
			}
			ptable.headersInEvent = he;
		}

		/**
		 * Checks if a PdfPTable fits the current page
		 */
		
		private function _fitsPage( table: PdfPTable, margin: Number ): Boolean
		{
			if (!table.lockedWidth) {
				var totalWidth: Number = (indentRight - indentLeft) * table.widthPercentage / 100;
				table.totalWidth = totalWidth;
			}
			// ensuring that a new line has been started.
			ensureNewLine();
			return table.totalHeight + ((currentHeight > 0) ? table.spacingBefore : 0) <= indentTop - currentHeight - indentBottom - margin;
		}
	}
}
