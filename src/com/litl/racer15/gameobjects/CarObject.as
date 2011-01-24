package com.litl.racer15.gameobjects
{
    import flash.display.Bitmap;
    import flash.display.Sprite;

    public class CarObject extends Sprite
    {
        [Embed(source="../assets/cars/red-car.png")]
        private var CarClass:Class;
        private var car:Bitmap;

        public function CarObject() {
            car = new CarClass();
            car.smoothing = true;
            car.x -= car.width / 2;
            car.y -= car.height / 2;
            addChild(car);
        }
    }
}
