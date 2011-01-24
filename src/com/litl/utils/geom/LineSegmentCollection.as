package com.litl.utils.geom
{

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class LineSegmentCollection
    {

        private var _lineSegments:Array;

        public function LineSegmentCollection() {
            _lineSegments = [];
        }

        public function addLineSegment(ls:LineSegment):void {
            _lineSegments.push(ls);
        }

        public function get lineSegments():Array {
            return _lineSegments;
        }

    }

}
