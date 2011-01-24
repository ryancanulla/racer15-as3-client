package com.litl.utils.network.clock
{

    /**
     * This class is used to store one round trip of information used in an attempt to sync the server and client clocks.
     */
    public class TimeDelta
    {
        private var _latency:Number;
        private var _timeSyncDelta:Number;

        /**
         * Creates a new instance of the TimeDelta class.
         * @param	Latency value (1/2 the round trip time)
         * @param	TimeSyncDelta
         */
        public function TimeDelta(latency:Number, timeSyncDelta:Number) {
            _latency = latency;
            _timeSyncDelta = timeSyncDelta;
        }

        public function get latency():Number {
            return _latency;
        }

        public function get timeSyncDelta():Number {
            return _timeSyncDelta;
        }
    }

}
