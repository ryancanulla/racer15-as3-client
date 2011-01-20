package com.litl.racer15.player
{

    //import com.gamebook.dig.elements.Trowel;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class Player
    {

        private var _score:int;
        private var _name:String;
        private var _isMe:Boolean;

        private var _car:Car;

        public function Player() {
            _isMe = false;
            _car = new Car();
        }

        public function get score():int {
            return _score;
        }

        public function set score(value:int):void {
            _score = value;
        }

        public function get name():String {
            return _name;
        }

        public function set name(value:String):void {
            _name = value;
        }

        public function get isMe():Boolean {
            return _isMe;
        }

        public function set isMe(value:Boolean):void {
            _isMe = value;
        }

        public function get car():Car {
            return _car;
        }
    }

}
