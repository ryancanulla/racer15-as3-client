package com.litl.utils.geom
{
    import flash.geom.Point;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class LineSegment
    {

        private var _point1:Point;
        private var _point2:Point;

        private var _slope:Number;

        private var _yIntercept:Number;

        public function LineSegment(p1:Point, p2:Point) {
            _point1 = p1;
            _point2 = p2;

            _slope = (_point2.y - _point1.y) / (_point2.x - _point1.x);

            //y = m*x+b  ---> b = y-m*x
            _yIntercept = _point1.y - _slope * _point1.x;
        }

        public function get point1():Point {
            return _point1;
        }

        public function get point2():Point {
            return _point2;
        }

        public function get slope():Number {
            return _slope;
        }

        public function get yIntercept():Number {
            return _yIntercept;
        }

    }

}
