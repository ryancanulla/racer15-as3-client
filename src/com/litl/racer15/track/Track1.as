package com.litl.racer15.track
{
    import flash.display.Bitmap;
    import flash.external.ExternalInterface;

    public class Track1 extends TrackBase implements ITrack
    {

        [Embed(source="../assets/track-one.png")]
        protected var TrackClass:Class;

        public function Track1() {

            super();
            create(TrackClass);
        }
    }
}
