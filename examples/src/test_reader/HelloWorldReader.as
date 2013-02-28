package test_reader
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.collections.iterators.Iterator;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfReader;
	import org.purepdf.pdf.SimpleBookmark;

	public class HelloWorldReader extends SimpleReader
	{
		public function HelloWorldReader()
		{
			super( "../output/HelloWorldBookmark.pdf" );
		}

		protected override function onReadComplete( event: Event ): void
		{
			super.onReadComplete( event );
			var k: int;
			trace( "=== Document Information ===" );
			trace( "PDF Version: " + reader.pdfVersion );
			trace( "Number of pages: " + reader.getNumberOfPages());
			trace( "File lengeth: " + reader.getFileLength());
			trace( "Encrypted? " + reader.isEncrypted());
			trace( "Rebuilt? " + reader.isRebuilt());
			trace( "=== Page Size ===" );

			for ( k = 0; k < reader.getNumberOfPages(); ++k )
			{
				trace( "Page " + k + " size: " + reader.getPageSize( k + 1 ) + "Rotation: " +
						reader.getPageRotation( k + 1 ));
			}
			trace( "=== bookmarks ===" );
			var list: Vector.<HashMap> = SimpleBookmark.getBookmark( reader );

			for ( k = 0; k < list.length; ++k )
			{
				showBookmark( list[k], 0 );
			}
			trace( "=== Document Info ===" );
			var map: HashMap = reader.getInfo();

			for ( var iterator: Iterator = map.keySet().iterator(); iterator.hasNext();  )
			{
				var key: String = iterator.next();
				trace( key + ": " + map.getValue( key ));
			}
			trace( "=== Document info (no loop) ===" );
			// In order to get the document metadata
			// informations without a loop
			trace( "Author: " + map.getValue( "Author" ));
			trace( "Creator: " + map.getValue( "Creator" ));
			trace( "Title: " + map.getValue( "Title" ));
		}

		protected static function showBookmark( bookmark: HashMap, indent: int ): void
		{
			var tab: String = "";
			var i: int;

			for ( i = 0; i < indent; i++ )
			{
				tab += "   ";
			}
			trace( tab + bookmark.getValue( "Title" ));
			var kids: Vector.<HashMap> = bookmark.getValue( "Kids" ) as Vector.<HashMap>;

			if ( kids == null )
				return;

			for ( i = 0; i < kids.length; ++i )
			{
				showBookmark( kids[i], indent + 1 );
			}
		}
	}
}