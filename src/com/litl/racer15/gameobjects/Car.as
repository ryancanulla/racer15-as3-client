package com.litl.racer15.gameobjects
{
    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;

    [Embed(source="../assets/cars/red-car.png")]
    public class Car extends Bitmap
    {
        private var _targetX:Number;
        private var _targetY:Number;

        public function Car() {
            _targetX = 0;
            _targetY = 0;
        }

        public function run():void {
            var k:Number = .15;
            var xm:Number = (_targetX - x) * k;
            var ym:Number = (_targetY - y) * k;
            x += xm;
            y += ym;
        }

        public function moveTo(tx:Number, ty:Number):void {
            _targetX = tx;
            _targetY = ty;
        }

    }

}
