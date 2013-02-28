/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfViewPreferences.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfViewPreferences.as $
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
	

	/**
	 * Contains the constants used for modify the pdf display
	 * preferences
	 * 
	 * @see org.purepdf.pdf.PdfDocument.setViewerPreferences()
	 */
	public class PdfViewPreferences extends ObjectHash
	{
		public static const PageLayoutSinglePage: int = 1;
		public static const PageLayoutOneColumn: int = 2;
		public static const PageLayoutTwoColumnLeft: int = 4;
		public static const PageLayoutTwoColumnRight: int = 8;
		public static const PageLayoutTwoPageLeft: int = 16;
		public static const PageLayoutTwoPageRight: int = 32;
		public static const PageModeUseNone: int = 64;
		public static const PageModeUseOutlines: int = 128;
		public static const PageModeUseThumbs: int = 256;
		public static const PageModeFullScreen: int = 512;
		public static const PageModeUseOC: int = 1024;
		public static const PageModeUseAttachments: int = 2048;
		
		public static const HideToolbar: int = 1 << 12;
		public static const HideMenubar: int = 1 << 13;
		public static const HideWindowUI: int = 1 << 14;
		public static const FitWindow: int = 1 << 15;
		public static const CenterWindow: int = 1 << 16;
		public static const DisplayDocTitle: int = 1 << 17;
		public static const NonFullScreenPageModeUseNone: int = 1 << 18;
		public static const NonFullScreenPageModeUseOutlines: int = 1 << 19;
		public static const NonFullScreenPageModeUseThumbs: int = 1 << 20;
		public static const NonFullScreenPageModeUseOC: int = 1 << 21;
		public static const DirectionL2R: int = 1 << 22;
		public static const DirectionR2L: int = 1 << 23;
		public static const PrintScalingNone: int = 1 << 24;
	}
}