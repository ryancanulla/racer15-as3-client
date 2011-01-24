package com.litl.utils.network.clock
{
    import com.electrotank.electroserver5.ElectroServer;
    import com.electrotank.electroserver5.api.MessageType;
    import com.electrotank.electroserver5.api.PluginMessageEvent;
    import com.electrotank.electroserver5.api.PluginRequest;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    /**
     * This class uses a stream based time synchronization technique to sync the client and server clocks.
     */
    public class Clock extends EventDispatcher
    {

        /**
         * Event fired when the array of datapoints is full
         */
        public static const CLOCK_READY:String = "clockReady";

        //each latency data point
        private var _deltas:Array;

        //max number of deltas to keep track of
        private var _maxDeltas:Number;

        //the best computed offset to getTimer based on the information we have
        private var _syncTimeDelta:Number;

        //plugin request object
        private var _pr:PluginRequest;

        //electroserver reference
        private var _es:ElectroServer;

        //name of the time sync plugin
        private var _pluginName:String;

        //true if there is a request out
        private var _responsePending:Boolean;

        //time we sent the request
        private var _timeRequestSent:Number;

        //determined latency value
        private var _latency:int;

        //of the data set used, this is the biggest variation from the latency and the furthest value
        private var _latencyError:int;

        //how long to wait between pings
        private var _backgroundWaitTime:int;

        //timer used to make pings happen
        private var _backgroundTimer:Timer;

        //true if we are in the initial flurry of pings
        private var _bursting:Boolean;

        private var _lockedInServerTime:Boolean;

        /**
         * Creates a new instance of the ServerClock class.
         */
        public function Clock(es:ElectroServer, pluginName:String) {

            _es = es;
            _pluginName = pluginName;

            _pr = new PluginRequest();
            _pr.pluginName = _pluginName;

            _maxDeltas = 10;

        }

        /**
         * Starts the process of determining the server clock time
         * @param	How long to wait in between pings. If -1, then no pings are sent after the time is determined
         * @param	If true, the pings are sent as fast as possible until the initial latency is found, then it slows
         */
        public function start(pingDelay:int = -1, burst:Boolean = true):void {
            if (pingDelay != -1) {
                _backgroundTimer = new Timer(pingDelay);
                _backgroundTimer.addEventListener(TimerEvent.TIMER, onTimer);
                _backgroundTimer.start();
            }

            _deltas = [];

            _lockedInServerTime = false;

            _responsePending = false;

            _es.engine.addEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);

            _bursting = burst;
            requestServerTime();
        }

        /**
         * Stop gathering data
         */
        public function stop():void {
            _es.engine.removeEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);

            if (_backgroundTimer != null) {
                _backgroundTimer.stop();
                _backgroundTimer.removeEventListener(TimerEvent.TIMER, onTimer);
                _backgroundTimer = null;
            }
        }

        private function onTimer(e:TimerEvent):void {
            if (!_responsePending && !_bursting) {
                requestServerTime();
            }
        }

        private function requestServerTime():void {
            if (!_responsePending) {
                _es.engine.send(_pr);
                _responsePending = true;
                _timeRequestSent = getTimer();
            }
        }

        public function onPluginMessageEvent(e:PluginMessageEvent):void {
            if (e.pluginName == _pluginName) {
                _responsePending = false;

                var serverTimeStamp:Number = Number(e.parameters.getString("tm"));
                addTimeDelta(_timeRequestSent, getTimer(), serverTimeStamp);

                if (_bursting) {
                    if (_deltas.length == _maxDeltas) {
                        _bursting = false;
                        dispatchEvent(new Event(CLOCK_READY));
                    }
                    requestServerTime();
                }
            }
        }

        /**
         * Gets the current server time as best approximated by the algorithm used.
         * @return The server time.
         */
        public function getServerTime():Number {
            var now:Number = getTimer();
            return now + _syncTimeDelta;
        }

        /**
         * Adds information to this class so it can properly converge on a more precise idea of the actual server time.
         * @param	Time the client sent the request (in ms)
         * @param	Time the client received the response (in ms)
         * @param	Time the server sent the response (in ms)
         */
        public function addTimeDelta(clientSendTime:Number, clientReceiveTime:Number, serverTime:Number):void {

            //guess the latency
            var latency:Number = (clientReceiveTime - clientSendTime) / 2;

            var clientServerDelta:Number = serverTime - clientReceiveTime;
            var timeSyncDelta:Number = clientServerDelta + latency;
            var delta:TimeDelta = new TimeDelta(latency, timeSyncDelta);
            _deltas.push(delta);

            if (_deltas.length > _maxDeltas) {
                _deltas.shift();
            }
            recalculate();
        }

        /**
         * Recalculates the best timeSyncDelta based on the most recent information
         */
        private function recalculate():void {
            //grab a copy of the deltas array
            var tmp_deltas:Array = _deltas.slice(0);

            //sort them lowest to highest
            tmp_deltas.sort(compare);

            //find the median value
            var medianLatency:Number = determineMedian(tmp_deltas);

            //get rid of any latencies that fall outside a threshold
            pruneOutliers(tmp_deltas, medianLatency, 1.5);

            _latency = determineAverageLatency(tmp_deltas);

            if (!_lockedInServerTime) {

                //average the remaining time deltas
                var avgValue:Number = determineAverage(tmp_deltas);

                //store the result
                _syncTimeDelta = Math.round(avgValue);

                _lockedInServerTime = _deltas.length == _maxDeltas;
            }
        }

        /**
         * Determines the average timeSyncDelta based on values within the acceptable range
         * @param	Array of Time_deltas to be used
         * @return Average timeSyncDelta
         */
        private function determineAverage(arr:Array):Number {
            var total:Number = 0;

            for (var i:Number = 0; i < arr.length; ++i) {
                var td:TimeDelta = arr[i];
                total += td.timeSyncDelta;
            }
            return total / arr.length;
        }

        private function determineAverageLatency(arr:Array):Number {
            var total:Number = 0;

            for (var i:Number = 0; i < arr.length; ++i) {
                var td:TimeDelta = arr[i];
                total += td.latency;
            }

            var lat:Number = total / arr.length;

            _latencyError = Math.abs(TimeDelta(arr[arr.length - 1]).latency - lat);

            return lat;
        }

        /**
         * Removes the values that are more than 1.5 X the median. The idea is that if it is outside 1.5 X the median then it was probably a TCP retransmit and so it should be ignored.
         * @param	Array of Time_deltas to prune
         * @param	Median value
         * @param	Threshold multiplier of median value
         */
        private function pruneOutliers(arr:Array, median:Number, threshold:Number):void {
            var maxValue:Number = median * threshold;

            for (var i:Number = arr.length - 1; i >= 0; --i) {
                var td:TimeDelta = arr[i];

                if (td.latency > maxValue) {
                    arr.splice(i, 1);
                }
                else {
                    //we can break out of the loop because they are already sorted in order, if we find one that isn't too high then we are done
                    break;
                }
            }
        }

        /**
         * Determines the median latency value.
         * @param	Array of Time_deltas to use.
         * @return Median value.
         */
        private function determineMedian(arr:Array):Number {
            var ind:Number;

            if (arr.length % 2 == 0) { //even
                ind = arr.length / 2 - 1;
                return (arr[ind].latency + arr[ind + 1].latency) / 2;
            }
            else { //odd
                ind = Math.floor(arr.length / 2);
                return arr[ind].latency;
            }
        }

        /**
         * Function used by Array.sort to sort an array from lowest to highest based on latency values.
         * @param	TimeDelta
         * @param	TimeDelta
         * @return -1, 0, or 1
         */
        private function compare(a:TimeDelta, b:TimeDelta):Number {
            if (a.latency < b.latency) {
                return -1;
            }
            else if (a.latency > b.latency) {
                return 1;
            }
            else {
                return 0;
            }
        }

        /**
         * The best approximation of the time on the server
         */
        public function get time():Number {
            var now:Number = getTimer();
            return now + _syncTimeDelta;
        }

        public function get latency():int {
            return _latency;
        }

        public function get latencyError():int {
            return _latencyError;
        }

        public function get maxDeltas():Number {
            return _maxDeltas;
        }

        public function set maxDeltas(value:Number):void {
            _maxDeltas = value;
        }
    }

}
