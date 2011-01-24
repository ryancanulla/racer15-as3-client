package com.litl.utils.network.movement
{
    import com.litl.utils.NumberUtil;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class Heading
    {

        private var _x:Number;
        private var _y:Number;
        private var _angle:Number;
        private var _speed:Number;
        private var _time:Number;
        private var _cos:Number;
        private var _sin:Number;
        private var _xspeed:Number;
        private var _yspeed:Number;
        private var _accelTime:Number;
        private var _endSpeed:Number;
        private var _isAccelerating:Boolean;
        private var _accel:Number;
        private var _xaccel:Number;
        private var _yaccel:Number;
        private var _targetX:Number;
        private var _targetY:Number;
        private var _targetTime:Number;

        public function Heading() {
            _x = 0;
            _y = 0;
            _speed = 0;
            this.angle = 0;
            _time = 0;
            _accelTime = 0;
            _endSpeed = 0;
            _isAccelerating = false;
            _accel = 0;
            _xaccel = 0;
            _yaccel = 0;
            _targetX = 0;
            _targetY = 0;
            _targetTime = -1;
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

        /**
         * angle in degrees
         */
        public function set angle(value:Number):void {
            _angle = NumberUtil.clampDegrees(value);
            doAngleMath();
        }

        private function doAngleMath():void {
            _cos = Math.cos(_angle * Math.PI / 180);
            _sin = Math.sin(_angle * Math.PI / 180);
            _xspeed = _cos * _speed;
            _yspeed = _sin * _speed;
        }

        public function get speed():Number {
            return _speed;
        }

        public function set speed(value:Number):void {
            _speed = value;
            doAngleMath();
        }

        public function get time():Number {
            return _time;
        }

        public function set time(value:Number):void {
            _time = value;
        }

        public function get xspeed():Number {
            return _xspeed;
        }

        public function get yspeed():Number {
            return _yspeed;
        }

        public function set xspeed(value:Number):void {
            _xspeed = value;
        }

        public function set yspeed(value:Number):void {
            _yspeed = value;
        }

        public function get endSpeed():Number {
            return _endSpeed;
        }

        public function set endSpeed(value:Number):void {
            _endSpeed = value;
            accelTime = _accelTime;
        }

        public function get accelTime():Number {
            return _accelTime;
        }

        public function set accelTime(value:Number):void {
            _accelTime = value;

            _isAccelerating = _accelTime > 0;

            if (_isAccelerating) {
                accel = (endSpeed - speed) / _accelTime;
            }
            else {
                _xaccel = 0;
                _yaccel = 0;
            }
        }

        public function get isAccelerating():Boolean {
            return _isAccelerating;
        }

        public function get accel():Number {
            return _accel;
        }

        public function set accel(value:Number):void {
            _accel = value;
            _xaccel = _accel * _cos;
            _yaccel = _accel * _sin;
        }

        public function get xaccel():Number {
            return _xaccel;
        }

        public function get yaccel():Number {
            return _yaccel;
        }

        public function get targetX():Number {
            return _targetX;
        }

        public function set targetX(value:Number):void {
            _targetX = value;
        }

        public function get targetY():Number {
            return _targetY;
        }

        public function set targetY(value:Number):void {
            _targetY = value;
        }

        public function get targetTime():Number {
            return _targetTime;
        }

        public function set targetTime(value:Number):void {
            _targetTime = value;
        }

    }

}
