package com.litl.lobby.ui
{
    import fl.controls.Button;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class ErrorScreen extends MovieClip
    {

        public static const OK:String = "ok";

        public function ErrorScreen(msg:String) {

            //create background and position it
            var bg:PopuupBackground = new PopuupBackground();
            addChild(bg);
            bg.width = 200;
            bg.height = 100;

            //create ok button and position it
            var btn:Button = new Button();
            btn.label = "ok";
            btn.x = 50;
            btn.y = 60;
            btn.addEventListener(MouseEvent.CLICK, onClick);
            addChild(btn);

            //create message field and position it
//            var txt:TextLabel = new TextLabel();
//            txt.label_txt.text = msg;
//            txt.x = 100;
//            txt.y = 40;
//            addChild(txt);
        }

        private function onClick(e:MouseEvent):void {
            dispatchEvent(new Event(OK));
        }

    }

}
