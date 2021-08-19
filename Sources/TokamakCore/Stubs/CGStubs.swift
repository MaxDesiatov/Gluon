// Copyright 2020-2021 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Max Desiatov on 08/04/2020.
//

import CoreFoundation
import Foundation

extension CGPoint {
  func rotate(_ angle: Angle, around origin: Self) -> Self {
    let cosAngle = CGFloat(cos(angle.radians))
    let sinAngle = CGFloat(sin(angle.radians))

    return .init(
      x: cosAngle * (x - origin.x) - sinAngle * (y - origin.y) + origin.x,
      y: sinAngle * (x - origin.x) + cosAngle * (y - origin.y) + origin.y
    )
  }

  func offset(by offset: Self) -> Self {
    .init(
      x: x + offset.x,
      y: y + offset.y
    )
  }
}

public extension CGAffineTransform {
  /// Transform the point into the transform's coordinate system.
  func transform(point: CGPoint) -> CGPoint {
    // To transform, we multiply the given point's matrix with the
    // scale-rotation sub-matrix:
    //
    // [ x' y' ] = [ px  py ] × [ a  b ] = [ px*a+py*c  px*b+py*d ]
    //                          [ c  d ]
    //
    // And then add the translation values `tx` and `ty`:
    //
    // [ x' y' ] = [ px*a+py*c  px*b+py*d ] + [ tx  ty ]
    //
    // [ x' y' ] = [ px*a+py*c+tx  px*b+py*d+ty ]
    CGPoint(
      x: (a * point.x) + (c * point.y) + tx,
      y: (b * point.x) + (d * point.y) + ty
    )
  }
}

#warning("Remove `|| true` before merging.")
#if !canImport(CoreGraphics) || true
public enum CGLineCap {
  /// A line with a squared-off end. Extends to the endpoint of the Path.
  case butt
  /// A line with a rounded end. Extends past the endpoint of the Path.
  case round
  /// A line with a squared-off end. Extends past the endpoint of the Path.
  case square
}

public enum CGLineJoin {
  case miter
  /// A join with a rounded end. Extends past the endpoint of the Path.
  case round
  /// A join with a squared-off end. Extends past the endpoint of the Path.
  case bevel
}

/// An affine transformation matrix for use in drawing 2D graphics.
///
///     a   b   0
///     c   d   0
///     tx  ty  1
public struct CGAffineTransform: Equatable, Codable {
  /// The value at position [1,1] in the matrix.
  public var a: CGFloat
  /// The value at position [1,2] in the matrix.
  public var b: CGFloat
  /// The value at position [2,1] in the matrix.
  public var c: CGFloat
  /// The value at position [2,2] in the matrix.
  public var d: CGFloat
  /// The value at position [3,1] in the matrix.
  public var tx: CGFloat
  /// The value at position [3,2] in the matrix.
  public var ty: CGFloat

  /// Creates an affine transform with the given matrix values.
  ///
  /// - Parameters:
  ///   - a: The value at position [1,1] in the matrix.
  ///   - b: The value at position [1,2] in the matrix.
  ///   - c: The value at position [2,1] in the matrix.
  ///   - d: The value at position [2,2] in the matrix.
  ///   - tx: The value at position [3,1] in the matrix.
  ///   - ty: The value at position [3,2] in the matrix.
  public init(
    a: CGFloat, b: CGFloat,
    c: CGFloat, d: CGFloat,
    tx: CGFloat, ty: CGFloat
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.tx = tx
    self.ty = ty
  }
}

public extension CGAffineTransform {
  /// The identity transformation matrix.
  static let identity = Self(
    a: 1, b: 0, // 0
    c: 0, d: 1, // 0
    tx: 0, ty: 0 // 1
  )

  /// Creates the identity transformation matrix.
  init() {
    self = .identity
  }

  var isIdentity: Bool {
    self == .identity
  }
}

public extension CGAffineTransform {
  /// Creates an affine transformation matrix constructed from a rotation value you
  /// provide.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which this matrix rotates the coordinate
  ///   system axes. A positive value specifies clockwise rotation and a negative value
  ///   specifies counterclockwise rotation.
  init(rotationAngle angle: CGFloat) {
    let angleSine = sin(angle)
    let angleCosine = cos(angle)

    self.init(
      a: angleCosine, b: angleSine,
      c: -angleSine, d: angleCosine,
      tx: 0, ty: 0
    )
  }

  /// Creates an affine transformation matrix constructed from scaling values you provide.
  ///
  /// - Postcondition: The created transformation is invertible if both `sx` and
  /// `sy` are not `0`.
  ///
  /// - Parameters:
  ///   - sx: The factor by which to scale the x-axis of the coordinate system.
  ///   - sy: The factor by which to scale the y-axis of the coordinate system.
  init(scaleX sx: CGFloat, y sy: CGFloat) {
    self.init(
      a: sx, b: 0,
      c: 0, d: sy,
      tx: 0, ty: 0
    )
  }

  /// Creates an affine transformation matrix constructed from translation values you
  /// provide.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move the x-axis of the coordinate system.
  ///   - ty: The value by which to move the y-axis of the coordinate system.
  init(translationX tx: CGFloat, y ty: CGFloat) {
    self.init(
      a: 1, b: 0,
      c: 0, d: 1,
      tx: tx, ty: ty
    )
  }
}

public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed by combining two existing affine
  /// transforms.
  ///
  /// Note that concatenation is not commutative, meaning that order is important. For
  /// instance, `t1.concatenating(t2)` != `t2.concatenating(t1)` — where
  /// `t1` and `t2` are`CGAffineTransform` instances.
  ///
  /// - Postcondition: The returned transformation is invertible if both `self` and
  /// the given transformation (`t2`) are invertible.
  ///
  /// - Parameters:
  ///   - t2: The affine transform to concatenate to this affine transform.
  /// - Returns: A new affine transformation matrix. That is, `t’ = t1*t2`.
  func concatenating(_ t2: Self) -> Self {
    //            [ a1, b1, 0 ]          [ a2, b2, 0 ]
    // Given: A = [ c1, d1, 0 ] and: B = [ c2, d2, 0 ]
    //            [ x1, y1, 1 ]          [ x2, y2, 1 ]
    //
    //       [ a1*a2+b1*c2+0*x2 a1*b2+b1*d2+0*y2 a1*0+b1*0+0*1 ]
    // A×B = [ c1*a2+d1*c2+0*x2 c1*b2+d1*d2+0*y2 c1*0+d1*0+0*1 ]
    //       [ x1*a2+y1*c2+1*x2 x1*b2+y1*d2+1*y2 x1*0+y1*0+1*1 ]
    //
    //       [   a1*a2+b1*c2    a1*b2+b1*d2        0 ]
    // A×B = [   c1*a2+d1*c2    c1*b2+d1*d2        0 ]
    //       [ x1*a2+y1*c2+x2  x1*b2+y1*d2+y2      1 ]
    let t1 = self

    return CGAffineTransform(
      a: (t1.a * t2.a) + (t1.b * t2.c),
      b: (t1.a * t2.b) + (t1.b * t2.d),
      c: (t1.c * t2.a) + (t1.d * t2.c),
      d: (t1.c * t2.b) + (t1.d * t2.d),
      tx: (t1.tx * t2.a) + (t1.ty * t2.c) + t2.tx,
      ty: (t1.tx * t2.b) + (t1.ty * t2.d) + t2.ty
    )
  }
}

public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed by inverting an existing affine
  /// transform.
  ///
  /// - Postcondition: Invertibility is preserved, meaning that if `self` is
  /// invertible, so the returned transformation will also be invertible.
  ///
  /// - Returns: A new affine transformation matrix. If `self` is not invertible, it's
  /// returned unchanged.
  func inverted() -> Self {
    // Before finding the inverse matrix we first have to find the
    // determinant |A| by which we'll divide later. So given:
    //     [ a b 0 ]
    // A = [ c d 0 ]
    //     [ x y 1 ]
    //
    // The determinant |A| is:
    //
    // |A| = a(d*1-y*0) - b(c*1-x*0) + 0(d*x-c*y) = a*d - b*c
    let determinant = (a * d) - (b * c)
    
    // Since we're going divide by the determinant we must check
    // that |A|≠0. Note that floating-point rounding could also
    // produce infinity (the division-by-zero result), but we
    // just want to detect simple cases, like scaling by 0.
    guard determinant != 0 else { return self }
    
    // Then, we have to find the matrix of cofactors. To do that,
    // we first need to calculate the minors of each element —
    // where the minor of an element Ai,j is the determinant of
    // the matrix derived from deleting the ith row and jth column:
    //
    //     [ |d y|  |c x|  |c x| ]
    //     [ |0 1|  |0 1|  |d y| ]
    //     [                     ]
    //     [ |b y|  |a x|  |a x| ]
    // M = [ |0 1|  |0 1|  |b y| ]
    //     [                     ]
    //     [ |b d|  |a c|  |a c| ]
    //     [ |0 0|  |0 0|  |b d| ]
    //
    //     [ d*1-y*0  c*1-x*0  c*y-x*d ]
    // M = [ b*1-y*0  a*1-x*0  a*y-x*b ]
    //     [ b*0-d*0  a*0-c*0  a*d-c*b ]
    //
    //     [ d    c    c*y-x*d ]
    // M = [ b    a    a*y-x*b ]
    //     [ 0    0      |A|   ]
    //
    // Now we can calculate the matrix of cofactors by negating
    // each element Ai,j when i+j is odd:
    //
    //     [  d    -c     c*y-x*d   ]
    // C = [ -b     a   -(a*y-x*b)  ]
    //     [  0    -0       |A|     ]
    //
    // Next, we can calculate the adjugate matrix, which is the
    // transposed matrix of cofactors — a matrix whose ith
    // column is the ith row of the matrix of C:
    //
    //          [    d         -b          0  ]
    // adj(A) = [   -c          a         -0  ]
    //          [ c*y-x*d  -(a*y-x*b)     |A| ]
    //
    // Finally, the inverse matrix is the product of the
    // reciprocal of |A| times adj(A):
    //
    //        [     d/|A|          -b/|A|         0/|A|  ]
    // A^-1 = [    -c/|A|           a/|A|        -0/|A|  ]
    //        [ (c*y-x*d)/|A|  -(a*y-x*b)/|A|    |A|/|A| ]
    //
    //        [     d/|A|          -b/|A|          0 ]
    // A^-1 = [    -c/|A|           a/|A|          0 ]
    //        [ (c*y-x*d)/|A|   (x*b-a*y)/|A|      1 ]
    return Self(
      a: d / determinant,
      b: -b / determinant,
      c: -c / determinant,
      d: a / determinant,
      tx: (c * ty - d * tx) / determinant,
      ty: (b * tx - a * ty) / determinant
    )
  }
}

// TODO: - Optimize operators.
public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed by rotating an existing affine
  /// transform.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which to rotate the affine transform.
  ///   A positive value specifies clockwise rotation and a negative value specifies
  ///   counterclockwise rotation.
  func rotated(by angle: CGFloat) -> Self {
    // To rotate, we concatenate the scaling matrix (R) with
    // self (A): A'=R×A, producing the concatenated matrix
    // A'. A', given an angle in radians α is:
    //
    //       [  cos(α)  sin(α)   0 ]   [ a   b   0 ]
    // R×A = [ -sin(α)  cos(α)   0 ] × [ c   d   0 ]
    //       [    0       0      1 ]   [ x   y   1 ]
    //
    //       [  cos(α)*a+sin(α)*c   cos(α)*b+sin(α)*d      0 ]
    // R×A = [ -sin(α)*a+cos(α)*c  -sin(α)*b+cos(α)*d      0 ]
    //       [      0*a+0*c+x           0*b+0*d+y          1 ]
    //
    //       [  cos(α)*a+sin(α)*c   cos(α)*b+sin(α)*d      0 ]
    // R×A = [ -sin(α)*a+cos(α)*c  -sin(α)*b+cos(α)*d      0 ]
    //       [          x                   y              1 ]
    
    let cosα = cos(angle), sinα = sin(angle)
    
    return Self(
      a: cosα*a + sinα*c, b: cosα*b + sinα*d,
      c: -sinα*a+cosα*c, d: -sinα*b+cosα*d,
      tx: tx, ty: ty
    )
  }

  /// Returns an affine transformation matrix constructed by scaling an existing affine
  /// transform.
  ///
  /// - Postcondition: Invertibility is preserved if both `sx` and `sy` aren't `0`.
  ///
  /// - Parameters:
  ///   - sx: The value by which to scale x values of the affine transform.
  ///   - sy: The value by which to scale y values of the affine transform.
  func scaledBy(x sx: CGFloat, y sy: CGFloat) -> Self {
    // To scale, we concatenate the scaling matrix (S) with
    // self (A): A'=S×A, producing the concatenated matrix
    // A'. A', given two non-zero scaling coefficients sx and
    // sy, is:
    //
    //       [ sx  0   0 ]   [ a   b   0 ]
    // S×A = [ 0   sy  0 ] × [ c   d   0 ]
    //       [ 0   0   1 ]   [ x   y   1 ]
    //
    //       [ sx*a+0*c    sx*b+0*d      0 ]
    // S×A = [ 0*a+sy*c    0*b+sy*d      0 ]
    //       [ 0*a+0*c+x   0*b+0*d+y     1 ]
    //
    //       [ sx*a sx*b  0 ]
    // S×A = [ sy*c sy*d  0 ]
    //       [  x    y    1 ]
    
    Self(
      a: sx * a, b: sx * b,
      c: sy * c, d: sy * d,
      tx: tx, ty: ty
    )
  }

  /// Returns an affine transformation matrix constructed by translating an existing
  /// affine transform.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move x values with the affine transform.
  ///   - ty: The value by which to move y values with the affine transform.
  func translatedBy(x: CGFloat, y: CGFloat) -> Self {
    // To translate, we concatenate the translation matrix (T)
    // with self (A):
    //
    //       [ 1  0  0 ]   [ a    b    0 ]
    // T×A = [ 0  1  0 ] × [ c    d    0 ]
    //       [ x  y  1 ]   [ tx   ty   1 ]
    //
    //       [  1*a+0*c      1*b+0*d        0 ]
    // T×A = [  0*a+1*c      0*b+1*d        0 ]
    //       [ x*a+y*c+tx   x*b+y*d+ty      1 ]
    //
    //       [     a           b         0 ]
    // T×A = [     c           d         0 ]
    //       [ x*a+y*c+tx  x*b+y*d+ty    1 ]

    Self(
      a: a, b: b,
      c: c, d: d,
      tx: x*a + y*c + tx, ty: x*b + y*d + ty
    )
  }
}

#endif
