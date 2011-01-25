package com.litl.racer15.track
{
    import flash.display.Bitmap;
    import flash.display.Sprite;

    public class TrackBase extends Sprite
    {
        protected var _track:Bitmap;

        public function TrackBase() {
            super();
        }

        protected function create(e:Class):void {
            _track = new e as Bitmap;
            _track.smoothing = true;
            _track.scaleX = .5;
            _track.scaleY = .5;
            addChild(_track);
        }

        protected function destroy():void {
            removeChild(_track);
            _track = null;
        }

    }
}
