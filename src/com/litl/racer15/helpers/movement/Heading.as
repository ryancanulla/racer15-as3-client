package com.litl.racer15.helpers.movement
{

    public class Heading
    {
        private var _x:Number;
        private var _y:Number;
        private var _angle:Number;
        private var _speed:Number;
        private var _time:Number;
        private var _isAccelerating:Boolean;

        public function Heading() {
            _x = 0;
            _y = 0;
            _speed = 0;
            this.angle = 0;
            _time = 0;
            _isAccelerating = false;
        }

        public function get x():Number {
            return _x;
        }

        public function set x(value:Number):void {
            _x = value;
        }

        public function get y():Number {
            return _y;
        }

        public function set y(value:Number):void {
            _y = value;
        }

        public function get angle():Number {
            return _angle;
        }

        public function set angle(value:Number):void {
            _angle = value;
        }

        public function get speed():Number {
            return _speed;
        }

        public function set speed(value:Number):void {
            _speed = value;
        }

        public function get time():Number {
            return _time;
        }

        public function set time(value:Number):void {
            _time = value;
        }

        public function get isAccelerating():Boolean {
            return _isAccelerating;
        }

        public function set isAccelerating(value:Boolean):void {
            _isAccelerating = value;
        }

    }
}
