package com.litl.racer15.helpers.camera
{
    import com.litl.racer15.player.Player;
    import com.litl.racer15.track.TrackBase;

    import flash.display.Sprite;
    import flash.events.Event;

    public class CameraBase extends Sprite
    {
        protected var _track:TrackBase;

        protected var _targetX:Number;
        protected var _targetY:Number;
        protected var _targetPlayer:Player;

        public function CameraBase() {
            addEventListener(Event.ADDED_TO_STAGE, move);
        }

        private function move(e:Event):void {
            _track.x += (stage.stageWidth / 2) - (_targetPlayer.x + _track.x);
            _track.y += (stage.stageHeight / 2) - (_targetPlayer.y + _track.y);
        }

        public function follow(e:Player):void {
            _targetPlayer = e;
        }

        public function moveCamera():void {
            var speed:Number = Math.abs(_targetPlayer.speed);
            var dx:Number = (stage.stageWidth / 2) - (_targetPlayer.x + _track.x);
            var dy:Number = (stage.stageHeight / 2) - (_targetPlayer.y + _track.y);
            var angle:Number = Math.atan2(dy, dx);
            var vx:Number = Math.cos(angle) * speed;
            var vy:Number = Math.sin(angle) * speed;
            var dist:Number = Math.sqrt(dx * dx + dy * dy);

            if (dist > 100) {
                _track.x += vx;
                _track.y += vy;
            }
        }

        public function set track(e:TrackBase):void {
            _track = e;
        }
    }
}
