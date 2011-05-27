package com.litl.racer15.helpers.movement
{
    import com.hurlant.crypto.symmetric.NullPad;
    import com.litl.racer15.gameobjects.Car;
    import com.litl.racer15.player.Player;
    import com.litl.racer15.track.ITrack;
    import com.litl.racer15.track.TrackBase;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Point;

    public class CollisionManager
    {
        public function CollisionManager() {
        }

        public function onTheTrack(player:Player, track:Bitmap):void {
//            trace(track.bitmapData.getPixel(player.x, player.y));

            if (track.bitmapData.getPixel(player.x, player.y) == 0) {
                player.maxSpeed = 25;
            }
            else if (track.bitmapData.getPixel(player.x, player.y) == 15985689) {
                player.speed *= -1.5;
            }

            else {
                player.maxSpeed = 3;
            }
        }

        public function checkCollision(player1:Player, player2:Player):void {
            var object1:BitmapData = player1.car.data();
            var object2:BitmapData = player2.car.data();
            var hit:Boolean = object1.hitTest(new Point(player1.x, player1.y), 255, object2,
                                              new Point(player2.x, player2.y), 255);

//            var pixelValue:uint = object1.getPixel32(myX, myY);
//            var alphaValue:uint = pixelValue >> 24 & 0xFF;
//            trace(alphaValue);

            if (hit)
                collide(player1, player2);

        }

        private function collide(player1:Player, player2:Player):void {
            var mass:Number = 1;
            var distX:Number = player2.x - player1.x;
            var distY:Number = player2.y - player1.y;
            var angle:Number = Math.atan2(distY, distX);
            var sin:Number = Math.sin(angle);
            var cos:Number = Math.cos(angle);

            // rotate player 1 position
            var x0:Number = 0;
            var y0:Number = 0;

            // rotate player 2 position
            var x1:Number = distX * cos + distY * sin;
            var y1:Number = distY * cos - distX * sin;

            // rotate velocities
            var vx0:Number = player1.vx * cos + player1.vy * sin;
            var vy0:Number = player1.vy * cos - player1.vx * sin;

            var vx1:Number = player2.vx * cos + player2.vy * sin;
            var vy1:Number = player2.vy * cos - player2.vx * sin;

            // collision reaction
            var vxTotal:Number = vx0 - vx1;
            vx0 = ((mass - mass) * vx0 + 2 * mass * vx1) / (mass + mass);
            vx1 = vxTotal + vx0;

            // seperate them BEGINNER
            x0 += vx0;
            x1 += vx1;

            // seperate them ADVANCED
//            var absV:Number = Math.abs(vx0) + Math.abs(vx1);
//            var overlap:Number = (player1.width + player2.width)
//                - Math.abs(x0 - x1);
//
//            x0 += vx0 / absV * overlap;
//            x1 += vx1 / absV * overlap;

            // rotate positions back
            var x0Final:Number = x0 * cos - y0 * sin;
            var y0Final:Number = y0 * cos + x0 * sin;
            var x1Final:Number = x1 * cos - y1 * sin;
            var y1Final:Number = y1 * cos + x1 * sin;

            // adjust positions to actual screen positions
            player2.x = player1.x + x1Final;
            player2.y = player1.y + y1Final;
            player1.x = player1.x + x0Final;
            player1.y = player1.y + y0Final;

            // rotate the velocities back
            player1.vx = vx0 * cos - vy0 * sin;
            player1.vy = vy0 * cos + vx0 * sin;
            player2.vx = vx1 * cos - vy1 * sin;
            player2.vy = vy1 * cos + vx1 * sin;

            if (player1.speed > player2.speed) {
                player2.speed = player1.speed * .5;
            }
            else {
                player1.speed = player2.speed * .5;
            }
        }

        private function rotate(x:Number, y:Number, sin:Number, cos:Number, reverse:Boolean):Point {
            var result:Point = new Point();

            if (reverse) {
                result.x = x * cos + y * sin;
                result.y = y * cos - x * sin;
            }
            else {
                result.x = y * cos - y * sin;
                result.y = y * cos + x * sin;
            }
            return result;
        }
    }
}
