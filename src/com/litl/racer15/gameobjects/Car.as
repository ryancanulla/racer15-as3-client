package com.litl.racer15.gameobjects
{
    import com.hurlant.crypto.symmetric.NullPad;
    import com.litl.keyboard.KeyManager;
    import com.litl.racer15.player.Player;
    import com.litl.utils.NumberUtil;
    import com.litl.utils.network.clock.Clock;
    import com.litl.utils.network.movement.Converger;
    import com.litl.utils.network.movement.Heading;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Point;

    public class Car extends Player
    {
        private var keyManager:KeyManager;

        private var car:CarObject;

        private var _converger:Converger;
        private var _direction:Number;
        private var _friction:Number;
        private var _speed:Number;
        private var _maxSpeed;
        private var isNotMoving:Boolean;

        public function Car() {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            car = new CarObject();
            addChild(car);

            isNotMoving = (_speed == 0);

            _direction = 0;
            _speed = 1;
            _maxSpeed = 15;
            _friction = .97;
        }

        private function onAddedToStage(e:Event):void {
            keyManager = new KeyManager(this);
            stage.addChild(keyManager);
        }

        public function run():void {
            trace(isNotMoving);

            checkDriverInput();

            _speed *= .97;

            var vx:Number = Math.cos(_direction * Math.PI / 180) * _speed;
            var vy:Number = Math.sin(_direction * Math.PI / 180) * _speed;

            x += vx;
            y += vy;

            car.rotation = _direction;

        }

        private function checkDriverInput():void {
            if (keyManager.isAccelerating) {
                if (_speed < _maxSpeed)
                    _speed += 1;
            }

            if (keyManager.isBraking) {
                if (_speed > (_maxSpeed * -1))
                    _speed -= 1;
            }

        }

        public function turnLeft():void {
            var rotation:Number = 10

            if (_direction < 0)
                _direction = 360;

            _direction -= rotation;
        }

        public function turnRight():void {
            var rotation:Number = 10

            if (_direction > 360)
                _direction = 0;

            _direction += rotation;
        }

    }

}
