package com.litl.lobby.ui
{
    import fl.controls.Button;
    import fl.controls.TextInput;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class CreateRoomScreen extends MovieClip
    {

        public static const OK:String = "ok";

        private var _roomName:String;
        private var _input:TextInput;

        public function CreateRoomScreen() {

            //create background and position it
            var bg:PopuupBackground = new PopuupBackground();
            addChild(bg);
            bg.width = 260;
            bg.height = 150;

            //create input field and position it
            _input = new TextInput();
            _input.x = 33;
            _input.y = 57;
            _input.width = 185;
            addChild(_input);

            //create submit button and position it
            var btn:Button = new Button();
            btn.label = "Submit";
            btn.x = 76;
            btn.y = 90;
            btn.addEventListener(MouseEvent.CLICK, onClick);
            addChild(btn);

            //create directive and position it
//            var txt:TextLabel = new TextLabel();
//            txt.x = 130;
//            txt.y = 40;
//            txt.label_txt.text = "Room Name";
//            addChild(txt);
        }

        private function onClick(e:MouseEvent):void {
            if (_input.text != "") {
                _roomName = _input.text;
                dispatchEvent(new Event(OK));
            }
        }

        public function get roomName():String {
            return _roomName;
        }

    }

}
