package
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.Font;
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.elements.Anchor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.IElement;
	import org.purepdf.elements.ITextElementaryArray;
	import org.purepdf.elements.List;
	import org.purepdf.elements.ListItem;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.utils.StringUtils;

	public class FlyerExample extends DefaultBasicExample
	{
		[Embed(source="assets/foobar.xml", mimeType="application/octet-stream")]
		private var cls: Class;
		
		protected var FONTSIZES: Vector.<int> = Vector.<int>([ 24, 18, 16, 14, 12, 10 ]);
		protected var H: Vector.<String> = Vector.<String>([ "h1", "h2", "h3", "h4", "h5", "h6" ]);
		protected var currentChunk: Chunk;
		protected var stack: Vector.<IElement>;
		
		public function FlyerExample()
		{
			super(["Read from an html document and print the resulting pdf"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			var b: ByteArray = new cls() as ByteArray;
			b.position = 0;
			var xml: XML = new XML( b.readUTFBytes( b.length ) );
			stack = new Vector.<IElement>();
			
			
			createDocument();
			
			parse( xml );
			
			save();
		}
		
		private function parse( x: XML ): void
		{
			var children: XMLList = x.children();
			for( var a: int = 0; a < children.length(); ++a )
			{
				startElement( children[a] );
				endElement( children[a] );
			}
		}
		
		public function characters( content: String ): void
		{
			if( content == null || content.length == 0 )
				return;
			
			if( currentChunk == null )
			{
				currentChunk = new Chunk( StringUtils.trim( content ) );
			} else 
			{
				currentChunk.append(" ");
				currentChunk.append( StringUtils.trim( content ) );
			}
		}
		
		private function updateStack(): void
		{
			if( currentChunk != null )
			{
				var current: ITextElementaryArray;
				try 
				{
					current = ITextElementaryArray( stack.pop() );
					if( !(current is Paragraph ) || !Paragraph(current).isEmpty )
						current.add(new Chunk(" "));
				} catch( e: Error )
				{
					current = new Paragraph( null );
				}
				
				current.add( currentChunk );
				stack.push( current );
				currentChunk = null;
			}
		}
		
		private function flushStack(): void
		{
			try
			{
				while( stack.length > 0 )
				{
					var element: IElement = stack.pop();
					try 
					{
						var previous: ITextElementaryArray = ITextElementaryArray( stack.pop() );
						previous.add( element );
						stack.push( previous );
					} catch ( e: TypeError )
					{
						document.add( element );
					}
				}
			} catch( e: Error )
			{
				trace("ERROR: " + e.getStackTrace() );
			}
		}
		
		private function startElement( element: XML ): void
		{
			trace('start', element.name() );
			
			var qname: String = element.name().toString().toLowerCase();
			var p: Paragraph;
			
			try
			{
				if( document.opened )
				{
					updateStack();
					for( var i: int = 0; i < H.length; i++ )
					{
						if( H[i] == qname )
						{
							flushStack();
							p = new Paragraph( "", new Font( Font.HELVETICA, FONTSIZES[i], Font.UNDEFINED, new CMYKColor(0.9, 0.7, 0.4, 0.1)));
							p.leading = Number.NaN;
							stack.push( p );
							break;
						}
					}
					
					if( "blockquote" == qname )
					{
						flushStack();
						p = new Paragraph( null );
						p.indentationLeft = 50;
						p.indentationRight = 20;
						stack.push(p);
					} else if( "a" == qname )
					{
						var anchor: Anchor = new Anchor("", new Font(Font.HELVETICA, Font.UNDEFINED, Font.UNDEFINED, new CMYKColor(0.9, 0.7, 0.4, 0.1)));
						anchor.reference = element.attribute("href");
						stack.push( anchor );
					} else if( "ol" == qname )
						stack.push( new List( List.ORDERED, 10 ) );
					else if( "ul" == qname )
						stack.push( new List( List.UNORDERED, 10 ) );
					else if( "li" == qname )
						stack.push( new ListItem(null) );
				} else if( "body" == qname )
					document.open();
			} catch( e: Error )
			{
				trace("ERROR: " + e.getStackTrace() );
				return;
			}
			
			var text: String = element.text();
			
			characters( text );
			
			var children: XMLList = element.children();
			for( var a: int = 0; a < children.length(); ++a )
			{
				if( XML(children[a]).name() )
				{
					startElement( children[a] );
					endElement( children[a] );
				}
			}
		}
		
		public function endElement( element: XML ): void
		{
			var qname: String = element.name().toString().toLowerCase();
			try 
			{
				if( document.opened ) 
				{
					updateStack();
					for( var i: int = 0; i < H.length; i++ )
					{
						if( H[i] == qname )
						{
							flushStack();
							return;
						}
					}
					
					if( "blockquote" == qname || "ol" == qname || "ul" == qname )
					{
						flushStack();
					} else if( "p" == qname )
					{
						//currentChunk = Chunk.NEWLINE;
						updateStack();
					} else if( "li" ==  qname )
					{
						var listItem: ListItem = stack.pop() as ListItem;
						var list: List = stack.pop() as List;
						list.add( listItem );
						stack.push( list );
					} else if( "a" == qname )
					{
						var anchor: Anchor = stack.pop() as Anchor;
						try 
						{
							var previous: ITextElementaryArray = stack.pop() as ITextElementaryArray;
							previous.add( anchor );
							stack.push( previous );
						} catch ( e: RangeError )
						{
							document.add( anchor );
						}
					} else if( "body" == qname )
					{
						flushStack();
						document.close();
					}
				} else 
				{
					if( "title" == qname )
					{
						document.addTitle( currentChunk.content );
					}
					currentChunk = null;
				}
			} catch (e: Error ) {
				trace("ERROR: " + e.getStackTrace() );
			}
		}
	}
}