package com.litl.racer15.player
{
    import com.electrotank.electroserver5.api.EsObject;
    import com.hurlant.crypto.symmetric.NullPad;
    import com.litl.racer15.PluginConstants;
    import com.litl.racer15.gameobjects.Car;
    import com.litl.racer15.helpers.keyboard.KeyManager;
    import com.litl.racer15.helpers.movement.CollisionManager;
    import com.litl.racer15.helpers.movement.Heading;
    import com.litl.racer15.track.TrackBase;
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
        private var collisionManager:CollisionManager;
        private var _trackBounds:Bitmap;
        private var _car:Car;
        private var isNotMoving:Boolean;

        private var _converger:Converger;
        private var _direction:Number;
        private var _friction:Number;
        private var _speed:Number;
        private var _maxSpeed:Number;
        private var _vx:Number;
        private var _vy:Number;
        private var _destX:uint;
        private var _destY:uint;

        public function Player() {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            collisionManager = new CollisionManager();

            _car = new Car();
            addChild(car);
            isNotMoving = (_speed == 0);
            _direction = 0;
            _speed = 1;
            _maxSpeed = 25;
            _friction = .47;

        }

        private function onAddedToStage(e:Event):void {

            if (isMe) {
                keyManager = new KeyManager(this);
                stage.addChild(keyManager);
            }
        }

        public function run():void {
            if (isMe)
                checkDriverInput();

            checkForCollisions();

            _speed *= .97;

            vx = Math.cos(_direction * Math.PI / 180) * _speed;
            vy = Math.sin(_direction * Math.PI / 180) * _speed;

            //this.x -= (x - destX) * 0.2;
            //this.y -= (y - destY) * 0.2;

            this.x += vx;
            this.y += vy;
            car.rotation = _direction;
        }

        private function checkForCollisions():void {
            collisionManager.onTheTrack(this, _trackBounds);
        }

        public function setHeading(e:Heading):void {
//            var targetPoint:Point = new Point();
//            targetPoint.x = e.x;
//            targetPoint.y = e.y;
//
//            var dx:Number = targetPoint.x - x;
//            var dy:Number = targetPoint.y - y;
//
//            var newAngle:Number = Math.atan2(dy, dx);
//            var vx:Number = Math.cos(newAngle) * e.speed;
//            var vy:Number = Math.sin(newAngle) * e.speed;
//

            x = e.x;
            y = e.y;
            _speed = e.speed;
            _direction = e.angle;
            _time = e.time;
        }

        private function checkDriverInput():void {
            // calculate steering
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

            // reset rotation if needed
            if (_direction < 0 || _direction > 360)
                _direction = 0;

            // manage acceleration
            if (keyManager.isAccelerating) {
                if (_speed < _maxSpeed)
                    _speed += 1;
            }

            // manage braking
            if (keyManager.isBraking) {
                if (_speed > (_maxSpeed * -.35))
                    _speed -= 1;
            }

        }

        public function collide(heading:Heading):void {
            _direction += heading.angle;
            _speed = heading.speed;

            var vx:Number = Math.cos(_direction * Math.PI / 180) * _speed;
            var vy:Number = Math.sin(_direction * Math.PI / 180) * _speed;

            this.x += vx;
            this.y += vy;
        }

        public function get esObject():EsObject {
            var esob:EsObject = new EsObject();

            esob.setNumber(PluginConstants.X, x);
            esob.setNumber(PluginConstants.Y, y);
            esob.setNumber(PluginConstants.SPEED, _speed);
            esob.setNumber(PluginConstants.ANGLE, _direction);
            esob.setNumber(PluginConstants.TIME, _time);
            esob.setString(PluginConstants.NAME, _name);

            return esob;
        }

        public function get heading():Heading {
            var heading:Heading = new Heading();
//            heading.x = x;
//            heading.y = y;
            heading.angle = _direction;
            heading.speed = _speed;

            return heading;
        }

        public function get speed():Number {
            return _speed;
        }

        public function set speed(value:Number):void {
            _speed = value;
        }

        public function get maxSpeed():Number {
            return _maxSpeed;
        }

        public function set maxSpeed(value:Number):void {
            _maxSpeed = value;
        }

        public function set trackBase(value:Bitmap):void {
            _trackBounds = value;
        }

        public function get car():Car {
            return _car;
        }

        public function get vx():Number {
            return _vx;
        }

        public function set vx(value:Number):void {
            _vx = value;
        }

        public function get vy():Number {
            return _vy;
        }

        public function set vy(value:Number):void {
            _vy = value;
        }

        public function get direction():Number {
            return _direction;
        }

        public function set direction(value:Number):void {
            _direction = value;
        }

        public function set destX(value:uint):void {
            _destX = value;
        }

        public function set destY(value:uint):void {
            _destY = value;
        }

    }

}
