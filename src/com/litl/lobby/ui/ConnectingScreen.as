package com.litl.lobby.ui
{
    import flash.display.MovieClip;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class ConnectingScreen extends MovieClip
    {

        public function ConnectingScreen() {

            //create background and position it
            var bg:PopuupBackground = new PopuupBackground();
            bg.width = 200;
            bg.height = 100;
            addChild(bg);

            //create message and position it
            var txt:MyTextLabel = new MyTextLabel();
            txt.label_txt.text = "Connecting...";
            txt.x = 100;
            txt.y = 50;
            addChild(txt);
        }

    }

}
