package com.litl.utils.network.movement
{
    import com.litl.utils.NumberUtil;
    import com.litl.utils.network.clock.Clock;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class Converger
    {

        private var _interceptor:Heading; //smoothed vector heading
        private var _course:Heading; //real vector heading
        private var _view:Heading; //what the outside uses for rendering
        private var _clock:Clock;
        private var _mode:String;
        private var _debug:Boolean;
        private var _interceptTime:Number;
        private var _interceptTimeMultiplier:int;
        private var _maxDurationInterceptTime:Number;

        private var INTERCEPTING:String = "intercepting";
        private var MATCHING:String = "matching";

        public function Converger() {
            _interceptor = new Heading();
            _course = new Heading();
            _view = new Heading();
            _mode = MATCHING;
            _debug = false;
            _interceptTimeMultiplier = 7;
            _maxDurationInterceptTime = 800;
        }

        /**
         * Injects a new heading that should be converged on
         * @param	heading
         */
        public function intercept(heading:Heading):void {
            run();
            _mode = INTERCEPTING

            //copy the new properties into course heading
            _course.x = heading.x;
            _course.y = heading.y;
            _course.speed = heading.speed;
            _course.angle = heading.angle;
            _course.time = heading.time;
            _course.endSpeed = heading.endSpeed;
            _course.accelTime = heading.accelTime;
            _course.targetTime = heading.targetTime;
            _course.targetX = heading.targetX;
            _course.targetY = heading.targetY;

            //
            if (_course.isAccelerating) {
                _course.accel = (_course.endSpeed - _course.speed) / _course.accelTime;
            }

            createInterceptor();
        }

        private function createInterceptor():void {
            //update the interceptor to start on a new course
            _interceptor.x = _view.x;
            _interceptor.y = _view.y;
            _interceptor.time = _clock.time;

            //how long ago was this new vector born?
            var age:Number = _clock.time - _course.time;

            //how long from now to give the interceptor time to converge on the course
            var scheduled:Number = age * _interceptTimeMultiplier;

            scheduled = Math.min(scheduled, _maxDurationInterceptTime);

            //in absolute time, this is when the convergence is complete
            var when:Number = _clock.time + scheduled;

            //the x/y position where the two paths intersect
            var targetx:Number = _course.x + _course.xspeed * (when - _course.time);
            var targety:Number = _course.y + _course.yspeed * (when - _course.time);

            //if the new vector has acceleration
            if (_course.isAccelerating) {

                //find x/y for when it is done accelerating
                var tx:Number = _course.x + _course.xspeed * _course.accelTime + (1 / 2) * _course.xaccel * Math.pow(_course.accelTime, 2);
                var ty:Number = _course.y + _course.yspeed * _course.accelTime + (1 / 2) * _course.yaccel * Math.pow(_course.accelTime, 2);

                //update the target intersection point to be when the acceleration is done
                targetx = tx;
                targety = ty;

                //how long from now until acceleration is done
                var timeDelta:Number = _course.time + _course.accelTime - _clock.time;

                //update the relative time variable saying how long from to to have the intersection complete
                scheduled = timeDelta;

                //in absolute time, when will the intersection be complete
                when = _clock.time + scheduled;

            }

            //distance between the current interceptor position and where the intersection will take place
            var dis:Number = Math.sqrt(Math.pow(targetx - _interceptor.x, 2) + Math.pow(targety - _interceptor.y, 2));

            //speed that must occur to achieve this
            var speed:Number = dis / scheduled;

            //angle of the interseptor
            var angle:Number = Math.atan2(targety - _interceptor.y, targetx - _interceptor.x) * 180 / Math.PI;

            //update properties on the interceptor
            _interceptor.speed = speed;
            _interceptor.angle = angle;

            _interceptTime = when;

        }

        public function run():void {
            if (_course.targetTime > -1 && _clock.time >= _course.targetTime) {
                _course.speed = 0;
                _course.targetTime = -1;
                _course.x = _course.targetX;
                _course.y = _course.targetY;
            }

            //figure out where it should render
            switch (_mode) {
                case INTERCEPTING:
                    if (_clock.time > _interceptTime) {
                        _mode = MATCHING;
                    }
                    updateView(_interceptor);
                    break;
                case MATCHING:
                    updateCourse();
                    updateView(_course);
                    break;
            }
        }

        private function updateCourse():void {
            //if the course is accelerating and it should be done accelerating
            if (_course.isAccelerating && _clock.time >= _course.time + _course.accelTime) {
                //update the course to a position of where it would be at the moment acceleration is done
                _course.x = _course.x + _course.xspeed * _course.accelTime + (1 / 2) * _course.xaccel * Math.pow(_course.accelTime, 2);
                _course.y = _course.y + _course.yspeed * _course.accelTime + (1 / 2) * _course.yaccel * Math.pow(_course.accelTime, 2);
                _course.time = _course.time + _course.accelTime;

                //reset acceleration values
                _course.accelTime = 0;
                _course.accel = 0;

                //give a new speed (the one is should have after acceleration)
                _course.speed = _course.endSpeed;

            }

        }

        private function updateView(heading:Heading):void {
            //amount of time since starting this heading
            var elapsed:Number = _clock.time - heading.time;

            //x, y position
            var x:Number = heading.x + heading.xspeed * elapsed + (1 / 2) * heading.xaccel * Math.pow(elapsed, 2);
            var y:Number = heading.y + heading.yspeed * elapsed + (1 / 2) * heading.yaccel * Math.pow(elapsed, 2);

            //value for easing rotation
            //TODO: replace with a better rotating algorithm
            var k:Number = .25;
            /*
            var angMov:Number = (heading.angle-_view.angle) * k;

            //need to check for this case or it may roate the wrong direction
            if (NumberUtil.isAngleBetween(_view.angle, 270, 90) && !NumberUtil.isAngleBetween(heading.angle, 180, 270)) {
                var ang1:Number = _view.angle > 270 ? _view.angle-360 : _view.angle;
                var ang2:Number = heading.angle > 270 ? heading.angle-360 : heading.angle;
                angMov = (ang2 - ang1) * k;
            }
            */

            var angMov:Number = NumberUtil.getRotationEaseAmount(heading.angle - _view.angle, k);

            var speed:Number = heading.speed;

            if (heading.isAccelerating) {
                speed += heading.accel * elapsed;
            }

            var angle:Number = _view.angle + angMov;

            //copy properties to the view heading
            _view.x = x;
            _view.y = y;
            _view.angle = angle;
            _view.speed = speed;
            _view.xspeed = heading.xspeed;
            _view.yspeed = heading.yspeed;

        }

        public function get interceptor():Heading {
            return _interceptor;
        }

        public function get course():Heading {
            return _course;
        }

        public function get clock():Clock {
            return _clock;
        }

        public function set clock(value:Clock):void {
            _clock = value;
            _course.time = _clock.time;
            _interceptor.time = _clock.time;
            _view.time = _clock.time;
        }

        public function get view():Heading {
            return _view;
        }

        public function get debug():Boolean {
            return _debug;
        }

        public function set debug(value:Boolean):void {
            _debug = value;
        }

        public function get interceptTimeMultiplier():int {
            return _interceptTimeMultiplier;
        }

        public function set interceptTimeMultiplier(value:int):void {
            _interceptTimeMultiplier = value;
        }

        public function get maxDurationInterceptTime():Number {
            return _maxDurationInterceptTime;
        }

        public function set maxDurationInterceptTime(value:Number):void {
            _maxDurationInterceptTime = value;
        }

    }

}
