package com.litl.utils.geom
{
    import flash.geom.Point;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class IntersectionTestResult
    {

        private var _intersecting:Boolean = false;
        private var _point:Point;

        public function get intersecting():Boolean {
            return _intersecting;
        }

        public function set intersecting(value:Boolean):void {
            _intersecting = value;
        }

        public function get point():Point {
            return _point;
        }

        public function set point(value:Point):void {
            _point = value;
        }

    }

}
