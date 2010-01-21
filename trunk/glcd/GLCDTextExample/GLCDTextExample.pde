/*
 * GLCDexample
 *
 * Basic test code for the Arduino GLCD library.
 * This code exercises a range of graphic functions supported
 * by the library and is an example of its use.
 * It also gives an indication of performance, showing the
 * number of frames drawn per second.  
 */

/*  This version uses .Text.WindowFunction syntax 
    not all library functionality has been implemented
 */


#include <glcd.h>
#include "fonts/Arial14.h"             // proportional font
#include "fonts/SystemFont5x7.h"       // system font
#include "bitmaps/ArduinoIcon64x64.h"  // 64x64 bitmap 
#include "bitmaps/ArduinoIcon64x32.h"

unsigned long startMillis;
unsigned int loops = 0;
unsigned int iter = 0;

void setup(){
  Serial.begin(9600);
  delay(500);    // allow the hardware time settle
  GLCD.Init();   // initialise the library, non inverted writes pixels onto a clear screen
  introScreen();
  GLCD.ClearScreen();
}

void  loop(){   // run over and over again
  byte centerX = GLCD.Width /2 ;
  byte centerY = GLCD.Height / 2;
  byte bottom = GLCD.Height -1;
  iter=0; 
  startMillis = millis();
  while(iter++ < 10){   // do 10 iterations
    GLCD.DrawRect(0, 0, centerX, bottom); // rectangle in left side of screen
    GLCD.DrawRoundRect(centerX + 2, 0, centerX -3, bottom, 5);  // rounded rectangle around text area   
    for(int i=0; i < bottom; i += 4)
      GLCD.DrawLine(1,1, centerX-1, i);  // draw lines from upper left down right side of rectangle  
    GLCD.DrawCircle(centerX/2, centerY-1, centerY-2);   // draw circle centered in the left side of screen  
    GLCD.FillRect( centerX + centerX/2-8 ,centerY + centerY/2 -8,16,16, WHITE); // clear previous spinner position  
    drawSpinner(loops++, centerX + centerX/2, centerY + centerY/2);       // draw new spinner position
    GLCD.GotoXY(centerX/2, bottom -15); // todo             
    GLCD.print(iter);            // print current iteration at the current cursor position 
  } 
  // display iterations per second
  unsigned long duration = millis() - startMillis;
  int fps = 10000 / duration;
  int fps_fract = (10000 % duration) / 10;
  GLCD.ClearScreen();               // clear the screen  
  //  GLCD.CursorTo(centerX/8 + 1,1);   // position cursor - TODO 
  GLCD.GotoXY(centerX + 4, centerY - 8);
  GLCD.print("FPS=");               // print a text string
  GLCD.print(fps);              
  GLCD.print(".");
  GLCD.print(fps_fract);
}

void showAscii(int _delay)
{
  for( char ch = 0x40; ch < 0x7f; ch++)
  {
    GLCD.print(ch);
    delay(_delay);
  }   
}

void introScreen(){  
  if(GLCD.Height >= 64)   
    GLCD.DrawBitmap(ArduinoIcon, 32,0); //draw the bitmap at the given x,y position
  else
    GLCD.DrawBitmap(ArduinoIcon64x32, 32,0); //draw the bitmap at the given x,y position
  countdown(3);
  GLCD.ClearScreen();
  GLCD.SelectFont(Arial_14); // you can also make your own fonts, see playground for details   
  GLCD.GotoXY(10, 2);
  GLCD.print("GLCD ver ");
  GLCD.print(GLCD_VERSION, DEC);
  GLCD.DrawRoundRect(8,0,GLCD.Width-9,18, 5);  // rounded rectangle around text area   
  countdown(3);  
  scrollingDemo();
  GLCD.Text.SelectArea(0);
  GLCD.SelectFont(System5x7, BLACK);
  GLCD.Text.DefineArea(0, 0,0,GLCD.Width-1, GLCD.Height-1, 1);
  GLCD.ClearScreen();  
  showCharacters();
  countdown(3);
}

void showCharacters(){
  // this displays the fixed width system font  
  GLCD.CursorTo(0,0);
  GLCD.print("5x7 font:");
  GLCD.DrawRoundRect(GLCD.Width/2 + 2, 0, GLCD.Width/2 -3, GLCD.Height-1, 5);  // rounded rectangle around text area 
  GLCD.Text.SelectArea(1);
  GLCD.SelectFont(System5x7, BLACK);
  GLCD.Text.DefineArea(1, GLCD.Width/2 + 5, 3, GLCD.Width -1-4, GLCD.Height -1-4, 1);
  GLCD.CursorTo(0,0);
  for(byte c = 32; c <=127; c++){
    GLCD.print(c);  
    delay(50);
  }
  GLCD.Text.SelectArea(0); 
}

void drawSpinner(byte pos, byte x, byte y) {   
  // this draws an object that appears to spin
  switch(pos % 8) {
    case 0 : GLCD.DrawLine( x, y-8, x, y+8); break;
    case 1 : GLCD.DrawLine( x+3, y-7, x-3, y+7);  break;
    case 2 : GLCD.DrawLine( x+6, y-6, x-6, y+6);  break;
    case 3 : GLCD.DrawLine( x+7, y-3, x-7, y+3);  break;
    case 4 : GLCD.DrawLine( x+8, y, x-8, y);      break;
    case 5 : GLCD.DrawLine( x+7, y+3, x-7, y-3);  break;
    case 6 : GLCD.DrawLine( x+6, y+6, x-6, y-6);  break; 
    case 7 : GLCD.DrawLine( x+3, y+7, x-3, y-7);  break;
  } 
}

void countdown(int count){
  GLCD.SelectFont(System5x7); // select fixed width system font 
  while(count--){  // do countdown  
    GLCD.CursorTo(0,1);   // first column, second row (offset is from 0)
    GLCD.print((char)(count + '0'));
    delay(1000);  
  }  
}

// this function demonstrates scrolling bitmaps and text
void scrollingDemo()
{
  int x;

  GLCD.ClearScreen(WHITE);
  GLCD.SelectFont(System5x7, WHITE); // switch to fixed width system font 
  for(x = 0; x< 32; x++)
  {
    GLCD.FillRect(x, x, 31-x, 31-x, BLACK);
    delay(40);
    GLCD.FillRect(x, x, 31-x, 31-x, WHITE);
  }
  for(x = 31; x; x--)
  {
    GLCD.FillRect(x, x, 31-x, 31-x, BLACK);
    delay(40);
    GLCD.FillRect(x, x, 31-x, 31-x, WHITE);
  }

  for(x = 0; x < 8; x++)
  {
    if(GLCD.Height > 32)
      GLCD.DrawBitmap(ArduinoIcon64x32, x, 0, BLACK);
    else
      GLCD.DrawBitmap(ArduinoIcon64x32, x, x, BLACK);
    delay(50);
  }
  GLCD.ClearScreen();

  for(x = 0; x < 16; x++)
  {
    GLCD.DrawBitmap(ArduinoIcon64x32, GLCD.Width /2 -16 + x, 0, WHITE);
    delay(50);
  }
  
  GLCD.Text.SelectArea(0);
  GLCD.Text.DefineArea(0, 0,0, GLCD.Width-1,GLCD.Height-1, 1);
  GLCD.SelectFont(Arial_14, WHITE);
  for(x=0; x< 15; x++)
  {
    for(byte p = 0; p < GLCD.Height; p+=8)
    {
      GLCD.DrawHLine(0,p, 8);
    }
    GLCD.GotoXY(x,x);
    GLCD.print("@ABCDFGHIJ");
    delay(200);
    GLCD.ClearScreen();
  }

  GLCD.ClearScreen();  
  GLCD.Text.SelectArea(0);
//  GLCD.Text.DefineArea(0, 0,0, GLCD.Width/2 -1,GLCD.Height/2 -1, 1);
  GLCD.Text.DefineArea(0,textAreaLEFT,1); 
  GLCD.SelectFont(System5x7, WHITE);
  GLCD.CursorTo(0,0);
  GLCD.Text.SelectArea(1);
//  GLCD.Text.DefineArea(1, GLCD.Width/2,0, GLCD.Width-1,GLCD.Height/2-1, -1);
  GLCD.Text.DefineArea(0,textAreaRIGHT,-1); 
  GLCD.SelectFont(System5x7, BLACK);
  GLCD.CursorTo(0,0);
  GLCD.Text.SelectArea(2);
//  GLCD.Text.DefineArea(2, 0,GLCD.Height/2, GLCD.Width-1,GLCD.Height-1, 1);
  GLCD.Text.DefineArea(2,textAreaBOTTOM,1); 
  
  GLCD.SelectFont(Arial_14, BLACK);
  GLCD.CursorTo(0,0);

  for(byte area = 0; area< 3; area++)
  {
    GLCD.Text.SelectArea(area);
    showAscii(80);
  }
  for(char c = 0x20; c < 0x7f; c++)
  {
    for(byte area = 0; area < 3; area++)
    {
      GLCD.Text.SelectArea(area);
      GLCD.print(c);
    }
    delay(50);
  }  

  for(byte area = 0; area< 3; area++)
  {
    GLCD.Text.SelectArea(area);
    GLCD.Text.ClearArea();
  }
  for(x = 0; x< 15; x++)
  {
    for(byte area = 0; area < 3; area++)
    {
      GLCD.Text.SelectArea(area);

      // The newline needs to be sent just before the string to make
      // the scrolling look correct. It can be moved below
      // the delay but it won't look as good.
      // if the newline is done while printing the number,
      // you lose a line in the text area because of the scroll
      // and it no longer works with only a 2 line text area.

      GLCD.print("\nline ");
      GLCD.print(x);
      delay(100);
    }
  }

  GLCD.Text.SelectArea(1);
  GLCD.Text.ClearArea();
  for(x = 0; x < 16; x++)
  {
    GLCD.DrawBitmap(ArduinoIcon64x32, GLCD.Width/2 -16 + x, 0, WHITE);
    delay(50);
  }
  if(GLCD.Height < 64)
  {
    GLCD.Text.SelectArea(0);
    GLCD.Text.DefineArea(0, 0,0,GLCD.Width/2-1, GLCD.Height-1, 1);
  }

  for(char c = 0x20; c < 0x7f; c++)
  {
    GLCD.Text.SelectArea(0);
    GLCD.print(c);
    if(GLCD.Height > 32 )
    {    
      GLCD.Text.SelectArea(2);
      GLCD.print(c);
    }           
    delay(50);
  }
  delay(2000);
}
