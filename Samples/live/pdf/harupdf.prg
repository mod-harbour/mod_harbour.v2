#include 'harupdf.ch'

STATIC aTtfFontList:= NIL
STATIC cFontDir


function Main()
    
   LOCAL pdf := HPDF_New()
   local cFile := hb_GetEnv( "PRGPATH" ) + "/data/test4.pdf"

   IF pdf == NIL
     ? 'Error'
      RETURN NIL
   ENDIF
   
   
   // Passwords and Permissions
   //
   /*
   HPDF_SetPassword( pdf, "owner", "user" )
   HPDF_SetPermission( pdf, HPDF_ENABLE_READ )  // cannot print
   HPDF_SetEncryptionMode( pdf, HPDF_ENCRYPT_R3, 16 )
   */ 

   Page_Lines( pdf )
   
   Page_Text( pdf )
   Page_TextScaling( pdf )
   
   Page_Images( pdf )
   
   Page_Annotation( pdf )
   
   Page_Graphics( pdf )   
   
   Page_CodePages( pdf )
   
   IF HPDF_SaveToFile( pdf, cFile ) != 0
      ? "0x" + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf )
   ENDIF

   HPDF_Free( pdf )   
   
   ?? "<" + "iframe src='./data/test4.pdf' style='width:calc( 100% + 16px );height:100%;border:0px;margin:-8px;'><" + ;
      "/iframe>"

return nil

//------------------------------------------------------------------------------

STATIC PROCEDURE Page_Graphics( pdf )

   LOCAL page, pos

   /* add a new page object. */
   page := HPDF_AddPage( pdf )

   HPDF_Page_SetHeight( page, 220 )
   HPDF_Page_SetWidth( page, 200 )

   /* draw grid to the page */
#if 0
   print_grid( pdf, page )
#endif

   /* draw pie chart
    *
    *   A: 45% Red
    *   B: 25% Blue
    *   C: 15% green
    *   D: other yellow
    */

   /* A */
   HPDF_Page_SetRGBFill( page, 1.0, 0, 0 )
   HPDF_Page_MoveTo( page, 100, 100 )
   HPDF_Page_LineTo( page, 100, 180 )
   HPDF_Page_Arc( page, 100, 100, 80, 0, 360 * 0.45 )
   pos := HPDF_Page_GetCurrentPos( page )
   HPDF_Page_LineTo( page, 100, 100 )
   HPDF_Page_Fill( page )

   /* B */
   HPDF_Page_SetRGBFill( page, 0, 0, 1.0 )
   HPDF_Page_MoveTo( page, 100, 100 )
   HPDF_Page_LineTo( page, pos[ 1 ], pos[ 2 ] )
   HPDF_Page_Arc( page, 100, 100, 80, 360 * 0.45, 360 * 0.7 )
   pos := HPDF_Page_GetCurrentPos( page )
   HPDF_Page_LineTo( page, 100, 100 )
   HPDF_Page_Fill( page )

   /* C */
   HPDF_Page_SetRGBFill( page, 0, 1.0, 0 )
   HPDF_Page_MoveTo( page, 100, 100 )
   HPDF_Page_LineTo( page, pos[ 1 ], pos[ 2 ] )
   HPDF_Page_Arc( page, 100, 100, 80, 360 * 0.7, 360 * 0.85 )
   pos := HPDF_Page_GetCurrentPos( page )
   HPDF_Page_LineTo( page, 100, 100 )
   HPDF_Page_Fill( page )

   /* D */
   HPDF_Page_SetRGBFill( page, 1.0, 1.0, 0 )
   HPDF_Page_MoveTo( page, 100, 100 )
   HPDF_Page_LineTo( page, pos[ 1 ], pos[ 2 ] )
   HPDF_Page_Arc( page, 100, 100, 80, 360 * 0.85, 360 )
#if 0
   pos := HPDF_Page_GetCurrentPos( page )
#endif
   HPDF_Page_LineTo( page, 100, 100 )
   HPDF_Page_Fill( page )

   /* draw center circle */
   HPDF_Page_SetGrayStroke( page, 0 )
   HPDF_Page_SetGrayFill( page, 1 )
   HPDF_Page_Circle( page, 100, 100, 30 )
   HPDF_Page_Fill( page )

   RETURN
   
   
#define PAGE_WIDTH   420
#define PAGE_HEIGHT  400
#define CELL_WIDTH   20
#define CELL_HEIGHT  20
#define CELL_HEADER  10

STATIC FUNCTION Page_CodePages( pdf )

   LOCAL page, outline, font2, font_name, root, i, font, dst
   LOCAL cResPath := hb_GetEnv( "PRGPATH" ) + "/files" + hb_ps()
   LOCAL cAfm := cResPath + "a010013l.afm"
   LOCAL cPfb := cResPath + "a010013l.pfb"
   LOCAL encodings := { ;
      "StandardEncoding", ;
      "MacRomanEncoding", ;
      "WinAnsiEncoding", ;
      "ISO8859-2",       ;
      "ISO8859-3",       ;
      "ISO8859-4",       ;
      "ISO8859-5",       ;
      "ISO8859-9",       ;
      "ISO8859-10",      ;
      "ISO8859-13",      ;
      "ISO8859-14",      ;
      "ISO8859-15",      ;
      "ISO8859-16",      ;
      "CP1250",          ;
      "CP1251",          ;
      "CP1252",          ;
      "CP1254",          ;
      "CP1257",          ;
      "KOI8-R",          ;
      "Symbol-Set",      ;
      "ZapfDingbats-Set" }

   /* Set page mode to use outlines. */
   HPDF_SetPageMode( pdf, HPDF_PAGE_MODE_USE_OUTLINE )

   /* get default font */
   font := HPDF_GetFont( pdf, "Helvetica", NIL )

   /* load font object */
   font_name := HPDF_LoadType1FontFromFile( pdf, cAfm, cPfb )

   /* create outline root. */
   root := HPDF_CreateOutline( pdf, NIL, "Encoding list", NIL )
   HPDF_Outline_SetOpened( root, .T. )

   FOR i := 1 TO Len( encodings )
      page := HPDF_AddPage( pdf )

      HPDF_Page_SetWidth( page, PAGE_WIDTH )
      HPDF_Page_SetHeight( page, PAGE_HEIGHT )

      outline := HPDF_CreateOutline( pdf, root, encodings[ i ], NIL )
      dst := HPDF_Page_CreateDestination( page )
      HPDF_Destination_SetXYZ( dst, 0, HPDF_Page_GetHeight( page ), 1 )

#if 0
      HPDF_Destination_SetFitB( dst )
#endif
      HPDF_Outline_SetDestination( outline, dst )

      HPDF_Page_SetFontAndSize( page, font, 15 )
      draw_graph( page )

      HPDF_Page_BeginText( page )
      HPDF_Page_SetFontAndSize( page, font, 20 )
      HPDF_Page_MoveTextPos( page, 40, PAGE_HEIGHT - 50 )
      HPDF_Page_ShowText( page, encodings[ i ] )
      HPDF_Page_ShowText( page, " Encoding" )
      HPDF_Page_EndText( page )

      IF encodings[ i ] == "Symbol-Set"
         font2 := HPDF_GetFont( pdf, "Symbol", NIL )
      ELSEIF encodings[ i ] == "ZapfDingbats-Set"
         font2 := HPDF_GetFont( pdf, "ZapfDingbats", NIL )
      ELSE
         font2 := HPDF_GetFont( pdf, font_name, encodings[ i ] )
      ENDIF

      HPDF_Page_SetFontAndSize( page, font2, 14 )
      draw_fonts( page )
   NEXT

   RETURN NIL

STATIC PROCEDURE draw_graph( page )

   LOCAL buf, i, x, y

   /* Draw 16 X 15 cells */

   /* Draw vertical lines. */
   HPDF_Page_SetLineWidth( page, 0.5 )

   FOR i := 0 TO 17
      x := i * CELL_WIDTH + 40

      HPDF_Page_MoveTo( page, x, PAGE_HEIGHT - 60 )
      HPDF_Page_LineTo( page, x, 40 )
      HPDF_Page_Stroke( page )

      IF i > 0 .AND. i <= 16
         HPDF_Page_BeginText( page )
         HPDF_Page_MoveTextPos( page, x + 5, PAGE_HEIGHT - 75 )
         buf := hb_NumToHex( i - 1 )
         HPDF_Page_ShowText( page, buf )
         HPDF_Page_EndText( page )
      ENDIF
   NEXT

   /* Draw horizontal lines. */
   FOR i := 0 TO 15
      y := i * CELL_HEIGHT + 40

      HPDF_Page_MoveTo( page, 40, y )
      HPDF_Page_LineTo( page, PAGE_WIDTH - 40, y )
      HPDF_Page_Stroke( page )

      IF i < 14
         HPDF_Page_BeginText( page )
         HPDF_Page_MoveTextPos( page, 45, y + 5 )
         buf := hb_NumToHex( 15 - i )
         HPDF_Page_ShowText( page, buf )
         HPDF_Page_EndText( page )
      ENDIF
   NEXT

   RETURN

STATIC PROCEDURE draw_fonts( page )

   LOCAL i, j, buf, x, y, d

   HPDF_Page_BeginText( page )

   /* Draw all character from 0x20 to 0xFF to the canvas. */
   FOR i := 1 TO 16
      FOR j := 1 TO 16
         y := PAGE_HEIGHT - 55 - ( ( i - 1 ) * CELL_HEIGHT )
         x := j * CELL_WIDTH + 50

         buf := ( i - 1 ) * 16 + ( j - 1 )
         IF buf >= 32
            d  := x - HPDF_Page_TextWidth( page, Chr( buf ) ) / 2
            HPDF_Page_TextOut( page, d, y, Chr( buf ) )
         ENDIF
      NEXT
   NEXT

   HPDF_Page_EndText( page )

   RETURN
   
STATIC PROCEDURE Page_Annotation( pdf )

   LOCAL rect1 := { 50, 350, 150, 400 }
   LOCAL rect2 := { 210, 350, 350, 400 }
   LOCAL rect3 := { 50, 250, 150, 300 }
   LOCAL rect4 := { 210, 250, 350, 300 }
   LOCAL rect5 := { 50, 150, 150, 200 }
   LOCAL rect6 := { 210, 150, 350, 200 }
   LOCAL rect7 := { 50, 50, 150, 100 }
   LOCAL rect8 := { 210, 50, 350, 100 }

   LOCAL page, font, encoding, annot

   /* use Times-Roman font. */
   font := HPDF_GetFont( pdf, "Times-Roman", "WinAnsiEncoding" )

   page := HPDF_AddPage( pdf )

   HPDF_Page_SetWidth( page, 400 )
   HPDF_Page_SetHeight( page, 500 )

   HPDF_Page_BeginText( page )
   HPDF_Page_SetFontAndSize( page, font, 16 )
   HPDF_Page_MoveTextPos( page, 130, 450 )
   HPDF_Page_ShowText( page, "Annotation Demo" )
   HPDF_Page_EndText( page )


   annot := HPDF_Page_CreateTextAnnot( page, rect1, ;
      "Annotation with Comment Icons" + hb_eol() + ;
      "This annotation set to be opened initially.", ;
      NIL )

   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_COMMENT )
   HPDF_TextAnnot_SetOpened( annot, HPDF_TRUE )

   annot := HPDF_Page_CreateTextAnnot( page, rect2, "Annotation with Key Icon", NIL )
   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_PARAGRAPH )

   annot := HPDF_Page_CreateTextAnnot( page, rect3, "Annotation with Note Icon", NIL )
   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_NOTE )

   annot := HPDF_Page_CreateTextAnnot( page, rect4, "Annotation with Help Icon", NIL )
   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_HELP )

   annot := HPDF_Page_CreateTextAnnot( page, rect5, "Annotation with NewParagraph Icon", NIL )
   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_NEW_PARAGRAPH )

   annot := HPDF_Page_CreateTextAnnot( page, rect6, "Annotation with Paragraph Icon", NIL )
   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_PARAGRAPH )

   annot := HPDF_Page_CreateTextAnnot( page, rect7, "Annotation with Insert Icon", NIL )
   HPDF_TextAnnot_SetIcon( annot, HPDF_ANNOT_ICON_INSERT )

   encoding := HPDF_GetEncoder( pdf, "ISO8859-2" )

   HPDF_Page_CreateTextAnnot( page, rect8, "Annotation with ISO8859 text " + hb_BChar( 211 ) + hb_BChar( 212 ) + hb_BChar( 213 ) + hb_BChar( 214 ) + hb_BChar( 215 ) + hb_BChar( 216 ) + hb_BChar( 217 ), encoding )

   HPDF_Page_SetFontAndSize( page, font, 11 )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect1[ 1 ] + 35, rect1[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Comment Icon." )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect2[ 1 ] + 35, rect2[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Key Icon" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect3[ 1 ] + 35, rect3[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Note Icon." )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect4[ 1 ] + 35, rect4[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Help Icon" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect5[ 1 ] + 35, rect5[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "NewParagraph Icon" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect6[ 1 ] + 35, rect6[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Paragraph Icon" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect7[ 1 ] + 35, rect7[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Insert Icon" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, rect8[ 1 ] + 35, rect8[ 2 ] - 20 )
   HPDF_Page_ShowText( page, "Text Icon(ISO8859-2 text)" )
   HPDF_Page_EndText( page )

   RETURN

   
STATIC PROCEDURE Page_TextScaling( pdf )

   LOCAL font, page, tw, angle1, angle2, buf, len, fsize, i, r, b, g, yPos, rad1, rad2
   LOCAL samp_text  := "abcdefgABCDEFG123!#$%&+-@?"
   LOCAL samp_text2 := "The quick brown fox jumps over the lazy dog."
   LOCAL page_title := "Text Demo"

   /* set compression mode */
#if 0
   HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL )
#endif

   /* create default-font */
   font := HPDF_GetFont( pdf, "Helvetica", NIL )

   /* add a new page object. */
   page := HPDF_AddPage( pdf )

   /* draw grid to the page */
#if 0
   print_grid( pdf, page )
#endif

   /* print the lines of the page */
#if 0
   HPDF_Page_SetLineWidth( page, 1 )
   HPDF_Page_Rectangle( page, 50, 50, HPDF_Page_GetWidth( page ) - 100, ;
      HPDF_Page_GetHeight( page ) - 110 )
   HPDF_Page_Stroke( page )
#endif

   /* print the title of the page(with positioning center). */
   HPDF_Page_SetFontAndSize( page, font, 24 )
   tw := HPDF_Page_TextWidth( page, page_title )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, ( HPDF_Page_GetWidth( page ) - tw ) / 2, ;
      HPDF_Page_GetHeight( page ) - 50, page_title )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 60, HPDF_Page_GetHeight( page ) - 60 )

   /* font size */
   fsize := 8
   DO WHILE fsize < 60
      /* set style and size of font. */
      HPDF_Page_SetFontAndSize( page, font, fsize )

      /* set the position of the text. */
      HPDF_Page_MoveTextPos( page, 0, -5 - fsize )

      /* measure the number of characters which included in the page. */
      buf := samp_text
      HPDF_Page_MeasureText( page, samp_text, ;
         HPDF_Page_GetWidth( page ) - 120, .F., NIL )

      HPDF_Page_ShowText( page, buf )

      /* print the description. */
      HPDF_Page_MoveTextPos( page, 0, -10 )
      HPDF_Page_SetFontAndSize( page, font, 8 )
      buf := "Fontsize=" + hb_ntos( fsize )

      HPDF_Page_ShowText( page, buf )

      fsize *= 1.5
   ENDDO

   /* font color */
   HPDF_Page_SetFontAndSize( page, font, 8 )
   HPDF_Page_MoveTextPos( page, 0, -30 )
   HPDF_Page_ShowText( page, "Font color" )

   HPDF_Page_SetFontAndSize( page, font, 18 )
   HPDF_Page_MoveTextPos( page, 0, -20 )
   len := Len( samp_text )
   FOR i := 1 TO len
      r := i / len
      g := 1 - ( i / len )
      buf := SubStr( samp_text, i, 1 )

      HPDF_Page_SetRGBFill( page, r, g, 0.0 )
      HPDF_Page_ShowText( page, buf )
   NEXT
   HPDF_Page_MoveTextPos( page, 0, -25 )

   FOR i := 1 TO len
      r := i / len
      b := 1 - ( i / len )
      buf := SubStr( samp_text, i, 1 )

      HPDF_Page_SetRGBFill( page, r, 0.0, b )
      HPDF_Page_ShowText( page, buf )
   NEXT
   HPDF_Page_MoveTextPos( page, 0, -25 )

   FOR i := 1 TO len
      b := i / len
      g := 1 - ( i / len )
      buf := SubStr( samp_text, i, 1 )

      HPDF_Page_SetRGBFill( page, 0.0, g, b )
      HPDF_Page_ShowText( page, buf )
   NEXT

   HPDF_Page_EndText( page )

   ypos := 450

   /* Font rendering mode */
   HPDF_Page_SetFontAndSize( page, font, 32 )
   HPDF_Page_SetRGBFill( page, 0.5, 0.5, 0.0 )
   HPDF_Page_SetLineWidth( page, 1.5 )

   /* PDF_FILL */
   show_description( page,  60, ypos, "RenderingMode=PDF_FILL" )
   HPDF_Page_SetTextRenderingMode( page, HPDF_FILL )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, ypos, "ABCabc123" )
   HPDF_Page_EndText( page )

   /* PDF_STROKE */
   show_description( page, 60, ypos - 50, "RenderingMode=PDF_STROKE" )
   HPDF_Page_SetTextRenderingMode( page, HPDF_STROKE )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, ypos - 50, "ABCabc123" )
   HPDF_Page_EndText( page )

   /* PDF_FILL_THEN_STROKE */
   show_description( page, 60, ypos - 100, "RenderingMode=PDF_FILL_THEN_STROKE" )
   HPDF_Page_SetTextRenderingMode( page, HPDF_FILL_THEN_STROKE )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, ypos - 100, "ABCabc123" )
   HPDF_Page_EndText( page )

   /* PDF_FILL_CLIPPING */
   show_description( page, 60, ypos - 150, "RenderingMode=PDF_FILL_CLIPPING" )
   HPDF_Page_GSave( page )
   HPDF_Page_SetTextRenderingMode( page, HPDF_FILL_CLIPPING )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, ypos - 150, "ABCabc123" )
   HPDF_Page_EndText( page )
   show_stripe_pattern( page, 60, ypos - 150 )
   HPDF_Page_GRestore( page )

   /* PDF_STROKE_CLIPPING */
   show_description( page, 60, ypos - 200, "RenderingMode=PDF_STROKE_CLIPPING" )
   HPDF_Page_GSave( page )
   HPDF_Page_SetTextRenderingMode( page, HPDF_STROKE_CLIPPING )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, ypos - 200, "ABCabc123" )
   HPDF_Page_EndText( page )
   show_stripe_pattern( page, 60, ypos - 200 )
   HPDF_Page_GRestore( page )

   /* PDF_FILL_STROKE_CLIPPING */
   show_description( page, 60, ypos - 250, "RenderingMode=PDF_FILL_STROKE_CLIPPING" )
   HPDF_Page_GSave( page )
   HPDF_Page_SetTextRenderingMode( page, HPDF_FILL_STROKE_CLIPPING )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, ypos - 250, "ABCabc123" )
   HPDF_Page_EndText( page )
   show_stripe_pattern( page, 60, ypos - 250 )
   HPDF_Page_GRestore( page )

   /* Reset text attributes */
   HPDF_Page_SetTextRenderingMode( page, HPDF_FILL )
   HPDF_Page_SetRGBFill( page, 0, 0, 0 )
   HPDF_Page_SetFontAndSize( page, font, 30 )

   /* Rotating text */
   angle1 := 30                   /* A rotation of 30 degrees. */
   rad1 := angle1 / 180 * 3.141592 /* Calcurate the radian value. */

   show_description( page, 320, ypos - 60, "Rotating text" )
   HPDF_Page_BeginText( page )
   HPDF_Page_SetTextMatrix( page, Cos( rad1 ), Sin( rad1 ), -Sin( rad1 ), Cos( rad1 ), 330, ypos - 60 )
   HPDF_Page_ShowText( page, "ABCabc123" )
   HPDF_Page_EndText( page )

   /* Skewing text. */
   show_description( page, 320, ypos - 120, "Skewing text" )
   HPDF_Page_BeginText( page )

   angle1 := 10
   angle2 := 20
   rad1 := angle1 / 180 * 3.141592
   rad2 := angle2 / 180 * 3.141592

   HPDF_Page_SetTextMatrix( page, 1, Tan( rad1 ), Tan( rad2 ), 1, 320, ypos - 120 )
   HPDF_Page_ShowText( page, "ABCabc123" )
   HPDF_Page_EndText( page )

   /* scaling text(X direction) */
   show_description( page, 320, ypos - 175, "Scaling text(X direction)" )
   HPDF_Page_BeginText( page )
   HPDF_Page_SetTextMatrix( page, 1.5, 0, 0, 1, 320, ypos - 175 )
   HPDF_Page_ShowText( page, "ABCabc12" )
   HPDF_Page_EndText( page )

   /* scaling text(Y direction) */
   show_description( page, 320, ypos - 250, "Scaling text(Y direction)" )
   HPDF_Page_BeginText( page )
   HPDF_Page_SetTextMatrix( page, 1, 0, 0, 2, 320, ypos - 250 )
   HPDF_Page_ShowText( page, "ABCabc123" )
   HPDF_Page_EndText( page )

   /* char spacing, word spacing */
   show_description( page, 60, 140, "char-spacing 0" )
   show_description( page, 60, 100, "char-spacing 1.5" )
   show_description( page, 60, 60, "char-spacing 1.5, word-spacing 2.5" )

   HPDF_Page_SetFontAndSize( page, font, 20 )
   HPDF_Page_SetRGBFill( page, 0.1, 0.3, 0.1 )

   /* char-spacing 0 */
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, 140, samp_text2 )
   HPDF_Page_EndText( page )

   /* char-spacing 1.5 */
   HPDF_Page_SetCharSpace( page, 1.5 )

   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, 100, samp_text2 )
   HPDF_Page_EndText( page )

   /* char-spacing 1.5, word-spacing 3.5 */
   HPDF_Page_SetWordSpace( page, 2.5 )

   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, 60, 60, samp_text2 )
   HPDF_Page_EndText( page )

#if 0
   HPDF_SetCompressionMode( pdf, nComp )
#endif

   RETURN
   

STATIC PROCEDURE show_stripe_pattern( page, x, y )
   LOCAL iy


   FOR iy := 0 TO 50 STEP 3
      HPDF_Page_SetRGBStroke( page, 0.0, 0.0, 0.5 )
      HPDF_Page_SetLineWidth( page, 1 )
      HPDF_Page_MoveTo( page, x, y + iy )
      HPDF_Page_LineTo( page, x + HPDF_Page_TextWidth( page, "ABCabc123" ), y + iy )
      HPDF_Page_Stroke( page )
   NEXT

   HPDF_Page_SetLineWidth( page, 2.5 )

   RETURN   

STATIC PROCEDURE show_description( page, x, y, text )

   LOCAL fsize := HPDF_Page_GetCurrentFontSize( page )
   LOCAL font  := HPDF_Page_GetCurrentFont( page )
   LOCAL c     := HPDF_Page_GetRGBFill( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_SetRGBFill( page, 0, 0, 0 )
   HPDF_Page_SetTextRenderingMode( page, HPDF_FILL )
   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, x, y - 12, text )
   HPDF_Page_EndText( page )

   HPDF_Page_SetFontAndSize( page, font, fsize )
   HPDF_Page_SetRGBFill( page, c[ 1 ], c[ 2 ], c[ 3 ] )

   RETURN


function  Page_Lines( pdf )

   LOCAL page_title := "Line Example"
   LOCAL font, page

   LOCAL DASH_MODE1 := { 3 }
   LOCAL DASH_MODE2 := { 3, 7 }
   LOCAL DASH_MODE3 := { 8, 7, 2, 7 }

   LOCAL x, y, x1, y1, x2, y2, x3, y3, tw

   /* create default-font */
   font := HPDF_GetFont( pdf, "Helvetica", NIL )

   /* add a new page object. */
   page := HPDF_AddPage( pdf )

   /* print the lines of the page. */
   HPDF_Page_SetLineWidth( page, 1 )
   HPDF_Page_Rectangle( page, 50, 50, HPDF_Page_GetWidth( page ) - 100, ;
      HPDF_Page_GetHeight( page ) - 110 )
   HPDF_Page_Stroke( page )

   /* print the title of the page(with positioning center). */
   HPDF_Page_SetFontAndSize( page, font, 24 )
   tw := HPDF_Page_TextWidth( page, page_title )
   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, ( HPDF_Page_GetWidth( page ) - tw ) / 2, ;
      HPDF_Page_GetHeight( page ) - 50 )
   HPDF_Page_ShowText( page, page_title )
   HPDF_Page_EndText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )

   /* Draw various widths of lines. */
   HPDF_Page_SetLineWidth( page, 0 )
   draw_line( page, 60, 770, "line width: 0" )

   HPDF_Page_SetLineWidth( page, 1.0 )
   draw_line( page, 60, 740, "line width: 1.0" )

   HPDF_Page_SetLineWidth( page, 2.0 )
   draw_line( page, 60, 710, "line width: 2.0" )

   /* Line dash pattern */
   HPDF_Page_SetLineWidth( page, 1.0 )

   HPDF_Page_SetDash( page, DASH_MODE1, 1, 1 )
   draw_line( page, 60, 680, "dash_ptn=[3], phase=1 -- 2 on, 3 off, 3 on..." )

   HPDF_Page_SetDash( page, DASH_MODE2, 2, 2 )
   draw_line( page, 60, 650, "dash_ptn=[7, 3], phase=2 -- 5 on 3 off, 7 on,..." )

   HPDF_Page_SetDash( page, DASH_MODE3, 4, 0 )
   draw_line( page, 60, 620, "dash_ptn=[8, 7, 2, 7], phase=0" )

   HPDF_Page_SetDash( page, , 0, 0 )

   HPDF_Page_SetLineWidth( page, 30 )
   HPDF_Page_SetRGBStroke( page, 0.0, 0.5, 0.0 )

   /* Line Cap Style */
   HPDF_Page_SetLineCap( page, HPDF_BUTT_END )
   draw_line2( page, 60, 570, "PDF_BUTT_END" )

   HPDF_Page_SetLineCap( page, HPDF_ROUND_END )
   draw_line2( page, 60, 505, "PDF_ROUND_END" )

   HPDF_Page_SetLineCap( page, HPDF_PROJECTING_SCUARE_END )
   draw_line2( page, 60, 440, "PDF_PROJECTING_SCUARE_END" )

   /* Line Join Style */
   HPDF_Page_SetLineWidth( page, 30 )
   HPDF_Page_SetRGBStroke( page, 0.0, 0.0, 0.5 )

   HPDF_Page_SetLineJoin( page, HPDF_MITER_JOIN )
   HPDF_Page_MoveTo( page, 120, 300 )
   HPDF_Page_LineTo( page, 160, 340 )
   HPDF_Page_LineTo( page, 200, 300 )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 60, 360 )
   HPDF_Page_ShowText( page, "PDF_MITER_JOIN" )
   HPDF_Page_EndText( page )

   HPDF_Page_SetLineJoin( page, HPDF_ROUND_JOIN )
   HPDF_Page_MoveTo( page, 120, 195 )
   HPDF_Page_LineTo( page, 160, 235 )
   HPDF_Page_LineTo( page, 200, 195 )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 60, 255 )
   HPDF_Page_ShowText( page, "PDF_ROUND_JOIN" )
   HPDF_Page_EndText( page )

   HPDF_Page_SetLineJoin( page, HPDF_BEVEL_JOIN )
   HPDF_Page_MoveTo( page, 120, 90 )
   HPDF_Page_LineTo( page, 160, 130 )
   HPDF_Page_LineTo( page, 200, 90 )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 60, 150 )
   HPDF_Page_ShowText( page, "PDF_BEVEL_JOIN" )
   HPDF_Page_EndText( page )

   /* Draw Rectangle */
   HPDF_Page_SetLineWidth( page, 2 )
   HPDF_Page_SetRGBStroke( page, 0, 0, 0 )
   HPDF_Page_SetRGBFill( page, 0.75, 0.0, 0.0 )

   draw_rect( page, 300, 770, "Stroke" )
   HPDF_Page_Stroke( page )

   draw_rect( page, 300, 720, "Fill" )
   HPDF_Page_Fill( page )

   draw_rect( page, 300, 670, "Fill then Stroke" )
   HPDF_Page_FillStroke( page )

   /* Clip Rect */
   HPDF_Page_GSave( page )   /* Save the current graphic state */
   draw_rect( page, 300, 620, "Clip Rectangle" )
   HPDF_Page_Clip( page )
   HPDF_Page_Stroke( page )
   HPDF_Page_SetFontAndSize( page, font, 13 )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 290, 600 )
   HPDF_Page_SetTextLeading( page, 12 )
   HPDF_Page_ShowText( page, "Clip Clip Clip Clip Clip Clipi Clip Clip Clip" )
   HPDF_Page_ShowTextNextLine( page, "Clip Clip Clip Clip Clip Clip Clip Clip Clip" )
   HPDF_Page_ShowTextNextLine( page, "Clip Clip Clip Clip Clip Clip Clip Clip Clip" )
   HPDF_Page_EndText( page )
   HPDF_Page_GRestore( page )

   /* Curve Example(CurveTo2) */
   x  := 330
   y  := 440
   x1 := 430
   y1 := 530
   x2 := 480
   y2 := 470
   x3 := 480
   y3 := 90

   HPDF_Page_SetRGBFill( page, 0, 0, 0 )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 300, 540 )
   HPDF_Page_ShowText( page, "CurveTo2(x1, y1, x2. y2)" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x + 5, y - 5 )
   HPDF_Page_ShowText( page, "Current point" )
   HPDF_Page_MoveTextPos( page, x1 - x, y1 - y )
   HPDF_Page_ShowText( page, "(x1, y1)" )
   HPDF_Page_MoveTextPos( page, x2 - x1, y2 - y1 )
   HPDF_Page_ShowText( page, "(x2, y2)" )
   HPDF_Page_EndText( page )

   HPDF_Page_SetDash( page, DASH_MODE1, 1, 0 )

   HPDF_Page_SetLineWidth( page, 0.5 )
   HPDF_Page_MoveTo( page, x1, y1 )
   HPDF_Page_LineTo( page, x2, y2 )
   HPDF_Page_Stroke( page )

   HPDF_Page_SetDash( page, , 0, 0 )

   HPDF_Page_SetLineWidth( page, 1.5 )

   HPDF_Page_MoveTo( page, x, y )
   HPDF_Page_CurveTo2( page, x1, y1, x2, y2 )
   HPDF_Page_Stroke( page )

   /* Curve Example(CurveTo3) */
   y  -= 150
   y1 -= 150
   y2 -= 150

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 300, 390 )
   HPDF_Page_ShowText( page, "CurveTo3(x1, y1, x2. y2)" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x + 5, y - 5 )
   HPDF_Page_ShowText( page, "Current point" )
   HPDF_Page_MoveTextPos( page, x1 - x, y1 - y )
   HPDF_Page_ShowText( page, "(x1, y1)" )
   HPDF_Page_MoveTextPos( page, x2 - x1, y2 - y1 )
   HPDF_Page_ShowText( page, "(x2, y2)" )
   HPDF_Page_EndText( page )

   HPDF_Page_SetDash( page, DASH_MODE1, 1, 0 )

   HPDF_Page_SetLineWidth( page, 0.5 )
   HPDF_Page_MoveTo( page, x, y )
   HPDF_Page_LineTo( page, x1, y1 )
   HPDF_Page_Stroke( page )

   HPDF_Page_SetDash( page, , 0, 0 )

   HPDF_Page_SetLineWidth( page, 1.5 )
   HPDF_Page_MoveTo( page, x, y )
   HPDF_Page_CurveTo3( page, x1, y1, x2, y2 )
   HPDF_Page_Stroke( page )

   /* Curve Example(CurveTo) */
   y  -= 150
   y1 -= 160
   y2 -= 130
   x2 += 10

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 300, 240 )
   HPDF_Page_ShowText( page, "CurveTo(x1, y1, x2. y2, x3, y3)" )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x + 5, y - 5 )
   HPDF_Page_ShowText( page, "Current point" )
   HPDF_Page_MoveTextPos( page, x1 - x, y1 - y )
   HPDF_Page_ShowText( page, "(x1, y1)" )
   HPDF_Page_MoveTextPos( page, x2 - x1, y2 - y1 )
   HPDF_Page_ShowText( page, "(x2, y2)" )
   HPDF_Page_MoveTextPos( page, x3 - x2, y3 - y2 )
   HPDF_Page_ShowText( page, "(x3, y3)" )
   HPDF_Page_EndText( page )

   HPDF_Page_SetDash( page, DASH_MODE1, 1, 0 )

   HPDF_Page_SetLineWidth( page, 0.5 )
   HPDF_Page_MoveTo( page, x, y )
   HPDF_Page_LineTo( page, x1, y1 )
   HPDF_Page_Stroke( page )
   HPDF_Page_MoveTo( page, x2, y2 )
   HPDF_Page_LineTo( page, x3, y3 )
   HPDF_Page_Stroke( page )

   HPDF_Page_SetDash( page, , 0, 0 )

   HPDF_Page_SetLineWidth( page, 1.5 )
   HPDF_Page_MoveTo( page, x, y )
   HPDF_Page_CurveTo( page, x1, y1, x2, y2, x3, y3 )
   HPDF_Page_Stroke( page )

   RETURN
   
function Page_Text( pdf )


   LOCAL page, font, rect := Array( 4 )
   LOCAL SAMP_TXT := "The quick brown fox jumps over the lazy dog. "
   LOCAL angle1, angle2, rad1, rad2, i, x, y, buf

#if 0
   LOCAL page_height
#endif

   /* add a new page object. */
   page := HPDF_AddPage( pdf )
   HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A5, HPDF_PAGE_PORTRAIT )

#if 0
   print_grid( pdf, page )

   page_height := HPDF_Page_GetHeight( page )
#endif

   font := HPDF_GetFont( pdf, "Helvetica", NIL )
   HPDF_Page_SetTextLeading( page, 20 )

   #define rLEFT    1
   #define rTOP     2
   #define rRIGHT   3
   #define rBOTTOM  4

   /* text_rect method */

   /* HPDF_TALIGN_LEFT */
   rect[ rLEFT   ] := 25
   rect[ rTOP    ] := 545
   rect[ rRIGHT  ] := 200
   rect[ rBOTTOM ] := rect[ 2 ] - 40

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
      rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_LEFT" )

   HPDF_Page_SetFontAndSize( page, font, 13 )
   HPDF_Page_TextRect( page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
      SAMP_TXT + SAMP_TXT, HPDF_TALIGN_LEFT, NIL )

   HPDF_Page_EndText( page )

   /* HPDF_TALIGN_RIGTH */
   rect[ rLEFT  ] := 220
   rect[ rRIGHT ] := 395

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
      rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_RIGTH" )

   HPDF_Page_SetFontAndSize( page, font, 13 )
   HPDF_Page_TextRect( page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
      SAMP_TXT, HPDF_TALIGN_RIGHT, NIL )

   HPDF_Page_EndText( page )

   /* HPDF_TALIGN_CENTER */
   rect[ rLEFT   ] := 25
   rect[ rTOP    ] := 475
   rect[ rRIGHT  ] := 200
   rect[ rBOTTOM ] := rect[ rTOP ] - 40

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
      rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_CENTER" )

   HPDF_Page_SetFontAndSize( page, font, 13 )
   HPDF_Page_TextRect( page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
      SAMP_TXT, HPDF_TALIGN_CENTER, NIL )

   HPDF_Page_EndText( page )

   /* HPDF_TALIGN_JUSTIFY */
   rect[ rLEFT  ] := 220
   rect[ rRIGHT ] := 395

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
      rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_JUSTIFY" )

   HPDF_Page_SetFontAndSize( page, font, 13 )
   HPDF_Page_TextRect( page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
      SAMP_TXT, HPDF_TALIGN_JUSTIFY, NIL )

   HPDF_Page_EndText( page )

   /* Skewed coordinate system */
   HPDF_Page_GSave( page )

   angle1 := 5
   angle2 := 10
   rad1   := angle1 / 180 * 3.141592
   rad2   := angle2 / 180 * 3.141592

   HPDF_Page_Concat( page, 1, Tan( rad1 ), Tan( rad2 ), 1, 25, 350 )
   rect[ rLEFT   ] := 0
   rect[ rTOP    ] := 40
   rect[ rRIGHT  ] := 175
   rect[ rBOTTOM ] := 0

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
      rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, rect[ rLEFT ], rect[ rTOP ] + 3, "Skewed coordinate system" )

   HPDF_Page_SetFontAndSize( page, font, 13 )
   HPDF_Page_TextRect( page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
      SAMP_TXT, HPDF_TALIGN_LEFT, NIL )

   HPDF_Page_EndText( page )

   HPDF_Page_GRestore( page )

   /* Rotated coordinate system */
   HPDF_Page_GSave( page )

   angle1 := 5
   rad1   := angle1 / 180 * 3.141592

   HPDF_Page_Concat( page, Cos( rad1 ), Sin( rad1 ), - Sin( rad1 ), Cos( rad1 ), 220, 350 )
   rect[ rLEFT   ] := 0
   rect[ rTOP    ] := 40
   rect[ rRIGHT  ] := 175
   rect[ rBOTTOM ] := 0

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
      rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke( page )

   HPDF_Page_BeginText( page )

   HPDF_Page_SetFontAndSize( page, font, 10 )
   HPDF_Page_TextOut( page, rect[ rLEFT ], rect[ rTOP ] + 3, "Rotated coordinate system" )

   HPDF_Page_SetFontAndSize( page, font, 13 )
   HPDF_Page_TextRect( page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
      SAMP_TXT, HPDF_TALIGN_LEFT, NIL )

   HPDF_Page_EndText( page )

   HPDF_Page_GRestore( page )

   /* text along a circle */
   HPDF_Page_SetGrayStroke( page, 0 )
   HPDF_Page_Circle( page, 210, 190, 145 )
   HPDF_Page_Circle( page, 210, 190, 113 )
   HPDF_Page_Stroke( page )

   angle1 := 360 / ( Len( SAMP_TXT ) )
   angle2 := 180

   HPDF_Page_BeginText( page )
   font := HPDF_GetFont( pdf, "Courier-Bold", NIL )
   HPDF_Page_SetFontAndSize( page, font, 30 )

   FOR i := 1 TO Len( SAMP_TXT )
      rad1 := ( angle2 - 90 ) / 180 * 3.141592
      rad2 := angle2 / 180 * 3.141592

      x := 210 + Cos( rad2 ) * 122
      y := 190 + Sin( rad2 ) * 122

      HPDF_Page_SetTextMatrix( page, Cos( rad1 ), Sin( rad1 ), - Sin( rad1 ), Cos( rad1 ), x, y )

      buf := SubStr( SAMP_TXT, i, 1 )
      HPDF_Page_ShowText( page, buf )
      angle2 -= angle1
   NEXT

   HPDF_Page_EndText( page )
   
retu  

function Page_Images( pdf )

   LOCAL font, page, dst, image, image1, image2, image3
   LOCAL x, y, angle, angle1, angle2, rad, rad1, rad2,  iw,  ih
   LOCAL cImagePath := hb_GetEnv( "PRGPATH" ) + "/files" + hb_ps()

   /* create default-font */
   font := HPDF_GetFont( pdf, "Helvetica", NIL )

   /* add a new page object. */
   page := HPDF_AddPage( pdf )

   HPDF_Page_SetWidth( page, 550 )
   HPDF_Page_SetHeight( page, 500 )

   dst := HPDF_Page_CreateDestination( page )
   HPDF_Destination_SetXYZ( dst, 0, HPDF_Page_GetHeight( page ), 1 )
   HPDF_SetOpenAction( pdf, dst )

   HPDF_Page_BeginText( page )
   HPDF_Page_SetFontAndSize( page, font, 20 )
   HPDF_Page_MoveTextPos( page, 220, HPDF_Page_GetHeight( page ) - 70 )
   HPDF_Page_ShowText( page, "ImageDemo" )
   HPDF_Page_EndText( page )

   /* load image file. */
   image := HPDF_LoadPngImageFromFile( pdf, cImagePath + "basn3p02.png" )

   /* image1 is masked by image2. */
   image1 := HPDF_LoadPngImageFromFile( pdf, cImagePath + "basn3p02.png" )

   /* image2 is a mask image. */
   image2 := HPDF_LoadPngImageFromFile( pdf, cImagePath + "basn0g01.png" )

   /* image3 is a RGB-color image. we use this image for color-mask demo. */
   image3 := HPDF_LoadPngImageFromFile( pdf, cImagePath + "maskimag.png" )

   iw := HPDF_Image_GetWidth( image )
   ih := HPDF_Image_GetHeight( image )
   HPDF_Page_SetLineWidth( page, 0.5 )

   x := 100
   y := HPDF_Page_GetHeight( page ) - 150

   /* Draw image to the canvas. (normal-mode with actual size.) */
   HPDF_Page_DrawImage( page, image, x, y, iw, ih )

   show_description_1( page, x, y, "Actual Size" )

   x += 150

   /* Scaling image(X direction) */
   HPDF_Page_DrawImage( page, image, x, y, iw * 1.5, ih )

   show_description_1( page, x, y, "Scaling image(X direction)" )

   x += 150

   /* Scaling image(Y direction). */
   HPDF_Page_DrawImage( page, image, x, y, iw, ih * 1.5 )
   show_description_1( page, x, y, "Scaling image(Y direction)" )

   x := 100
   y -= 120

   /* Skewing image. */
   angle1 := 10
   angle2 := 20
   rad1   := angle1 / 180 * 3.141592
   rad2   := angle2 / 180 * 3.141592

   HPDF_Page_GSave( page )
   HPDF_Page_Concat( page, iw, Tan( rad1 ) * iw, Tan( rad2 ) * ih, ih, x, y )
   HPDF_Page_ExecuteXObject( page, image )
   HPDF_Page_GRestore( page )

   show_description_1( page, x, y, "Skewing image" )

   x += 150

   /* Rotating image */
   angle := 30     /* rotation of 30 degrees. */
   rad := angle / 180 * 3.141592 /* Calcurate the radian value. */

   HPDF_Page_GSave( page )
   HPDF_Page_Concat( page, iw * Cos( rad ), ;
      iw * Sin( rad ), ;
      ih * -Sin( rad ), ;
      ih * Cos( rad ), ;
      x, y )
   HPDF_Page_ExecuteXObject( page, image )
   HPDF_Page_GRestore( page )

   show_description_1( page, x, y, "Rotating image" )

   x += 150

   /* draw masked image. */

   /* Set image2 to the mask image of image1 */
   HPDF_Image_SetMaskImage( image1, image2 )

   HPDF_Page_SetRGBFill( page, 0, 0, 0 )
   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x - 6, y + 14 )
   HPDF_Page_ShowText( page, "MASKMASK" )
   HPDF_Page_EndText( page )

   HPDF_Page_DrawImage( page, image1, x - 3, y - 3, iw + 6, ih + 6 )

   show_description_1( page, x, y, "masked image" )

   x := 100
   y -= 120

   /* color mask. */
   HPDF_Page_SetRGBFill( page, 0, 0, 0 )
   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x - 6, y + 14 )
   HPDF_Page_ShowText( page, "MASKMASK" )
   HPDF_Page_EndText( page )

   HPDF_Image_SetColorMask( image3, 0, 255, 0, 0, 0, 255 )
   HPDF_Page_DrawImage( page, image3, x, y, iw, ih )

   show_description_1( page, x, y, "Color Mask" )

   RETURN  
   
function show_description_1( page, x, y, text )

   LOCAL buf

   HPDF_Page_MoveTo( page, x, y - 10 )
   HPDF_Page_LineTo( page, x, y + 10 )
   HPDF_Page_MoveTo( page, x - 10, y )
   HPDF_Page_LineTo( page, x + 10, y )
   HPDF_Page_Stroke( page )

   HPDF_Page_SetFontAndSize( page, HPDF_Page_GetCurrentFont( page ), 8 )
   HPDF_Page_SetRGBFill( page, 0, 0, 0 )

   HPDF_Page_BeginText( page )

   buf := "x=" + hb_ntos( x ) + ",y=" + hb_ntos( y )

   HPDF_Page_MoveTextPos( page, x - HPDF_Page_TextWidth( page, buf ) - 5, y - 10 )
   HPDF_Page_ShowText( page, buf )
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x - 20, y - 25 )
   HPDF_Page_ShowText( page, text )
   HPDF_Page_EndText( page )

   RETURN  


STATIC PROCEDURE draw_rect( page, x, y, label )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x, y - 10 )
   HPDF_Page_ShowText( page, label )
   HPDF_Page_EndText( page )

   HPDF_Page_Rectangle( page, x, y - 40, 220, 25 )

   RETURN

STATIC PROCEDURE draw_line( page, x, y, label )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x, y - 10 )
   HPDF_Page_ShowText( page, label )
   HPDF_Page_EndText( page )

   HPDF_Page_MoveTo( page, x, y - 15 )
   HPDF_Page_LineTo( page, x + 220, y - 15 )
   HPDF_Page_Stroke( page )

   RETURN

STATIC PROCEDURE draw_line2( page, x, y, label )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, x, y )
   HPDF_Page_ShowText( page, label )
   HPDF_Page_EndText( page )

   HPDF_Page_MoveTo( page, x + 30, y - 25 )
   HPDF_Page_LineTo( page, x + 160, y - 25 )
   HPDF_Page_Stroke( page )

   RETURN   


function InitPrn()   

	local oPrn := TPdf():New( "list" )
   
	oPrn:LoadedFonts := { "Verdana" }
   
    oPrn:hFont[ 'helvetica24' ] 		:= oPrn:DefineFont( 'Helvetica', 24 )
    oPrn:hFont[ 'helvetica16-bold' ] 	:= oPrn:DefineFont( 'Helvetica-Bold', 16 ) 
	
    oPrn:hFont[ 'helvetica12' ] 		:= oPrn:DefineFont( 'Helvetica', 12 )  
    oPrn:hFont[ 'helvetica12-bold' ] 	:= oPrn:DefineFont( 'Helvetica-Bold', 12 )  
	
    oPrn:hFont[ 'helvetica10' ] 		:= oPrn:DefineFont( 'Helvetica', 10 )  
    oPrn:hFont[ 'helvetica10-bold' ] 	:= oPrn:DefineFont( 'Helvetica-Bold', 10 ) 	
	
    oPrn:hFont[ 'helvetica08' ] 		:= oPrn:DefineFont( 'Helvetica', 8 )  
    oPrn:hFont[ 'helvetica08-bold' ] 	:= oPrn:DefineFont( 'Helvetica-Bold', 8 ) 	
 
   
retu oPrn 

function RowCliente( oPrn, nRow, cTitle, uValue )

	oPrn:cmSay( nRow, 2, cTitle, oPrn:hFont[ 'helvetica12' ] ,, 0 )
	oPrn:cmSay( nRow, 5, uValue, oPrn:hFont[ 'helvetica12-bold' ] ,, 0 )

retu nil

function RowCliente10( oPrn, nRow, cTitle, uValue )

	oPrn:cmSay( nRow, 2, cTitle, oPrn:hFont[ 'helvetica10' ] ,, 0 )
	oPrn:cmSay( nRow, 5, uValue, oPrn:hFont[ 'helvetica10-bold' ] ,, 0 )

retu nil

function RowCliente08( oPrn, nRow, cTitle, uValue )

	oPrn:cmSay( nRow, 2, cTitle, oPrn:hFont[ 'helvetica08' ] ,, 0 )
	oPrn:cmSay( nRow, 5, uValue, oPrn:hFont[ 'helvetica08-bold' ] ,, 0 )

retu nil
//------------------------------------------------------------------------------

#include 'hbclass.ch'
#include 'harupdf.ch'

CLASS TPdf

   DATA hPdf
   DATA hPage
   DATA LoadedFonts
   DATA aPages
   DATA nCurrentPage

   DATA nPageSize INIT HPDF_PAGE_SIZE_A4
   DATA nOrientation INIT HPDF_PAGE_PORTRAIT // HPDF_PAGE_LANDSCAPE
   DATA nHeight, nWidth

   DATA cFileName
   DATA nPermission
   DATA cPassword, cOwnerPassword

   DATA hImageList

   DATA lPreview INIT .F.
   DATA bPreview
   
   DATA hFont							INIT {=>}

   CONSTRUCTOR New( cFileName, cPassword, cOwnerPassword, nPermission, lPreview )
   METHOD SetPage( nPageSize )
   METHOD SetLandscape()
   METHOD SetPortrait()
   METHOD SetCompression( cMode ) INLINE HPDF_SetCompressionMode( ::hPdf, cMode )
   METHOD StartPage()
   METHOD EndPage()
   METHOD Say( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad )
   METHOD CmSay( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad, lO2A )
   METHOD SayRotate( nTop, nLeft, cTxt, oFont, nClrText, nAngle )
   METHOD DefineFont( cFontName, nSize, lEmbed )
   METHOD Cmtr2Pix( nRow, nCol )
   METHOD Mmtr2Pix( nRow, nCol )
   METHOD CmRect2Pix( aRect )
   METHOD nVertRes() INLINE 72
   METHOD nHorzRes() INLINE 72
   METHOD nLogPixelX() INLINE 72  // Number of pixels per logical inch
   METHOD nLogPixelY() INLINE 72
   METHOD nVertSize() INLINE HPDF_Page_GetHeight( ::hPage )
   METHOD nHorzSize() INLINE HPDF_Page_GetWidth( ::hPage )
   METHOD SizeInch2Pix( nHeight, nWidth )
   METHOD CmSayBitmap( nRow, nCol, xBitmap, nWidth, nHeight, nRaster, lStrech )
   METHOD SayBitmap( nRow, nCol, xBitmap, nWidth, nHeight, nRaster )
   METHOD GetImageFromFile( cImageFile )
   METHOD Line( nTop, nLeft, nBottom, nRight, oPen )
   METHOD CmLine( nTop, nLeft, nBottom, nRight, oPen )
   METHOD Rect( nTop, nLeft, nBottom, nRight, oPen, nColor, nBackColor )
   METHOD CmRect( nTop, nLeft, nBottom, nRight, oPen, nColor, nBackColor )
   MESSAGE Box METHOD Rect
   MESSAGE CmBox METHOD CmRect
   METHOD RoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor, lFondo )
   METHOD CmRoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor, lFondo )
   MESSAGE RoundRect METHOD RoundBox
   MESSAGE CmRoundRect METHOD CmRoundBox

   METHOD SetPen( oPen, nColor )
   METHOD SetRGBStroke( nColor )
   METHOD SetRGBFill( nColor )

   METHOD DashLine( nTop, nLeft, nBottom, nRight, oPen, nDashMode )
   METHOD CmDashLine( nTop, nLeft, nBottom, nRight, oPen, nDashMode )
   METHOD Save( cFilename )
   METHOD SyncPage()
   METHOD CheckPage()
   METHOD GetTextWidth( cText, oFont )
   METHOD GetTextHeight( cText, oFont )

   METHOD End()

ENDCLASS

//------------------------------------------------------------------------------

METHOD New( cFileName, cPassword, cOwnerPassword, nPermission, lPreview ) CLASS TPdf

   ::hPdf := HPDF_New()
   ::LoadedFonts := {}

   if ::hPdf == NIL
      ? "Pdf could not been created!"
      return NIL
   endif

   HPDF_SetCompressionMode( ::hPdf, HPDF_COMP_ALL )

   ::cFileName := cFileName
   ::cPassword := cPassword
   ::cOwnerPassword := cOwnerPassword
   ::nPermission := nPermission

   ::hImageList := { => }
   ::aPages := {}
   ::nCurrentPage := 0

   // Mastintin
   if HB_ISLOGICAL( lPreview )
      ::lPreview:= lPreview
    //  ::bPreview := { || HaruShellexecute( NIL, "open", ::cFileName ) }
   endif

return Self

//------------------------------------------------------------------------------

METHOD SetPage( nPageSize ) CLASS TPdf

   ::nPageSize:= nPageSize
   ::SyncPage()

return Self

//------------------------------------------------------------------------------

METHOD SyncPage() CLASS TPdf

   if ::hPage != NIL
      HPDF_Page_SetSize( ::hPage, ::nPageSize, ::nOrientation )
      ::nHeight := HPDF_Page_GetHeight( ::hPage )
      ::nWidth  := HPDF_Page_GetWidth( ::hPage )
   endif

return NIL

//------------------------------------------------------------------------------

METHOD CheckPage() CLASS TPdf

   if ::hPage == NIL
      ::StartPage()
   endif

return NIL

//------------------------------------------------------------------------------

METHOD SetLandscape() CLASS TPdf

   ::nOrientation:= HPDF_PAGE_LANDSCAPE
   ::SyncPage()

return Self

//------------------------------------------------------------------------------

METHOD SetPortrait() CLASS TPdf

   ::nOrientation:= HPDF_PAGE_PORTRAIT
   ::SyncPage()

return Self

//------------------------------------------------------------------------------

METHOD StartPage() CLASS TPdf

   ::hPage := HPDF_AddPage( ::hPdf )
   AAdd( ::aPages, ::hPage )
   ::nCurrentPage := Len( ::aPages )
   ::SyncPage()

return Self

//------------------------------------------------------------------------------

METHOD EndPage() CLASS TPdf

   ::hPage := NIL

return Self

//------------------------------------------------------------------------------

METHOD Say( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad ) CLASS TPdf

   local c, nTextHeight

   ::CheckPage()
   HPDF_Page_BeginText( ::hPage )

   if oFont == NIL
      nTextHeight := HPDF_Page_GetCurrentFontSize( ::hPage )
   ELSE
      HPDF_Page_SetFontAndSize( ::hPage, oFont[ 1 ], oFont[ 2 ] )
      nTextHeight := oFont[ 2 ]
   endif

   if ValType( nClrText ) == 'N'
      c := HPDF_Page_GetRGBFill( ::hPage )
      ::SetRGBFill( nClrText )
   endif

   DO CASE
   CASE nPad == NIL .OR. nPad == HPDF_TALIGN_LEFT
      HPDF_Page_TextOut( ::hPage, nCol, ::nHeight - nRow - nTextHeight, cText )
   CASE nPad == HPDF_TALIGN_RIGHT
      nWidth := HPDF_Page_TextWidth( ::hPage, cText )
      HPDF_Page_TextOut( ::hPage, nCol - nWidth, ::nHeight - nRow - nTextHeight, cText )
   OTHER
      nWidth := HPDF_Page_TextWidth( ::hPage, cText )
      HPDF_Page_TextOut( ::hPage, nCol - nWidth / 2, ::nHeight - nRow - nTextHeight, cText )
   ENDCASE

   if ValType( c ) == 'A'
      HPDF_Page_SetRGBFill( ::hPage, c[ 1 ], c[ 2 ], c[ 3 ] )
   endif
   HPDF_Page_EndText( ::hPage )

return Self

//------------------------------------------------------------------------------

METHOD CmSay( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad, lO2A ) CLASS TPdf

   ::Cmtr2Pix( @nRow, @nCol )
   if nWidth != Nil
      ::Cmtr2Pix( 0, @nWidth )
   endif
   ::Say( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad, lO2A )

return Self

//------------------------------------------------------------------------------

METHOD DefineFont( cFontName, nSize, lEmbed ) CLASS TPdf

   local font_list  := { ;
                        "Courier",                  ;
                        "Courier-Bold",             ;
                        "Courier-Oblique",          ;
                        "Courier-BoldOblique",      ;
                        "Helvetica",                ;
                        "Helvetica-Bold",           ;
                        "Helvetica-Oblique",        ;
                        "Helvetica-BoldOblique",    ;
                        "Times-Roman",              ;
                        "Times-Bold",               ;
                        "Times-Italic",             ;
                        "Times-BoldItalic",         ;
                        "Symbol",                   ;
                        "ZapfDingbats"              ;
                      }

   local i, ttf_list

   i := aScan( font_list, {|x| Upper( x ) == Upper( cFontName ) } )
   if i > 0 // Standard font
      cFontName:= font_list[ i ]
   ELSE
      i := aScan( ::LoadedFonts, {|x| Upper( x[ 1 ] ) == Upper( cFontName ) } )
      if i > 0
         cFontName := ::LoadedFonts[ i ][ 2 ]
         //DEBUGMSG 'Activada fuente ' + cFontName
      ELSE
         ttf_list := GetHaruFontList()
         i := aScan( ttf_list, {|x| Upper( x[ 1 ] ) == Upper( cFontName ) } )
         if i > 0
            cFontName := HPDF_LoadTTFontFromFile( ::hPdf, ttf_list[ i, 2 ], lEmbed )
            //DEBUGMSG 'Cargada fuente ' + cFontName
            //DEBUGMSG 'Fichero ' + ttf_list[ i, 2 ]
            AAdd( ::LoadedFonts, { ttf_list[ i, 1 ], cFontName } )
         ELSE
            Alert( 'Fuente desconocida '+cFontName )
            return NIL
         endif
      endif
   endif

return { HPDF_GetFont( ::hPdf, cFontName, "WinAnsiEncoding" ), nSize }

//------------------------------------------------------------------------------

METHOD Cmtr2Pix( nRow, nCol ) CLASS TPdf

   nRow *= 72 / 2.54
   nCol *= 72 / 2.54

return { nRow, nCol }

//------------------------------------------------------------------------------

METHOD Mmtr2Pix( nRow, nCol ) CLASS TPdf

   nRow *= 72 / 25.4
   nCol *= 72 / 25.4

 return { nRow, nCol }

//------------------------------------------------------------------------------

METHOD CmRect2Pix( aRect ) CLASS TPdf

   local aTmp[ 4 ]

   aTmp[ 1 ] = Max( 0, aRect[ 1 ] * 72 / 2.54 )
   aTmp[ 2 ] = Max( 0, aRect[ 2 ] * 72 / 2.54 )
   aTmp[ 3 ] = Max( 0, aRect[ 3 ] * 72 / 2.54 )
   aTmp[ 4 ] = Max( 0, aRect[ 4 ] * 72 / 2.54 )

return aTmp

//------------------------------------------------------------------------------

METHOD SizeInch2Pix( nHeight, nWidth ) CLASS TPdf

   nHeight *= 72
   nWidth *= 72

return { nHeight, nWidth }

//------------------------------------------------------------------------------

METHOD GetImageFromFile( cImageFile ) CLASS TPdf

   if hb_HHasKey( ::hImageList, cImageFile )
      return ::hImageList[ cImageFile ]
   endif
   if ! File( cImageFile )
      IF( Lower( Right( cImageFile, 4 ) ) == '.bmp' ) // En el c�digo esta como bmp, probar si ya fue transformado a png
         cImageFile := Left( cImageFile, Len( cImageFile ) - 3 ) + 'png'
         return ::GetImageFromFile( cImageFile )
      ELSE
         ? cImageFile + ' not found'
         return NIL
      endif
   endif
   IF( Lower( Right( cImageFile, 4 ) ) == '.png' )
      return ( ::hImageList[ cImageFile ] := HPDF_LoadPngImageFromFile(::hPdf, cImageFile ) )
   endif

return ::hImageList[ cImageFile ] := HPDF_LoadJpegImageFromFile(::hPdf, cImageFile )

//------------------------------------------------------------------------------

METHOD SayBitmap( nRow, nCol, xBitmap, nWidth, nHeight, nRaster ) CLASS TPdf

   local image

   if !Empty( image := ::GetImageFromFile( xBitmap ) )
      HPDF_Page_DrawImage( ::hPage, image, nCol, ::nHeight - nRow - nHeight, nWidth, nHeight /* iw, ih*/)
   endif

return Self

//------------------------------------------------------------------------------

METHOD Line( nTop, nLeft, nBottom, nRight, oPen ) CLASS TPdf

   if oPen != NIL
      ::SetPen( oPen )
   endif

   HPDF_Page_MoveTo ( ::hPage, nLeft, ::nHeight - nTop )
   HPDF_Page_LineTo ( ::hPage, nRight, ::nHeight - nBottom )
   HPDF_Page_Stroke ( ::hPage )

return Self

//------------------------------------------------------------------------------

METHOD Save( cFilename ) CLASS TPdf

   FErase( cFilename )

   if ValType( ::nPermission ) != 'N'
      ::nPermission := ( HPDF_ENABLE_READ + HPDF_ENABLE_PRINT + HPDF_ENABLE_COPY )
   endif

   if ValType( ::cPassword ) == 'C' .AND. !Empty( ::cPassword )
      if Empty( ::cOwnerPassword )
         ::cOwnerPassword := ::cPassword + '+1'
      endif
      HPDF_SetPassword( ::hPdf, ::cOwnerPassword, ::cPassword )
      HPDF_SetPermission( ::hPdf, ::nPermission )
   endif

return HPDF_SaveToFile ( ::hPdf, cFilename )

//------------------------------------------------------------------------------

METHOD GetTextWidth( cText, oFont ) CLASS TPdf

   HPDF_Page_SetFontAndSize( ::hPage, oFont[ 1 ], oFont[ 2 ] )

return HPDF_Page_TextWidth( ::hPage, cText )

//------------------------------------------------------------------------------

METHOD GetTextHeight( cText, oFont ) CLASS TPdf

   HPDF_Page_SetFontAndSize( ::hPage, oFont[ 1 ], oFont[ 2 ] )

return oFont[ 2 ] // height of the font when we create it

//------------------------------------------------------------------------------

METHOD End() CLASS TPdf

   local nResult

   if ValType( ::cFileName ) == 'C'
      nResult := ::Save( ::cFileName )
   endif

   HPDF_Free( ::hPdf )

   ::aPages := {}

   if ::lPreview
      Eval( ::bPreview, Self )
   endif

return nResult

//------------------------------------------------------------------------------

METHOD Rect( nTop, nLeft, nBottom, nRight, oPen, nColor, nBackColor ) CLASS TPdf

   HPDF_Page_GSave( ::hPage )
   ::SetPen( oPen, nColor )

   if HB_ISNUMERIC( nBackColor )
      ::SetRGBFill( nBackColor )
   endif

   HPDF_Page_Rectangle( ::hPage, nLeft, ::nHeight - nBottom, nRight - nLeft,  nBottom - nTop )

   if HB_ISNUMERIC( nBackColor )
      HPDF_Page_FillStroke( ::hPage )
   ELSE
      HPDF_Page_Stroke ( ::hPage )
   endif
   HPDF_Page_GRestore( ::hPage )

return Self


METHOD CmRect( nTop, nLeft, nBottom, nRight, oPen, nColor, nBackColor ) CLASS TPdf

   ::Rect( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, oPen, nColor, nBackColor )

return Self

METHOD CmLine( nTop, nLeft, nBottom, nRight, oPen ) CLASS TPdf

   ::Line( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, oPen )

return Self

METHOD CmDashLine( nTop, nLeft, nBottom, nRight, oPen, nDashMode ) CLASS TPdf

   ::DashLine( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, oPen, nDashMode )

return Self

METHOD DashLine( nTop, nLeft, nBottom, nRight, oPen, nDashMode ) CLASS TPdf

   HPDF_Page_SetDash( ::hPage, { 3, 7 }, 2, 2 )
   ::Line( nTop, nLeft, nBottom, nRight, oPen )
   HPDF_Page_SetDash( ::hPage, NIL, 0, 0 )

return Self

//------------------------------------------------------------------------------

METHOD CmSayBitmap( nRow, nCol, xBitmap, nWidth, nHeight, nRaster, lStrech  ) CLASS TPdf

   if !Empty(  nWidth  )
     nWidth := nWidth * 72 / 2.54
   endif

   if !Empty(  nHeight  )
      nHeight := nHeight * 72 / 2.54
   endif

   ::SayBitmap( nRow * 72 / 2.54, nCol * 72 / 2.54, xBitmap, nWidth, nHeight, nRaster, lStrech )

return nil 

//------------------------------------------------------------------------------

METHOD RoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor ) CLASS TPdf

   local nRay
   local xposTop, xposBotton
   local nRound

   HB_DEFAULT( @nWidth, 0 )
   HB_DEFAULT( @nHeight, 0 )

      nRound:= Min( nWidth, nHeight )

      nRound := nRound / 250

   HPDF_Page_GSave(::hPage)
   ::SetPen( oPen, nColor )

   if HB_ISNUMERIC( nBackColor )
      ::SetRGBFill( nBackColor )
   endif

   if Empty( nRound )
      HPDF_Page_Rectangle( ::hPage, nLeft, ::nHeight - nBottom, nRight - nLeft,  nBottom - nTop )
   ELSE
      nRay = Round( iif( ::nWidth > ::nHeight, Min( nRound,Int( (nBottom - nTop ) / 2 ) ), Min( nRound,Int( (nRight - nLeft) / 2 ) ) ), 0 )

      xposTop := ::nHeight - nTop
      xposBotton := ::nHeight - nBottom

      HPDF_Page_MoveTo ( ::hPage, nLeft + nRay,  xposTop )
      HPDF_Page_LineTo ( ::hPage, nRight - nRay, xposTop )

      HPDF_Page_CurveTo( ::hPage, nRight, xposTop, nRight,  xposTop, nRight,  xposTop - nRay )

      HPDF_Page_LineTo ( ::hPage, nRight, xposBotton + nRay )
      HPDF_Page_CurveTo( ::hPage, nRight, xposBotton, nRight, xposBotton, nRight - nRay,  xposBotton  )
      HPDF_Page_LineTo ( ::hPage, nLeft + nRay, xposBotton )
      HPDF_Page_CurveTo( ::hPage, nLeft, xposBotton,  nLeft, xposBotton, nLeft, xposBotton + nRay )

      HPDF_Page_LineTo ( ::hPage, nLeft, xposTop - nRay )
      HPDF_Page_CurveTo( ::hPage, nLeft, xposTop,  nLeft, xposTop, nLeft + nRay, xposTop )
   endif

   if HB_ISNUMERIC( nBackColor )
      HPDF_Page_FillStroke ( ::hPage )
   ELSE
      HPDF_Page_Stroke ( ::hPage )
   endif
   HPDF_Page_GRestore( ::hPage )

return Self

//------------------------------------------------------------------------------

METHOD SetPen( oPen, nColor ) CLASS TPdf

   if oPen != NIL
      if ValType( oPen ) == 'N'
         HPDF_Page_SetLineWidth( ::hPage, oPen )
      ELSE
         HPDF_Page_SetLineWidth( ::hPage, oPen:nWidth )
         nColor:= oPen:nColor
      endif
   endif

   if ValType( nColor ) == 'N'
      ::SetRGBStroke( nColor )
   endif

return SELF

//------------------------------------------------------------------------------

METHOD SetRGBStroke( nColor ) CLASS TPdf

  HPDF_Page_SetRGBStroke( ::hPage, ( nColor  % 256 ) / 256.00,;
                                   ( Int( nColor / 0x100 )  % 256 ) / 256.00,;
                                   ( Int( nColor / 0x10000 ) % 256 ) / 256.00 )
return NIL

//------------------------------------------------------------------------------

METHOD SetRGBFill( nColor ) CLASS TPdf

    HPDF_Page_SetRGBFill( ::hPage, HB_BitAnd( Int( nColor ), 0xFF ) / 255.00,;
                                   HB_BitAnd( HB_BitShift( Int( nColor ), -8 ), 0xFF ) / 255.00,;
                                   HB_BitAnd( HB_BitShift( Int( nColor ), -16 ), 0xFF ) / 255.00 )


//  HPDF_Page_SetRGBFill( ::hPage,  nRGBRed( nColor ) / 255.00,;
//                                  nRGBGeen( nColor ) / 255.00,;
//                                  nRGBBlue( nColor ) / 255.00 )

//  HPDF_Page_SetRGBFill( ::hPage, ( nColor  % 256 ) / 256.00,;
//                                  ( Int( nColor / 0x100 )  % 256 ) / 256.00,;
//                                  ( Int( nColor / 0x10000 ) % 256 ) / 256.00 )

return NIL

//------------------------------------------------------------------------------

METHOD CmRoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor, lFondo ) ;
   CLASS TPdf

   DEFAULT nWidth To 0, nHeight TO 0

return ::RoundBox( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54,;
       nWidth * 72 / 2.54 , nHeight * 72 / 2.54 , oPen, nColor, nBackColor, lFondo )

//------------------------------------------------------------------------------

METHOD SayRotate( nTop, nLeft, cTxt, oFont, nClrText, nAngle ) CLASS TPdf

   local aBackColor
   local nRadian := ( nAngle / 180 ) * 3.141592 /* Calcurate the radian value. */

    if ValType( nClrText ) == 'N'
       aBackColor:= HPDF_Page_GetRGBFill( ::hPage )
      ::SetRGBFill( nClrText )
   endif

   /* FONT and SIZE*/
   if !Empty( oFont )
       HPDF_Page_SetFontAndSize( ::hPage, oFont[1], oFont[2] )
   EndI

   /* Rotating text */
   HPDF_Page_BeginText( ::hPage )
//   HPDF_Page_SetTextMatrix( ::hPage, cos( nRadian ),;
//                                     sin( nRadian ),;
//                                     -( sin( nRadian ) ),;
//                                     cos( nRadian ), nLeft, HPDF_Page_GetHeight( ::hPage )-( nTop ) )
   HPDF_Page_ShowText( ::hPage, cTxt )

   if ValType( aBackColor ) == 'A'
      HPDF_Page_SetRGBFill( ::hPage, aBackColor[1], aBackColor[2], aBackColor[3] )
   endif

   HPDF_Page_EndText( ::hPage )

return NIL

//------------------------------------------------------------------------------

FUNCTION SetHaruFontDir(cDir)

   local cPrevValue:= cFontDir
   if ValType( cDir ) == 'C' .AND. HB_DirExists( cDir )
      cFontDir:= cDir
   endif

return cPrevValue

//------------------------------------------------------------------------------

FUNCTION GetHaruFontDir()

#define CSIDL_FONTS 0x0014

   if cFontDir == NIL
    //  cFontDir:= HaruGetSpecialFolder( CSIDL_FONTS )
   endif

return cFontDir

//------------------------------------------------------------------------------

FUNCTION GetHaruFontList()

   if aTtfFontList == NIL
      InitTtfFontList()
   endif

return aTtfFontList

//------------------------------------------------------------------------------

STATIC FUNCTION InitTtfFontList()

   local aDfltList:= { { 'Arial', 'arial.ttf' } ;
                     , { 'Verdana', 'verdana.ttf' } ;
                     , { 'Courier New', 'cour.ttf' } ;
                     , { 'Calibri', 'calibri.ttf' } ;
                     , { 'Tahoma', 'tahoma.ttf' } ;
                     }

   aTtfFontList:= {}
   aEval( aDfltList, {|_x| HaruAddFont( _x[1], _x[2] ) } )

return NIL

//------------------------------------------------------------------------------

FUNCTION HaruAddFont( cFontName, cTtfFile )

   local aList := GetHaruFontList()

   if !File( cTtfFile ) .AND. File( GetHaruFontDir() + '\' + cTtfFile )
      cTtfFile:= GetHaruFontDir() + '\' + cTtfFile
   endif
   if File( cTtfFile )
      aAdd( aList, { cFontName, cTtfFile } )
   ELSE
      ? 'file not found ' + cTtfFile
   endif

return NIL

//------------------------------------------------------------------------------