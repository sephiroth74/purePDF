package
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import flashx.textLayout.utils.CharacterUtil;
	
	import it.sephiroth.utils.Entry;
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.*;
	import org.purepdf.codecs.*;
	import org.purepdf.collections.PdfCrossReferenceCollection;
	import org.purepdf.collections.iterator.PdfCrossReferenceCollectionIterator;
	import org.purepdf.colors.*;
	import org.purepdf.elements.*;
	import org.purepdf.elements.images.*;
	import org.purepdf.errors.*;
	import org.purepdf.events.*;
	import org.purepdf.factories.*;
	import org.purepdf.html.*;
	import org.purepdf.io.*;
	import org.purepdf.io.zip.*;
	import org.purepdf.lang.*;
	import org.purepdf.pdf.*;
	import org.purepdf.pdf.barcode.*;
	import org.purepdf.pdf.barcode.pdf417.BarcodePDF417;
	import org.purepdf.pdf.codec.*;
	import org.purepdf.pdf.encoding.Cp437Conversion;
	import org.purepdf.pdf.encoding.ExtraEncoding;
	import org.purepdf.pdf.events.*;
	import org.purepdf.pdf.fonts.*;
	import org.purepdf.pdf.fonts.cmaps.*;
	import org.purepdf.pdf.forms.*;
	import org.purepdf.resources.*;
	import org.purepdf.utils.*;
	import org.purepdf.utils.collections.*;
	import org.purepdf.utils.iterators.*;

	public class Reflection extends DefaultBasicExample
	{
		private var chapterFont: Font;
		private var packageFont: Font;
		private var sectionFont: Font;
		private var titleFont: Font;
		private var defaultFont: Font;
		private var methodsFont: Font;
		private var methodsParamFont: Font;
		private var paramFont: Font;
		private var mainFont: Font;
		private var linkFont: Font;
		private var publicMethodsFont: Font;
		
		private var myriadpro_bold: BaseFont;
		private var minionpro_bold: BaseFont;
		private var minionpro_regular: BaseFont;
		private var myriadpro_regular: BaseFont;
		private var chapters: Vector.<Section> = new Vector.<Section>();
		
		private var queue: HashMap;
		private var processed: HashMap;
		private var timer: Timer;
		
		private var section_count: int = 0;
		private var newline: Chunk;
		
		[Embed(source="/Library/Fonts/MyriadPro-Semibold.otf", mimeType="application/octet-stream")] private var font1: Class;
		[Embed(source="/Library/Fonts/MyriadPro-Regular.otf", mimeType="application/octet-stream")] private var font3: Class;
		[Embed(source="/Library/Fonts/MinionPro-Regular.otf", mimeType="application/octet-stream")] private var font2: Class;
		[Embed(source="/Library/Fonts/MinionPro-Bold.otf", mimeType="application/octet-stream")] private var font4: Class;
		
		public function Reflection(d_list:Array=null)
		{
			super(d_list);
			registerDefaultFont();
			
			FontsResourceFactory.getInstance().registerFont( "MyriadPro-Semibold.otf", new font1() );
			FontsResourceFactory.getInstance().registerFont( "MinionPro-Regular.otf", new font2() );
			FontsResourceFactory.getInstance().registerFont( "MyriadPro-Regular.otf", new font3() );
			FontsResourceFactory.getInstance().registerFont( "MinionPro-Bold.otf", new font4() );
			
			minionpro_regular = BaseFont.createFont( "MinionPro-Regular.otf", BaseFont.WINANSI, false, true );
			minionpro_bold = 	BaseFont.createFont( "MinionPro-Bold.otf", BaseFont.WINANSI, false, true );
			myriadpro_regular = BaseFont.createFont( "MyriadPro-Regular.otf", BaseFont.WINANSI, false, true );
			myriadpro_bold = 	BaseFont.createFont( "MyriadPro-Semibold.otf", BaseFont.WINANSI, false, true );
			
			titleFont = new Font(-1, 34, -1, null, minionpro_bold );
			mainFont = new Font(-1, 32, -1, null, myriadpro_bold );
			chapterFont = new Font(-1, 24, -1, null, myriadpro_bold );
			packageFont = new Font(-1, 12, -1, RGBColor.DARK_GRAY, myriadpro_bold );
			sectionFont = new Font(-1, 14, -1, null, myriadpro_regular );
			
			linkFont = new Font( -1, 12, Font.UNDERLINE, RGBColor.BLUE, myriadpro_bold );
			defaultFont = new Font( -1, 10, -1, null, minionpro_regular );
			methodsFont = new Font( -1, 12, -1, null, minionpro_regular );
			methodsParamFont = new Font( -1, 10, -1, RGBColor.DARK_GRAY, minionpro_regular );
			paramFont = new Font( -1, 8, -1, RGBColor.GRAY, minionpro_regular );
			publicMethodsFont = new Font( -1, 11, -1, RGBColor.BLACK, minionpro_regular );
			
			newline = new Chunk("\n", defaultFont );
			
			queue = new HashMap( 200 );
			processed = new HashMap( 200 );
			
			timer = new Timer( 10, 0 );
			timer.addEventListener( TimerEvent.TIMER, onTimerComplete );
			
			push_class( 
				AlchemyUtils, ImageRaw, ImageTemplate, ImageWMF, Jpeg, Anchor, Annotation, ChapterAutoNumber,
				Chunk, Element, ElementTags, GreekList, HeaderFooter, List, ListItem, MarkedObject, MarkedSection,
				Meta, MultiColumnText, Paragraph, Phrase, ReadOnlyRectangle, RectangleElement, RomanList, PdfCrossReferenceCollectionIterator,
				SimpleCell, SimpleTable, TIFFEncoder, CMYKColor, ExtendedColor, GrayColor, PatternColor, RGBColor, ShadingColor, SpotColor, Element, 
				PdfViewPreferences, Font, IClonable, FontFactoryImp, IComparable, IFontProvider, IIterable, ISplitCharacter, RomanNumberFactory,
				PdfViewerPreferencesImp, ByteArrayUtils, Bytes, FloatUtils, IProperties, RomanAlphabetFactory, RomanDigit,
				PdfVersion, NumberUtils, Properties, StringTokenizer, StringUtils, Utilities, Markup, FontFactory, GreekAlphabetFactory,
				PdfTransparencyGroup, PdfCrossReferenceCollection, Barcode, BarcodeEAN, BarcodeEANSUPP, ByteArrayInputStream, DataInputStream, FilterInputStream,
				PdfTransition, VectorIterator, CJKFontResourceFactory, CMapResourceFactory, InputStream, LineReader, OutputStreamCounter,
				PdfTrailer, ICMap, CMap, BuiltinCJKFonts, BuiltinFonts, FieldBase, FieldText, PdfFormField, AssertPdfError, BadElementError,
				PdfTextArray, org.purepdf.pdf.GraphicState, GifImage, PngImage, TiffImage, InflaterInputStream, CastTypeError, ConversionError,
				PdfTemplate, PdfPCellEventForwarder, PdfPTableEventForwarder, ChapterEvent, ChunkEvent, PageEvent, ParagraphEvent, SectionEvent,
				PdfString, BaseFont, CJKFont, DocumentFont, FontsResourceFactory, GlyphList, StreamFont, DocumentError, IllegalPdfSyntaxError,
				PdfStream, TrueTypeFont, TrueTypeFontSubSet, TrueTypeFontUnicode, IllegalStateError, IndexOutOfBoundsError, NonImplementatioError,
				PdfSpotColor, PdfShading, PdfResources, PdfRectangle, SpecialSymbol, CharacterDataLatin1, Character, CharacterUtil,
				PdfReader, PdfPTable, PdfPRow, PdfPCell, PdfPatternPainter, PdfPattern, PdfPages, PdfPage, NullPointerError, RuntimeError,
				PdfOutline, PdfOCProperties, PdfObject, PdfNumber, PdfNull, PdfLiteral, PdfLine, PdfLayerMembership, UnsupportedOperationError,
				PdfLayer, PdfInfo, PdfIndirectObject, PdfImage, PdfGState, PdfFunction, PdfFormXObject, PdfFont, PdfEncryption,
				PdfEncodings, PdfDictionary, PdfDestination, PdfDashPattern, PdfCrossReference, PdfCopyFieldsImp, PdfContents,
				PdfContentByte, PdfColor, PdfChunk, PdfCatalog, PdfBorderArray, PdfBoolean, PdfBody, PdfBlendMode, PdfArray,
				PdfAppearance, PdfAnnotationsImp, PdfAnnotation, PdfAction, PdfAcroForm, PageSize, PageResources, BarcodePDF417,
				Indentation, FontSelector, DefaultSplitCharacter, ColumnText, ColorDetails, Cp437Conversion, ExtraEncoding,
				ByteBuffer, BidiOrder, BidiOrderTypes, BidiLine, ArabicLigaturizer, ImgCCITT, CCITTG4Encoder, TIFFFaxDecoder,
				PdfIndirectReference, PdfDocument, VerticalText, ShadingUtils, FieldText, MarkedSection, CMap, CMapResourceFactory, BuiltinCJKFonts, BuiltinFonts, FontsResourceFactory );
		}
		
		private function push_class( ...rest: Array ): void
		{
			for each( var c: Class in rest )
			{
				push_queue( getQualifiedClassName( c ) );
			}
		}
		
		private function push_queue( cname: String ): void
		{
			if( !processed.containsKey( cname ) && StringUtils.startsWith( cname, "org.purepdf." ) )
			{
				var def: Object;
				try
				{
					def = getDefinitionByName( cname );
				} catch( e: ReferenceError ){}
				
				if( def )
				{
					queue.put( cname, def );
				}
			}
		}
		
		private function onPageEnd( event: PageEvent ): void
		{
			var cb: PdfContentByte = document.getDirectContent();
			
			var w: Number = PageSize.A4.width;
			var h: Number = PageSize.A4.height;
			var margin_w: int = 18;
			var margin_h: int = 18;
			
			cb.setColorFill( new GrayColor( 0.93 ) );
			cb.moveTo( w - margin_w, margin_h );
			cb.lineTo( ( w - margin_w ) - 70, margin_h );
			cb.curveTo( (w - margin_w ) - 30, h/(3), (w - margin_w) - 30, h/(1.5), w - 70, (h - margin_h) );
			cb.lineTo( w - margin_w, h - margin_h );
			cb.fill();
			cb.resetFill();
		}		
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			createDocument();
			document.addEventListener( PageEvent.PAGE_START, onPageEnd );
		
			var f: Font = new Font( -1, 10, -1, new GrayColor(.7), minionpro_regular );
			var header: HeaderFooter = new HeaderFooter( new Phrase("http://code.google.com/p/purepdf  |  ", f ), null, true );
			header.alignment = Element.ALIGN_RIGHT;
			header.borderSides = RectangleElement.TOP;
			header.borderColor = new GrayColor(.7);
			header.borderWidth = .1
			document.setHeader( header );
			
			
			document.setMargins( 72, 72, 72, 72 );
			document.open();
			
			create_first_page();
			
			timer.start();
		}
		
		private function create_first_page(): void
		{
			var title: Paragraph = new Paragraph(null, defaultFont);
			title.add( new Paragraph("purePDF API (v." + PdfWriter.MAIN_VERSION + "." + PdfWriter.BUILD_NUMBER + ")\n", mainFont ));
			title.add( new Phrase("\n\nThis document has been generated automatically using purepdf (Version " + PdfWriter.RELEASE + ") with actionscript reflection methods\n\n", defaultFont ) );
			
			title.add( new Phrase("The contents of this file are subject to  LGPL license " +
				"(the \"GNU LIBRARY GENERAL PUBLIC LICENSE\"), in which case the " +
				"provisions of LGPL are applicable instead of those above.  If you wish to " +
				"allow use of your version of this file only under the terms of the LGPL " +
				"License and not to allow others to use your version of this file under " +
				"the MPL, indicate your decision by deleting the provisions above and " +
				"replace them with the notice and other provisions required by the LGPL. " +
				"If you do not delete the provisions above, a recipient may use your version " +
				"of this file under either the MPL or the GNU LIBRARY GENERAL PUBLIC LICENSE\n" +
				"Software distributed under the License is distributed on an \"AS IS\" basis, " +
				"WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License " +
				"for the specific language governing rights and limitations under the License.\n" +
				"The Original Code is 'iText, a free JAVA-PDF library' ( version 4.2 ) by Bruno Lowagie. " +
				"All the Actionscript ported code and all the modifications to the " +
				"original java library are written by Alessandro Crugnola (alessandro@sephiroth.it)\n" +
				"This library is free software; you can redistribute it and/or modify it " +
				"under the terms of the MPL as stated above or under the terms of the GNU " +
				"Library General Public License as published by the Free Software Foundation; " +
				"either version 2 of the License, or any later version.\n" +
				"This library is distributed in the hope that it will be useful, but WITHOUT " +
				"ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS " +
				"FOR A PARTICULAR PURPOSE. See the GNU LIBRARY GENERAL PUBLIC LICENSE for more " +
				"details\n" +
				"If you didn't download this code from the following link, you should check if " +
				"you aren't using an obsolete version: http://code.google.com/p/purepdf", defaultFont ) );
			
			document.add( title );
			
		}
		
		private function onTimerComplete( event: TimerEvent ): void
		{
			process_queue();
		}
		
		private function process_element( element: XML ): void
		{
			var real_name: String;
			var element_name: String = element.@name.toString();
			var node: XML;
			var k: int;
			var package_name: String = element_name.split("::").shift();
			var class_name: String = extractRealClassName( element_name );
			var name: String;
			var type: String;
			var list: List;
			var section: Section;
			var paragraph: Paragraph;
			var anchor: Anchor;
			var len: int;
			
			send_message( processed.size() + ". " + class_name );
			
			var chapterTitle: Paragraph = new Paragraph( " ", chapterFont );
			var chapterAnchor: Anchor = new Anchor( class_name, chapterFont );
			chapterAnchor.name = element_name;
			chapterTitle.add( chapterAnchor );
			
			var chapter: Chapter = new Chapter( chapterTitle, ++section_count );
			chapter.bookmarkTitle = class_name;
			chapter.bookmarkOpen = false;
			chapter.triggerNewPage = false;
			
			paragraph = new Paragraph("In package:\t", publicMethodsFont );
			paragraph.add( new Phrase( package_name + "\n", packageFont ) );
			
			// extends
			if( element.factory.extendsClass.length() > 0 )
			{
				var p0: Phrase = new Phrase("Extends:\t", publicMethodsFont );
				len = element.factory.extendsClass.length();
				for( k = 0; k < len; ++k )
				{
					node = element.factory.extendsClass[k];
					real_name = node.@type.toString();
					type = extractRealClassName( real_name );
					
					if( StringUtils.startsWith( real_name, "org.purepdf" ) )
					{
						anchor = new Anchor( type + (k+1 < len ? ", " : ""), packageFont );
						anchor.reference = "#" + real_name;
						p0.add( anchor );
					} else {
						p0.add( new Phrase( type + (k+1 < len ? ", " : ""), packageFont ) );
					}
					
					push_queue( node.@type.toString() );
					
				}
				p0.add("\n");
				paragraph.add( p0 );
			}
			
			// implements
			if( element.factory.implementsInterface.length() > 0 )
			{
				var p0: Phrase = new Phrase("Implemented interfaces:\t", publicMethodsFont );
				
				len = element.factory.implementsInterface.length();
				for( k = 0; k < element.factory.implementsInterface.length(); ++k )
				{
					node = element.factory.implementsInterface[k];
					type = extractRealClassName( node.@type.toString() );
					anchor = new Anchor( type + (k+1 < len ? ", " : ""), packageFont );
					anchor.reference = "#" + node.@type.toString();
					p0.add( anchor );
					push_queue( node.@type.toString() );
				}
				p0.add("\n");
				paragraph.add( p0 );
			}
			
			
			var link: Anchor = new Anchor( class_name + ".as", linkFont );
			link.reference = "http://purepdf.googlecode.com/svn/trunk/src/" + package_name.split(".").join("/") + "/" + class_name + ".as";
			var linkparagraph: Phrase = new Phrase("See online:\t", publicMethodsFont );
			paragraph.add( linkparagraph );
			paragraph.add( link );
			paragraph.add( "\n\n" );
			
			chapter.add( paragraph );
			
			// constants
			if( element.constant.length() > 0 )
			{
				section = chapter.addSection1( new Paragraph( " Public constants", sectionFont ) );
				section.indentation = 20;
				paragraph = new Paragraph(null, defaultFont );
				
				for( k = 0; k < element.constant.length(); ++k )
				{
					node = element.constant[k];
					real_name = node.@type.toString();
					type = extractRealClassName( real_name );
					name = node.@name.toString();
					
					
					var p: Phrase = new Phrase( "- ", defaultFont );
					p.add( new Phrase( name + ": ", defaultFont ) );
					
					if( StringUtils.startsWith( real_name, "org.purepdf" ) )
					{
						anchor = new Anchor( type + "\n", paramFont );
						anchor.reference = "#" + real_name;
						p.add( anchor );
					} else {
						p.add( new Phrase( type + "\n", paramFont ) );
					}
					
					paragraph.add( p );
				}
				
				paragraph.add("\n");
				section.add( paragraph );
			}
			
			// --------------
			// accessors
			// --------------
			if( element.factory.accessor.length() > 0 )
			{
				section = chapter.addSection1(new Paragraph(" Public properties", sectionFont) );
				section.indentation = 20;
				paragraph = new Paragraph( null, defaultFont );
				var accType: String;
				
				for( k = 0; k < element.factory.accessor.length(); ++k )
				{
					node = element.factory.accessor[k];
					real_name = node.@type.toString();
					type = extractRealClassName( real_name );
					name = node.@name.toString();
					accType = node.@access.toString();
					
					var phrase: Phrase = new Phrase( "- ", methodsFont );
					phrase.add( new Phrase( name, methodsFont ) );
					phrase.add( new Phrase( " [" + accType + "] ", paramFont ) );
					
					if( StringUtils.startsWith( real_name, "org.purepdf" ) )
					{
						anchor = new Anchor( type + "\n", defaultFont );
						anchor.reference = "#" + real_name;
						phrase.add( anchor );
					} else 
					{
						phrase.add( new Phrase( type + "\n", defaultFont ) );
					}
					
					paragraph.add( phrase );
				}
				
				paragraph.add("\n");
				section.add( paragraph );
			}
			
			// ctor
			if( element.factory.constructor.length() > 0 )
				process_methods("Constructor", element.factory.constructor, chapter, class_name );
			// public static methods
			process_methods("Static methods", element.method, chapter );
			// public methods
			process_methods("Public methods", element.factory.method, chapter );
			
			chapters.push( chapter );
			
			// check new files
			push_queue( element.@base.toString() );
		}
		
		private function process_methods( section_title: String, list: XMLList, chapter: Section, default_name: String = null ): Section
		{
			var section: Section;
			var paragraph: Paragraph;
			var k: int;
			var node: XML;
			var name: String;
			var len: int;
			var real_name: String;
			var anchor: Anchor;
			
			if( list.length() > 0 )
			{
				section = chapter.addSection1( new Paragraph( " " + section_title, sectionFont) );
				section.indentation = 20;
				paragraph = new Paragraph( null, defaultFont );
				
				var ctor_added: Boolean = false;
				for( k = 0; k < list.length(); ++k )
				{
					node = list[k];
					name = default_name ? default_name : node.@name.toString();
					
					var method: Phrase = process_method( name, node );
					
					paragraph.add( method );
					paragraph.add( newline );
				}
				
				section.add( paragraph );
				section.add( newline );
				section.add( newline );
			}
			return section;
		}
		
		private function process_method( name: String, node: XML ): Phrase
		{
			var method: Phrase = new Phrase( "- " + name, methodsFont );
			var method_subject_p: Phrase = new Phrase("(", methodsParamFont );
			var real_name: String;
			var len: int = node.parameter.length();
			var anchor: Anchor;
			
			if( len > 0 )
			{
				method_subject_p.add(" ");
				for( var j: int = 0; j < len; ++j )
				{
					var pnode: XML = node.parameter[j];
					push_queue( pnode.@type.toString() );
					
					real_name = pnode.@type.toString();
					
					if( StringUtils.startsWith( real_name, "org.purepdf" ) )
					{
						anchor = new Anchor( extractRealClassName( real_name ), methodsParamFont );
						anchor.reference = "#" + real_name;
						method_subject_p.add( anchor );
					} else 
					{
						method_subject_p.add( extractRealClassName( real_name ) );
					}
					
					if( j < node.parameter.length() - 1 )
					{
						method_subject_p.add(", ");
					}
				}
			}
			
			method_subject_p.add(") ");
			
			// return type
			if( node.@returnType )
			{
				real_name = node.@returnType.toString();
				
				if( StringUtils.startsWith( real_name, "org.purepdf" ) )
				{
					anchor = new Anchor( extractRealClassName( real_name ), methodsParamFont );
					anchor.reference = "#" + real_name;
					method_subject_p.add( anchor );
				} else 
				{
					method_subject_p.add( extractRealClassName( real_name ) );
				}
				
				push_queue( node.@returnType.toString() );
			}
			
			method.add( method_subject_p );
			return method;
		}
		
		private function extractRealClassName( s: String ): String
		{
			var index: int = s.indexOf("::");
			if( index > -1 )
				return s.substr( index + 2 );
			return s;
		}
		
		private function process_queue(): void
		{
			var iterator: Iterator;
			
			if( queue.size() > 0 )
			{
				iterator = queue.entrySet().iterator();
				var next: Entry = iterator.next() as Entry;
				
				queue.remove( next.key );
				processed.put( next.key, extractRealClassName( next.key.toString() ) );
				var x: XML = describeType( next.value );
				if( x )
				{
					process_element( x );
				}
			} else {
				timer.stop();
				post_complete();
			}
		}
		
		private function post_complete(): void
		{
			document.newPage();
			
			var tocChapter: Chapter = new Chapter( new Paragraph("Table of contents\n\n", mainFont ), 1 );
			tocChapter.bookmarkTitle = "Table of Contents";
			tocChapter.triggerNewPage = false;
			tocChapter.numberDepth = 0;
			
			
			var mct: MultiColumnText = new MultiColumnText();
			mct.addRegularColumns( document.left(), document.right(), 10, 3);
			
			var entries: Vector.<Object> = processed.entrySet().toArray( new Vector.<Object>( processed.size() ) );
			entries.sort( 
				function cmp( a: Entry, b: Entry ): Number{
					var _a: String = a.value.toString().toLowerCase();
					var _b: String = b.value.toString().toLowerCase();
					if( _a < _b ) return -1; 
					else return 1;  
				} );
			
			for( var k: int = 0; k < entries.length; ++k ) 
			{
				var e: Entry = entries[k] as Entry;
				var paragraph: Paragraph = new Paragraph( null, defaultFont );
				var anchor: Anchor = new Anchor( e.value.toString(), defaultFont );
				anchor.reference = "#" + e.key;
				paragraph.add( anchor );
				mct.addElement( paragraph );
			}
			
			//tocChapter.add( mct );
			document.add( tocChapter );
			document.add( mct );
			
			
			send_message("Generating TOC (" + processed.size() + ")...");

			var timer2: Timer = new Timer( 20, 0 );
			timer2.addEventListener( TimerEvent.TIMER, onTimer2Tick );
			timer2.start();
		}
		
		private function onTimer2Tick( event: TimerEvent ): void
		{
			var t1: Number = getTimer();
			while( getTimer() - t1 < 300 )
			{
				if( chapters.length > 0 )
				{
					send_message( chapters.length + " to go" );
					var chapter: Section = chapters.shift();
					document.add( chapter );
				} else 
				{
					send_message("completed. generating pdf...");
					Timer( event.target ).stop();
					complete();
					return;
				}
			}
		}
		
		private function complete(): void
		{
			document.close();
			
			create_button.removeEventListener( MouseEvent.CLICK, execute );
			create_button.addEventListener( MouseEvent.CLICK, save );
			//save();
		}
	}
}