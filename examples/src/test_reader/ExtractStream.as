package test_reader
{
	import flash.display.Sprite;
	import flash.events.Event;
	import org.purepdf.pdf.PRIndirectReference;
	import org.purepdf.pdf.PRStream;
	import org.purepdf.pdf.PRTokeniser;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfReader;
	import org.purepdf.utils.Bytes;

	public class ExtractStream extends SimpleReader
	{
		public function ExtractStream()
		{
			super( "../output/HelloWorld.pdf" );
		}

		override protected function onReadComplete( event: Event ): void
		{
			super.onReadComplete( event );

			var page: PdfDictionary = reader.getPageN( 1 );
			var objectReference: PRIndirectReference = PRIndirectReference( page.getValue( PdfName.CONTENTS ) );
			trace( "=== inspecting the stream of page 1 in object " + objectReference.number + " ===" );

			var stream: PRStream = PRStream( PdfReader.getPdfObject( objectReference ) );
			var streamBytes: Bytes = PdfReader.getStreamBytes2( stream );
			var contentStream: String = streamBytes.toString();
			trace( contentStream );

			// we can retrieve the String sections of the content stream
			trace( "=== extracting the strings from the stream ===" );
			var tokenizer: PRTokeniser = new PRTokeniser( streamBytes.buffer );
			while ( tokenizer.nextToken() )
			{
				if ( tokenizer.getTokenType() == PRTokeniser.TK_STRING )
				{
					trace( tokenizer.getStringValue() );
				}
			}
		}
	}
}