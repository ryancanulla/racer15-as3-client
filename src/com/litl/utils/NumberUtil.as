package com.litl.utils
{

    /**
     * This class contains useful number utilities.
     */
    public class NumberUtil
    {

        /**
         * This method takes in degrees and spits out radians.
         * @param	The degree value
         * @return The radian value
         */
        static public function degreesToRadians(degrees:Number):Number {
            return degrees * Math.PI / 180;
        }

        /**
         * This method takes and angle and an angle increment. It returns the index of the current angle while centering it. This is useful when determining which angle of an avatar to show.
         * @param	Angle of the avatar
         * @param	Angle increment
         * @return The index of the angles
         */
        static public function findAngleIndex(angle:Number, margin:Number):int {
            angle = clampDegrees(angle + margin / 2);
            var index:int = Math.floor(angle / margin);
            return index;
        }

        static public function getRotationEaseAmount(diff:Number, k:Number):Number {
            if (diff > 180) {
                diff = diff - 360;
            }
            else if (diff < -180) {
                diff = 360 + diff;
            }
            return diff * k;
        }

        /**
         * This method takes in radians and spits out degrees
         * @param	The radian value
         * @return The degree value
         */
        static public function radiansToDegrees(radians:Number):Number {
            return radians * 180 / Math.PI;
        }

        static public function isAngleBetween(angle:Number, angle1:Number, angle2:Number):Boolean {
            var isBetween:Boolean;
            angle = clampDegrees(angle);
            angle1 = clampDegrees(angle1);
            angle2 = clampDegrees(angle2);

            isBetween = angle >= angle1 && angle <= angle2;

            if (angle1 > 180 && angle2 < 180) {

                if (angle <= 360 && angle >= angle1) {
                    isBetween = true;
                }

                if (angle >= 0 && angle <= angle2) {
                    isBetween = true;
                }
            }

            return isBetween;
        }

        /**
         * This method takes an angle in desgrees (which is cylical, eg 720 is the same as 360) and brings it back into rand between 0 and 360
         * @param	Degree value
         * @return Clamped degree value
         */
        static public function clampDegrees(degrees:Number):Number {
            while (degrees < 0) {
                degrees += 360;
            }

            while (degrees >= 360) {
                degrees -= 360;
            }
            return degrees;
        }

        /**
         * This method takes an angle in radians and brings it back into rand between 0 and 2*Math.PI
         * @param	Radian value
         * @return Clamped radian value
         */
        static public function clampRadians(radians:Number):Number {
            while (radians < 0) {
                radians += 2 * Math.PI;
            }

            while (radians >= 2 * Math.PI) {
                radians -= 2 * Math.PI;
            }
            return radians;
        }

    }

}
