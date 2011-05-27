package com.litl.racer15.gameobjects
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;

    public class Car extends Sprite
    {
        [Embed(source="../assets/cars/red-car.png")]
        private var CarClass:Class;
        private var _car:Bitmap;
        private var _hitTests:Array;

        public function Car() {
            _car = new CarClass();
            _car.smoothing = true;
//            _car.scaleX = .75;
//            _car.scaleY = .75;
            _car.x -= _car.width * .5;
            _car.y -= _car.height * .5;
            addChild(_car);

            _hitTests = new Array();
            var backLeft:Point = this.localToGlobal(new Point(_car.x, _car.y));
            var backRight:Point = this.localToGlobal(new Point(_car.x, (_car.y + _car.height)));
            var frontLeft:Point = this.localToGlobal(new Point((_car.x + _car.width), _car.y));
            var frontRight:Point = this.localToGlobal(new Point((_car.x + _car.width), (_car.y + _car.height)));

            _hitTests.push(backLeft);
            _hitTests.push(backRight);
            _hitTests.push(frontLeft);
            _hitTests.push(frontRight);
        }

        public function data():BitmapData {
            return _car.bitmapData;
        }

        public function get hitTests():Array {
            return _hitTests;
        }

    }
}
