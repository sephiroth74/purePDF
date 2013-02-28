package test_reader
{
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.purepdf.pdf.PdfReader;
	
	public class SimpleReader extends Sprite
	{
		protected var file: String;
		protected var pdf: ByteArray;
		protected var reader: PdfReader;
		
		public function SimpleReader( file: String )
		{
			super();
			
			this.file = file;
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		protected function onAdded( event: Event ): void
		{
			var loader: URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, onComplete);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load( new URLRequest( this.file ) );
		}
		
		protected function onComplete( event: Event ): void
		{
			pdf = URLLoader( event.target ).data as ByteArray;
			reader = new PdfReader( pdf );
			reader.addEventListener( Event.COMPLETE, onReadComplete );
			reader.addEventListener( ProgressEvent.PROGRESS, onReadProgress );
			reader.addEventListener( ErrorEvent.ERROR, onReadError );
			reader.readPdf();
		}
		
		protected function onReadError( event: ErrorEvent ): void
		{
			trace(event);
		}
		
		protected function onReadProgress( event: ProgressEvent ): void
		{
			trace( reader.currentStep + " of " + reader.totalSteps, int((event.bytesLoaded/event.bytesTotal)*100) )
		}
		
		protected function onReadComplete( event: Event ): void
		{
			trace('complete');
		}
	}
}