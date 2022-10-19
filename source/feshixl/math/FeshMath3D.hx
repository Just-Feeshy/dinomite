package feshixl.math;

import openfl.geom.Matrix;

class FeshMath3D {

    /**
    * @param Z regular 2d angle from `FlxSprite`.
    */
    public inline static function rotateWithTrig3D(matrix:Matrix, thetaX:Float, thetaY:Float, thetaZ:Float, z:Float = 0, hasPerspective:Bool = true):Void {

        final xc:Float = Math.cos(thetaX);
        final xs:Float = Math.sin(thetaX);
        final yc:Float = Math.cos(thetaY);
        final ys:Float = Math.sin(thetaY);
        final zc:Float = Math.cos(thetaZ);
        final zs:Float = Math.sin(thetaZ);

        var p1:Float = 1;
        var p2:Float = 1;
        var p3:Float = 1;

        matrix.rotate(thetaZ);
    }

    public inline static function multiplyMatrices(a:FeshMatrix4x4, b:FeshMatrix4x4):FeshMatrix4x4 {
        a.multiplyBy(b);
        return a;
    }
}