package com.litl.utils.geom
{
    import flash.geom.Point;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class IntersectionDetector
    {

        public static function segmentCollectionTest(seg:LineSegment, col:LineSegmentCollection, point:Point = null):IntersectionTestResult {
            var res:IntersectionTestResult = new IntersectionTestResult();

            var collisions:Array = [];

            //find all intersections
            for (var i:int = 0; i < col.lineSegments.length; ++i) {
                var result:IntersectionTestResult = segementSegmentTest(seg, col.lineSegments[i]);

                if (result.intersecting) {
                    res.intersecting = true;

                    if (point != null) {
                        //in thise case, store the result because we need to find the closest intersection
                        collisions.push(result);
                    }
                    else {
                        //in this case just break the loop, we found what we want
                        res = result;
                        break;
                    }
                }
            }

            if (point != null) {
                //find closest intersection to point
                var closest:Point;
                var shortest:Number = Number.MAX_VALUE;

                for (i = 0; i < collisions.length; ++i) {
                    var res1:IntersectionTestResult = collisions[i];
                    var dis:Number = getDistance(point, res1.point);

                    if (dis < shortest) {
                        closest = res1.point;
                        shortest = dis;
                    }
                }

                res.point = closest;
            }

            return res;
        }

        private static function getDistance(p1:Point, p2:Point):Number {
            return Math.sqrt(Math.pow(p1.y - p2.y, 2) + Math.pow(p1.x - p2.x, 2));
        }

        public static function segementSegmentTest(segment1:LineSegment, segment2:LineSegment):IntersectionTestResult {
            var res:IntersectionTestResult = new IntersectionTestResult();

            var x:Number = (segment2.yIntercept - segment1.yIntercept) / (segment1.slope - segment2.slope);
            var y:Number = segment1.slope * x + segment1.yIntercept;

            if (Math.abs(segment1.slope) == Number.POSITIVE_INFINITY) {
                x = segment1.point1.x;
                y = segment2.slope * x + segment2.yIntercept;
            }
            else if (Math.abs(segment2.slope) == Number.POSITIVE_INFINITY) {
                x = segment2.point1.x;
                y = segment1.slope * x + segment1.yIntercept;
            }

            //TODO: doesn't check if both lines are vertical AND overlapping

            var within_bounds1:Boolean = false;
            var within_bounds2:Boolean = false;

            if (((x >= segment1.point1.x && x <= segment1.point2.x) || (x <= segment1.point1.x && x >= segment1.point2.x)) && ((y >= segment1.point1.y && y <= segment1.point2.y) || (y <= segment1.point1.y && y >= segment1.point2.y))) {
                within_bounds1 = true;
            }

            if (((x >= segment2.point1.x && x <= segment2.point2.x) || (x <= segment2.point1.x && x >= segment2.point2.x)) && ((y >= segment2.point1.y && y <= segment2.point2.y) || (y <= segment2.point1.y && y >= segment2.point2.y))) {
                within_bounds2 = true;
            }

            res.intersecting = within_bounds1 && within_bounds2;
            res.point = new Point(x, y);

            if (isNaN(res.point.y)) {
                res.point.y = segment1.point1.y;
            }

            return res;
        }

    }

}
