package com.litl.utils
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.text.TextField;

    /**
     * This class is used to show an approximation of the current frame rate.
     */
    public class FrameRateCounter extends MovieClip
    {
        private var times:Array;
        private var lastFrameTime:Date;
        private var totalTimesInAverage:int;
        private var textField:TextField;
        private var frameRate:int;

        /**
         * Creates a new instance of the FrameRateCounter class.
         */
        public function FrameRateCounter() {
            textField = new TextField();
            textField.selectable = false;
            textField.mouseEnabled = false;
            addChild(textField);
            totalTimesInAverage = 30;
            times = new Array();
            lastFrameTime = new Date();
            addEventListener(Event.ENTER_FRAME, run);
        }

        /**
         * Returns the latest frame rate average.
         * @return The latest frame rate average.
         */
        public function getFrameRate():int {
            return frameRate;
        }

        /**
         * Does the frame-based logic.
         * @param	Event.
         * @private
         */
        private function run(e:Event):void {
            var now:Date = new Date();
            var frameTime:Number = now.valueOf() - lastFrameTime.valueOf();
            lastFrameTime = now;
            //
            times.unshift(frameTime);

            if (times.length > totalTimesInAverage) {
                times.pop();
            }
            //average
            var totalTime:Number = 0;

            for (var i:int = 0; i < times.length; ++i) {
                totalTime += times[i];
            }
            var avg:Number = totalTime / times.length;
            var fps:int = Math.round(1000 / avg);
            frameRate = fps;
            textField.text = "fps: " + fps;
        }

    }

}
