package
{
	import flash.display.JointStyle;
	import flash.events.Event;
	
	import org.purepdf.pdf.PdfContentByte;

	public class LineStyles extends DefaultBasicExample
	{
		public function LineStyles()
		{
			super(["This Example shows the various type of supported","line styles (joints, caps, dashes)"]);
		}

		override protected function execute( event: Event=null ): void
		{
			super.execute();

			createDocument( "Line styles example" );
			document.open();


			var cb: PdfContentByte = document.getDirectContent();
			cb.saveState();

			for ( var i: int = 25; i > 0; i-- )
			{
				cb.setLineWidth( Number( i ) / 10 );
				cb.moveTo( 40, 806 - ( 5 * i ) );
				cb.lineTo( 320, 806 - ( 5 * i ) );
				cb.stroke();
			}

			cb.restoreState();
			cb.moveTo( 72, 650 );
			cb.lineTo( 72, 600 );
			cb.moveTo( 144, 650 );
			cb.lineTo( 144, 600 );
			cb.stroke();
			cb.saveState();
			cb.setLineWidth( 8 );
			cb.setLineCap( PdfContentByte.LINE_CAP_BUTT );
			cb.moveTo( 72, 640 );
			cb.lineTo( 144, 640 );
			cb.stroke();
			cb.setLineCap( PdfContentByte.LINE_CAP_ROUND );
			cb.moveTo( 72, 625 );
			cb.lineTo( 144, 625 );
			cb.stroke();
			cb.setLineCap( PdfContentByte.LINE_CAP_PROJECTING_SQUARE );
			cb.moveTo( 72, 610 );
			cb.lineTo( 144, 610 );
			cb.stroke();
			cb.restoreState();
			cb.saveState();
			cb.setLineWidth( 8 );
			cb.setLineJoin( JointStyle.MITER );
			cb.moveTo( 200, 610 );
			cb.lineTo( 215, 640 );
			cb.lineTo( 230, 610 );
			cb.stroke();
			cb.setLineJoin( JointStyle.ROUND );
			cb.moveTo( 240, 610 );
			cb.lineTo( 255, 640 );
			cb.lineTo( 270, 610 );
			cb.stroke();
			cb.setLineJoin( JointStyle.BEVEL );
			cb.moveTo( 280, 610 );
			cb.lineTo( 295, 640 );
			cb.lineTo( 310, 610 );
			cb.stroke();
			cb.restoreState();

			cb.saveState();
			cb.setLineWidth( 8 );
			cb.setLineJoin( JointStyle.MITER );
			cb.setMiterLimit( 2 );
			cb.moveTo( 75, 560 );
			cb.lineTo( 95, 590 );
			cb.lineTo( 115, 560 );
			cb.stroke();
			cb.moveTo( 116, 560 );
			cb.lineTo( 135, 590 );
			cb.lineTo( 154, 560 );
			cb.stroke();
			cb.moveTo( 157, 560 );
			cb.lineTo( 175, 590 );
			cb.lineTo( 193, 560 );
			cb.stroke();
			cb.moveTo( 198, 560 );
			cb.lineTo( 215, 590 );
			cb.lineTo( 232, 560 );
			cb.stroke();
			cb.moveTo( 239, 560 );
			cb.lineTo( 255, 590 );
			cb.lineTo( 271, 560 );
			cb.stroke();
			cb.moveTo( 280, 560 );
			cb.lineTo( 295, 590 );
			cb.lineTo( 310, 560 );
			cb.stroke();
			cb.restoreState();
			cb.saveState();
			cb.setLineWidth( 8 );
			cb.setLineJoin( JointStyle.MITER );
			cb.setMiterLimit( 2.1 );
			cb.moveTo( 75, 500 );
			cb.lineTo( 95, 530 );
			cb.lineTo( 115, 500 );
			cb.stroke();
			cb.moveTo( 116, 500 );
			cb.lineTo( 135, 530 );
			cb.lineTo( 154, 500 );
			cb.stroke();
			cb.moveTo( 157, 500 );
			cb.lineTo( 175, 530 );
			cb.lineTo( 193, 500 );
			cb.stroke();
			cb.moveTo( 198, 500 );
			cb.lineTo( 215, 530 );
			cb.lineTo( 232, 500 );
			cb.stroke();
			cb.moveTo( 239, 500 );
			cb.lineTo( 255, 530 );
			cb.lineTo( 271, 500 );
			cb.stroke();
			cb.moveTo( 280, 500 );
			cb.lineTo( 295, 530 );
			cb.lineTo( 310, 500 );
			cb.stroke();
			cb.restoreState();

			cb.saveState();
			cb.setLineWidth( 3 );
			cb.moveTo( 40, 480 );
			cb.lineTo( 320, 480 );
			cb.stroke();
			cb.setLineDash2( 6, 0 );
			cb.moveTo( 40, 470 );
			cb.lineTo( 320, 470 );
			cb.stroke();
			cb.setLineDash2( 6, 3 );
			cb.moveTo( 40, 460 );
			cb.lineTo( 320, 460 );
			cb.stroke();
			cb.setLineDash3( 15, 10, 5 );
			cb.moveTo( 40, 450 );
			cb.lineTo( 320, 450 );
			cb.stroke();
			var dash1: Vector.<Number> = Vector.<Number>( [ 10, 5, 5, 5, 20 ] );
			cb.setLineDash4( dash1, 5 );
			cb.moveTo( 40, 440 );
			cb.lineTo( 320, 440 );
			cb.stroke();
			var dash2: Vector.<Number> = Vector.<Number>( [ 9, 6, 0, 6 ] );
			cb.setLineCap( PdfContentByte.LINE_CAP_ROUND );
			cb.setLineDash4( dash2, 0 );
			cb.moveTo( 40, 430 );
			cb.lineTo( 320, 430 );
			cb.stroke();
			cb.restoreState();

			document.close();
			save();
		}
	}
}