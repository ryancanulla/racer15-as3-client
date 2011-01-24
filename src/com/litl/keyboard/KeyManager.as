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
        }

    }
}
