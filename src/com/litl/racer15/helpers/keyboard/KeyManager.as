package com.litl.racer15.helpers.keyboard
{
    import com.litl.racer15.player.Player;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    public class KeyManager extends Sprite
    {
        private var _car:Player;
        private var _accelerate:Boolean;
        private var _brake:Boolean;
        private var _turningLeft:Boolean;
        private var _turningRight:Boolean;
        private var _turnStrength:Number;

        public function KeyManager(car:Player) {
            _car = car;
            _turnStrength = 1;
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

        private function onKeyDown(e:KeyboardEvent):void {
            switch (e.keyCode) {
                case 37: // TURN LEFT
                    _turningLeft = true;
                    _turnStrength += 2;
                    break;
                case 38: // ACCELERATE
                    _accelerate = true;
                    break;
                case 39: // TURN RIGHT
                    _turningRight = true;
                    _turnStrength += 2;
                    break;
                case 40: // BRAKE
                    _brake = true;
                    break;
            }
        }

        private function onKeyUp(e:KeyboardEvent):void {
            switch (e.keyCode) {
                case 37: // STOP TURN LEFT
                    _turningLeft = false;
                    _turnStrength = 1;
                    break;
                case 38: // STOP ACCELERATE
                    _accelerate = false;
                    break;
                case 39: // STOP TURN RIGHT
                    _turningRight = false;
                    _turnStrength = 1;
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
            return _turningLeft;
        }

        public function get isTurningRight():Boolean {
            return _turningRight;
        }

        public function get turnStrength():Number {
            return _turnStrength;
        }

    }
}
