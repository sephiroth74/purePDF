package
{
	import cmodule.as3_jpeg_wrapper.CLibInit;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.LigatureLevel;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.elements.TextFlow;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.utils.StringUtils;

	public class DefaultBasicExample extends Sprite
	{
		protected var description_container: Sprite;
		protected var create_button: Sprite;
		protected var document: PdfDocument;
		protected var writer: PdfWriter;
		protected var end_time: Number;
		protected var message_line: TextLine;
		protected var font: FontDescription;
		protected var msg_format: ElementFormat;
		protected var default_block: TextBlock;

		protected var start_time: Number;
		internal var buffer: ByteArray;
		internal var filename: String;
		internal var description_list: Array;

		public static var jpegLoader: CLibInit = new CLibInit();
		public static var jpegLib: Object = jpegLoader.init();

		public function DefaultBasicExample( d_list: Array = null )
		{
			super();
			description_list = d_list;
			filename = getQualifiedClassName( this ).split( "::" ).pop() + ".pdf";;
			addEventListener( Event.ADDED_TO_STAGE, added );
			
			font = new FontDescription();
			font.fontName = "Helvetica";
			
			msg_format = new ElementFormat();
			msg_format.fontDescription = font;
			msg_format.fontSize = 12;
			msg_format.color = 0x006600;
			
			default_block = new TextBlock();
		}

		public function executeAll(): Array
		{
			execute();
			return [filename, buffer];
		}
		
		protected function registerDefaultFont(): void
		{
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA() );
		}

		protected function addResultTime( time: Number ): void
		{
			var text: String = "";
			var seconds: int = time / 1000;
			var ms: int = ( time - ( seconds * 1000 ) ) / 10;

			text = "Total execution time: " + StringUtils.padLeft( seconds.toString(), '0', 2 ) + ":" + StringUtils.padLeft( ms.toString(), '0', 2 );
			send_message( text );
		}
		
		protected function send_message( msg: String ): void
		{
			clear_message();
			if( stage )
			{
				default_block.content = new TextElement( msg, msg_format );
				message_line = default_block.createTextLine();
				addChild( message_line );
				center( message_line, null, create_button );
			}
		}
		
		protected function clear_message(): void
		{
			if( message_line )
				message_line.parent.removeChild( message_line );
			message_line = null;
		}

		protected function added( event: Event ): void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			createchildren();
		}

		protected function center( obj: DisplayObject, below: DisplayObject=null, above: DisplayObject=null ): void
		{
			obj.x = ( stage.stageWidth - obj.width ) / 2;

			if ( below )
				obj.y = below.y + below.height + 5;
			else if( above )
				obj.y = above.y - obj.height - 5;
			else
				obj.y = ( stage.stageHeight - obj.height ) / 2;
		}

		protected function createButton( color: uint=0xDDDDDD, label: String="", callBack: Function=null ): Sprite
		{
			var s: Sprite = new Sprite();
			s.buttonMode = true;
			s.mouseChildren = false;

			var font: FontDescription = new FontDescription();
			font.fontName = "Arial";

			var elementFormat: ElementFormat = new ElementFormat();
			elementFormat.fontDescription = font;
			elementFormat.fontSize = 26;
			elementFormat.color = 0;
			elementFormat.ligatureLevel = LigatureLevel.COMMON;

			var tb: TextBlock = new TextBlock();
			tb.content = new TextElement( label, elementFormat );
			var tl: TextLine = tb.createTextLine();

			s.addEventListener( MouseEvent.CLICK, callBack );
			s.graphics.beginFill( color, 1 );
			s.graphics.drawRoundRect( 0, 0, tl.width + 20, tl.height + 10, 8, 8 );
			s.graphics.endFill();

			tl.x = 10;
			tl.y = s.height - 10;

			s.addChild( tl );
			return s;
		}

		internal function createDescription(): void
		{
			description( description_list );
		}

		protected function createDocument( subject: String=null, rect: RectangleElement=null ): void
		{
			buffer = new ByteArray();

			if ( rect == null )
				rect = PageSize.A4;

			writer = PdfWriter.create( buffer, rect );
			document = writer.pdfDocument;
			document.addAuthor( "Alessandro Crugnola (http://www.sephiroth.it)" );
			document.addTitle( getQualifiedClassName( this ) );
			document.addCreator( "http://code.google.com/p/purepdf" );
			if( subject ) 
				document.addSubject( subject );
			document.addKeywords( "itext,purepdf" );
			document.setViewerPreferences( PdfViewPreferences.FitWindow );
		}

		protected function create_default_button( title: String=null ): void
		{
			create_button = createButton( 0xDDDDDD, title ? title : "create", execute );
			center( create_button, null );
			addChild( create_button );
		}

		protected function createchildren(): void
		{
			// To be implemented
			description_container = new Sprite();
			addChild( description_container );
			
			create_default_button();
			createDescription();
		}

		protected function description( texts: Array ): void
		{
			while( description_container.numChildren > 0 )
				description_container.removeChildAt(0);
			
			var font: FontDescription = new FontDescription();
			font.fontName = "Arial";

			var elementFormat: ElementFormat = new ElementFormat();
			elementFormat.fontDescription = font;
			elementFormat.fontSize = 14;
			elementFormat.color = 0;
			elementFormat.ligatureLevel = LigatureLevel.COMMON;

			var textline: TextLine;

			for each ( var text: String in texts )
			{
				var tb: TextBlock = new TextBlock();
				tb.content = new TextElement( text, elementFormat );

				var tl: TextLine = tb.createTextLine();
				tl.x = ( stage.stageWidth - tl.width ) / 2;

				if ( textline )
					tl.y = textline.y + textline.height + 5;
				else
					tl.y = tl.height + 5;

				description_container.addChild( addChild( tl ) );

				textline = tl;
			}
		}

		protected function execute( event: Event=null ): void
		{
			start_time = new Date().getTime();
		}

		protected function save( e: *=null ): void
		{
			if ( !stage )
				return;
			end_time = new Date().getTime();
			addResultTime( end_time - start_time );

			var f: FileReference = new FileReference();
			f.save( buffer, filename );
		}
	}
}