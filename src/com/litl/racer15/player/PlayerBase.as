﻿package com.litl.racer15.player
{
    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;

    public class PlayerBase extends Sprite
    {
        protected var _rank:int;
        protected var _name:String;
        protected var _isMe:Boolean;

        public function PlayerBase() {
            _isMe = false;
        }

        public function get ranking():int {
            return _rank;
        }

        public function set ranking(value:int):void {
            _rank = value;
        }

        override public function get name():String {
            return _name;
        }

        override public function set name(value:String):void {
            _name = value;
        }

        public function get isMe():Boolean {
            return _isMe;
        }

        public function set isMe(value:Boolean):void {
            _isMe = value;
        }
    }

}