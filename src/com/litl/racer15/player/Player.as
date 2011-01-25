package com.litl.racer15.player
{
    import com.electrotank.electroserver5.api.EsObject;
    import com.hurlant.crypto.symmetric.NullPad;
    import com.litl.racer15.PluginConstants;
    import com.litl.racer15.gameobjects.CarObject;
    import com.litl.racer15.helpers.keyboard.KeyManager;
    import com.litl.racer15.player.movement.Heading;
    import com.litl.utils.NumberUtil;
    import com.litl.utils.network.clock.Clock;
    import com.litl.utils.network.movement.Converger;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Point;

    public class Player extends PlayerBase
    {
        private var keyManager:KeyManager;
        private var car:CarObject;
        private var isNotMoving:Boolean;

        private var _converger:Converger;
        private var _direction:Number;
        private var _friction:Number;
        private var _speed:Number;
        private var _maxSpeed:Number;
        private var _time:Number;

        public function Player() {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            car = new CarObject();
            addChild(car);

            isNotMoving = (_speed == 0);

            _direction = 0;
            _speed = 1;
            _maxSpeed = 15;
            _friction = .87;
        }

        private function onAddedToStage(e:Event):void {
            keyManager = new KeyManager(this);
            stage.addChild(keyManager);
        }

        public function run():void {
            checkDriverInput();

            _speed *= .97;

            var vx:Number = Math.cos(_direction * Math.PI / 180) * _speed;
            var vy:Number = Math.sin(_direction * Math.PI / 180) * _speed;

            x += vx;
            y += vy;

            car.rotation = _direction;
        }

        private function checkDriverInput():void {
            trace(_direction);

            if (keyManager.isTurningLeft) {
                _direction -= keyManager.turnStrength;

                if (_direction < 0)
                    _direction = 360;
            }
            else if (keyManager.isTurningRight) {
                _direction += keyManager.turnStrength;

                if (_direction > 360)
                    _direction = 0;
            }

            if (_direction < 0 || _direction > 360)
                _direction = 0;

            if (keyManager.isAccelerating) {
                if (_speed < _maxSpeed)
                    _speed += 1;
            }

            if (keyManager.isBraking) {
                if (_speed > (_maxSpeed * -.35))
                    _speed -= 1;
            }

        }

        public function get time():Number {
            return _time;
        }

        public function set time(e:Number):void {
            _time = e;
        }

        public function get heading():EsObject {
            var esob:EsObject = new EsObject();

            esob.setNumber(PluginConstants.X, x);
            esob.setNumber(PluginConstants.Y, y);
            esob.setNumber(PluginConstants.SPEED, _speed);
            esob.setNumber(PluginConstants.ANGLE, _direction);
            esob.setNumber(PluginConstants.TIME, _time);
            esob.setString(PluginConstants.NAME, _name);

            return esob;
        }

        public function setHeading(e:Heading):void {
            x = e.x;
            y = e.y;
            _speed = e.speed;
            _direction = e.angle;
            _time = e.time;
        }

    }

}
