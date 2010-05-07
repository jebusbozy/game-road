/**
 * Trigonometry maths.
 * 
 * @file	Trigonometry.as
 * @author 	Jorge Miranda
 * @version 1.0.0
 */

/*
 * History:
 * 
 * v 1.0.0 - First Release - Jorge Miranda
 */

package com.gameroad.maths { 
	public class Trigonometry {

		
		public static function degreesToRadians(n:Number):Number {
			
			return Math.PI/180 * n
		}
		
		
		public static function radiansToDegrees(r:Number):Number
		{
			var rad:Number = r * 180 / Math.PI;
			if (rad > 180) rad = -180*2 + rad;
			
			return rad
		}
		
		
		public static function polarToCartesian(r:Number,aXY:Number,aZ:Number):Vector3
		{
			var pos :Vector3 = new Vector3(0,0,0);
			pos.x = r*Math.cos(aXY)*Math.cos(aZ)
			pos.y = r*Math.sin(aXY)*Math.cos(aZ)
			pos.z = r*Math.sin(aZ)
			
			return pos;
		}
		
		
		public static function cartesianToPolar(x:Number,y:Number,z:Number = 0):Object
		{
			var pos :Object = new Object();
			
			pos.aXY = Math.atan2(y,x)
			
			pos.aZ = Math.atan(z/Math.sqrt(y*y+x*x))
			
			pos.r = Math.sqrt(x*x +y*y+z*z)
			
			return pos;			
		}
		
		
		public static function distanceToAngle(angle :Number, targ :Number) :Number {
			
			angle %= 360;
			targ %= 360;
			
			if(targ < 0) targ += 360;
			
			var diff:Number = targ - angle;
			
			if(diff > 180)			diff -= 360;
			else if(diff < -180)	diff += 360;
			
			return diff;
		}
		
		
	}
}