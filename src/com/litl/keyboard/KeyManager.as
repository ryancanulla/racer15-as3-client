package com.litl.keyboard
{
    import com.litl.racer15.gameobjects.Car;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    public class KeyManager extends Sprite
    {
        private var _car:Car;
        private var _accelerate:Boolean;
        private var _brake:Boolean;
        private var _left:Boolean;
        private var _right:Boolean;

        public function KeyManager(car:Car) {
            _car = car;
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

        private function onKeyDown(e:KeyboardEvent):void {
            switch (e.keyCode) {
                case 37: // TURN LEFT
                    _car.turnLeft();
                    break;
                case 38: // ACCELERATE
                    _accelerate = true;
                    break;
                case 39: // TURN RIGHT
                    _car.turnRight();
                    break;
                case 40: // BRAKE
                    _brake = true;
                    break;
            }
        }

        private function onKeyUp(e:KeyboardEvent):void {
            switch (e.keyCode) {
                case 37: // STOP TURN LEFT
                    _left = false;
                    break;
                case 38: // STOP ACCELERATE
                    _accelerate = false;
                    break;
                case 39: // STOP TURN RIGHT
                    _right = false;
                    break;
                case 40: // STOP BRAKE
                    _brake = false;
                    break;
            }
        }

        public function get isAccelerating():Boolean {
            return _accelerate;
        }

        public function get isBraking():Boolean {
            return _brake;
        }

        public function get isTurningLeft():Boolean {
            return _left;
        }

        public function get isTurningRight():Boolean {
            return _right;
        }

    }
}
