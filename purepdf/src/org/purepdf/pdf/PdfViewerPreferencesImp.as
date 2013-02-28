/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfViewerPreferencesImp.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfViewerPreferencesImp.as $
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
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.pdf.interfaces.IPdfViewerPreferences;

	public class PdfViewerPreferencesImp extends ObjectHash implements IPdfViewerPreferences
	{
		public static const DIRECTION_PREFERENCES: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.L2R, PdfName.R2L ] );
		public static const DUPLEX_PREFERENCES: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.SIMPLEX, PdfName.DUPLEXFLIPSHORTEDGE, PdfName.DUPLEXFLIPLONGEDGE ] );
		public static const NONFULLSCREENPAGEMODE_PREFERENCES: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.USENONE, PdfName.USEOUTLINES, PdfName.USETHUMBS, PdfName.USEOC ] );
		public static const PAGE_BOUNDARIES: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.MEDIABOX, PdfName.CROPBOX, PdfName.BLEEDBOX, PdfName.TRIMBOX, PdfName.ARTBOX ] );
		public static const PRINTSCALING_PREFERENCES: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.APPDEFAULT, PdfName.NONE ] );
		public static const VIEWER_PREFERENCES: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.HIDETOOLBAR, // 0
																					   PdfName.HIDEMENUBAR, // 1
																					   PdfName.HIDEWINDOWUI, // 2
																					   PdfName.FITWINDOW, // 3
																					   PdfName.CENTERWINDOW, // 4
																					   PdfName.DISPLAYDOCTITLE, // 5
																					   PdfName.NONFULLSCREENPAGEMODE, // 6
																					   PdfName.DIRECTION, // 7
																					   PdfName.VIEWAREA, // 8
																					   PdfName.VIEWCLIP, // 9
																					   PdfName.PRINTAREA, // 10
																					   PdfName.PRINTCLIP, // 11
																					   PdfName.PRINTSCALING, // 12
																					   PdfName.DUPLEX, // 13
																					   PdfName.PICKTRAYBYPDFSIZE, // 14
																					   PdfName.PRINTPAGERANGE, // 15
																					   PdfName.NUMCOPIES // 16
																					 ] );
		private static var viewerPreferencesMask: int = 0xfff000;
		private var pageLayoutAndMode: int = 0;
		private var viewerPreferences: PdfDictionary = new PdfDictionary();

		public function PdfViewerPreferencesImp()
		{
		}

		public function addToCatalog( catalog: PdfDictionary ): void
		{
			// Page Layout
			catalog.remove( PdfName.PAGELAYOUT );

			if ( ( pageLayoutAndMode & PdfViewPreferences.PageLayoutSinglePage ) != 0 )
				catalog.put( PdfName.PAGELAYOUT, PdfName.SINGLEPAGE );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageLayoutOneColumn ) != 0 )
				catalog.put( PdfName.PAGELAYOUT, PdfName.ONECOLUMN );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageLayoutTwoColumnLeft ) != 0 )
				catalog.put( PdfName.PAGELAYOUT, PdfName.TWOCOLUMNLEFT );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageLayoutTwoColumnRight ) != 0 )
				catalog.put( PdfName.PAGELAYOUT, PdfName.TWOCOLUMNRIGHT );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageLayoutTwoPageLeft ) != 0 )
				catalog.put( PdfName.PAGELAYOUT, PdfName.TWOPAGELEFT );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageLayoutTwoPageRight ) != 0 )
				catalog.put( PdfName.PAGELAYOUT, PdfName.TWOPAGERIGHT );
			// Page Mode
			catalog.remove( PdfName.PAGEMODE );

			if ( ( pageLayoutAndMode & PdfViewPreferences.PageModeUseNone ) != 0 )
				catalog.put( PdfName.PAGEMODE, PdfName.USENONE );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageModeUseOutlines ) != 0 )
				catalog.put( PdfName.PAGEMODE, PdfName.USEOUTLINES );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageModeUseThumbs ) != 0 )
				catalog.put( PdfName.PAGEMODE, PdfName.USETHUMBS );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageModeFullScreen ) != 0 )
				catalog.put( PdfName.PAGEMODE, PdfName.FULLSCREEN );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageModeUseOC ) != 0 )
				catalog.put( PdfName.PAGEMODE, PdfName.USEOC );
			else if ( ( pageLayoutAndMode & PdfViewPreferences.PageModeUseAttachments ) != 0 )
				catalog.put( PdfName.PAGEMODE, PdfName.USEATTACHMENTS );
			catalog.remove( PdfName.VIEWERPREFERENCES );

			if ( viewerPreferences.size > 0 )
			{
				catalog.put( PdfName.VIEWERPREFERENCES, viewerPreferences );
			}
		}

		public function addViewerPreference( key: PdfName, value: PdfObject ): void
		{
			switch ( getIndex( key ) )
			{
				case 0: // HIDETOOLBAR
				case 1: // HIDEMENUBAR
				case 2: // HIDEWINDOWUI
				case 3: // FITWINDOW
				case 4: // CENTERWINDOW
				case 5: // DISPLAYDOCTITLE
				case 14: // PICKTRAYBYPDFSIZE
					if ( value is PdfBoolean )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 6: // NONFULLSCREENPAGEMODE
					if ( value is PdfName && isPossibleValue( PdfName( value ), NONFULLSCREENPAGEMODE_PREFERENCES ) )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 7: // DIRECTION
					if ( value is PdfName && isPossibleValue( PdfName( value ), DIRECTION_PREFERENCES ) )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 8: // VIEWAREA
				case 9: // VIEWCLIP
				case 10: // PRINTAREA
				case 11: // PRINTCLIP
					if ( value is PdfName && isPossibleValue( PdfName( value ), PAGE_BOUNDARIES ) )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 12: // PRINTSCALING
					if ( value is PdfName && isPossibleValue( PdfName( value ), PRINTSCALING_PREFERENCES ) )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 13: // DUPLEX
					if ( value is PdfName && isPossibleValue( PdfName( value ), DUPLEX_PREFERENCES ) )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 15: // PRINTPAGERANGE
					if ( value is PdfArray )
					{
						viewerPreferences.put( key, value );
					}
					break;
				case 16: // NUMCOPIES
					if ( value is PdfNumber )
					{
						viewerPreferences.put( key, value );
					}
					break;
			}
		}

		public function getPageLayoutMode(): int
		{
			return pageLayoutAndMode;
		}

		public function getViewerPreferences(): PdfDictionary
		{
			return viewerPreferences;
		}

		public function setViewerPreferences( preferences: int ): void
		{
			pageLayoutAndMode |= preferences;

			if ( ( preferences & viewerPreferencesMask ) != 0 )
			{
				pageLayoutAndMode = ~viewerPreferencesMask & pageLayoutAndMode;

				if ( ( preferences & PdfViewPreferences.HideToolbar ) != 0 )
					viewerPreferences.put( PdfName.HIDETOOLBAR, PdfBoolean.PDF_TRUE );

				if ( ( preferences & PdfViewPreferences.HideMenubar ) != 0 )
					viewerPreferences.put( PdfName.HIDEMENUBAR, PdfBoolean.PDF_TRUE );

				if ( ( preferences & PdfViewPreferences.HideWindowUI ) != 0 )
					viewerPreferences.put( PdfName.HIDEWINDOWUI, PdfBoolean.PDF_TRUE );

				if ( ( preferences & PdfViewPreferences.FitWindow ) != 0 )
					viewerPreferences.put( PdfName.FITWINDOW, PdfBoolean.PDF_TRUE );

				if ( ( preferences & PdfViewPreferences.CenterWindow ) != 0 )
					viewerPreferences.put( PdfName.CENTERWINDOW, PdfBoolean.PDF_TRUE );

				if ( ( preferences & PdfViewPreferences.DisplayDocTitle ) != 0 )
					viewerPreferences.put( PdfName.DISPLAYDOCTITLE, PdfBoolean.PDF_TRUE );

				if ( ( preferences & PdfViewPreferences.NonFullScreenPageModeUseNone ) != 0 )
					viewerPreferences.put( PdfName.NONFULLSCREENPAGEMODE, PdfName.USENONE );
				else if ( ( preferences & PdfViewPreferences.NonFullScreenPageModeUseOutlines ) != 0 )
					viewerPreferences.put( PdfName.NONFULLSCREENPAGEMODE, PdfName.USEOUTLINES );
				else if ( ( preferences & PdfViewPreferences.NonFullScreenPageModeUseThumbs ) != 0 )
					viewerPreferences.put( PdfName.NONFULLSCREENPAGEMODE, PdfName.USETHUMBS );
				else if ( ( preferences & PdfViewPreferences.NonFullScreenPageModeUseOC ) != 0 )
					viewerPreferences.put( PdfName.NONFULLSCREENPAGEMODE, PdfName.USEOC );

				if ( ( preferences & PdfViewPreferences.DirectionL2R ) != 0 )
					viewerPreferences.put( PdfName.DIRECTION, PdfName.L2R );
				else if ( ( preferences & PdfViewPreferences.DirectionR2L ) != 0 )
					viewerPreferences.put( PdfName.DIRECTION, PdfName.R2L );

				if ( ( preferences & PdfViewPreferences.PrintScalingNone ) != 0 )
					viewerPreferences.put( PdfName.PRINTSCALING, PdfName.NONE );
			}
		}

		private function getIndex( key: PdfName ): int
		{
			for ( var i: int = 0; i < VIEWER_PREFERENCES.length; i++ )
			{
				if ( VIEWER_PREFERENCES[ i ].equals( key ) )
					return i;
			}
			return -1;
		}

		private function isPossibleValue( value: PdfName, accepted: Vector.<PdfName> ): Boolean
		{
			for ( var i: int = 0; i < accepted.length; i++ )
			{
				if ( accepted[ i ].equals( value ) )
				{
					return true;
				}
			}
			return false;
		}
	}
}