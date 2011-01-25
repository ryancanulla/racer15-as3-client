package com.litl.racer15.gameobjects
{
    import flash.display.Bitmap;
    import flash.display.Sprite;

    public class Car extends Sprite
    {
        [Embed(source="../assets/cars/red-car.png")]
        private var CarClass:Class;
        private var car:Bitmap;

        public function Car() {
            car = new CarClass();
            car.smoothing = true;
            car.scaleX = .40;
            car.scaleY = .40;
            car.x -= car.width * .4;
            car.y -= car.height * .5;
            addChild(car);
        }
    }
}
