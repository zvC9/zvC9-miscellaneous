#ifndef _zvc9_AP_LINE2D_H_
#define _zvc9_AP_LINE2D_H_

#include "AP_point2d.h"

namespace zvC9 {
 class AP_line2d;
 AP_fraction getNumberNotLessThan_distance_from_point_to_line(const AP_point2d & p, const AP_line2d & l);
 
 class AP_line2d {
  protected:
  std::pair<AP_point2d,AP_point2d> vectorPair = std::make_pair(AP_point2d(0,0),AP_point2d(0,0));
  bool vertical;
  AP_fraction x;
  AP_fraction a;
  AP_fraction b;
  public:
  AP_line2d(const AP_point2d & p1, const AP_point2d & p2) {
   if (p1 == p2)
    throw std::runtime_error("can't create line passing through 2 equal points (points must differ)");
   vectorPair.first = p1;
   vectorPair.second = p2;
   if (p1.x == p2.x) {
    vertical = true;
    x = p1.x;
   } else {
    vertical = false;
    // line: ax+b ; ax1+b = y1; ax2+b=y2 ; 
    // y2-y1 = a(x2-x1) => a = (y2-y1)/(x2-x1)
    a = (p2.y-p1.y) / (p2.x-p1.x);
    // ax1+b=y1 => b=y1-ax1
    b = p1.y-a*p1.x;
   }
  }
  AP_line2d parallelMoveToTheLeft(const AP_fraction & distance, const AP_fraction & max_allowed_mistake) {
   AP_point2d direction(0,0);
   direction.x = -(vectorPair.second.y-vectorPair.first.y);
   direction.y =   vectorPair.second.x-vectorPair.first.x;
   AP_point2d moveByVector = scaleVectorToMakeItsLengthAlmostEqualTo(direction, distance, max_allowed_mistake);
   return AP_line2d(vectorPair.first + moveByVector, vectorPair.second + moveByVector);
  }
  AP_line2d parallelMoveToTheRight(const AP_fraction &distance, const AP_fraction &max_allowed_mistake) {
   AP_point2d direction(0,0);
   direction.x =  (vectorPair.second.y-vectorPair.first.y);
   direction.y = -(vectorPair.second.x-vectorPair.first.x);
   AP_point2d moveByVector = scaleVectorToMakeItsLengthAlmostEqualTo(direction, distance, max_allowed_mistake);
   return AP_line2d(vectorPair.first + moveByVector, vectorPair.second + moveByVector);
  }
  AP_point2d intersect(const AP_line2d & line2) {
   if (vertical && line2.vertical)
    throw std::runtime_error("can't find intersection of two vertical lines");
   if ((! vertical) && (! line2.vertical) && (a == line2.a))
    throw std::runtime_error("can't find intersection of two parallel lines");
   if ((! vertical) && (! line2.vertical)) {
    //Найти пересечение:
    //y=ax+b
    //(x,y)*(-a,1)=b
    //
    //(x,cx+d)*(-a,1)=b
    //-ax+cx+d=b
    //x*(c-a)=(b-d)
    //x=(b-d)/(c-a)
    //y=a*x+b
    AP_point2d p(0,0);
    p.x = (b-line2.b) / (line2.a-a);
    p.y = a*p.x+b;
    return p;
   }
   else {
    if (vertical) {
     AP_point2d p(0,0);
     p.x = x;
     p.y = line2.a*x+line2.b;
     return p;
    } else { // line2.vertical
    //y=ax+b, x=line2.x
    AP_point2d p(0,0);
    p.x = line2.x;
    p.y = a*line2.x+b;
    return p;
    }
   }
  }
  
  friend AP_fraction compute_distance_from_point_to_line_with_max_mistake(const AP_point2d & p, const AP_line2d & l, const AP_fraction & max_allowed_mistake);
 };



 AP_fraction compute_distance_from_point_to_line_with_max_mistake(const AP_point2d & p, const AP_line2d & l, const AP_fraction & max_allowed_mistake) {
  if (max_allowed_mistake <= 0)
   throw std::runtime_error("max_allowed_mistake <= 0 (should be >0)");
  
  AP_point2d ortho(0,0);
  AP_point2d vec;
  AP_fraction dotProduct;
  if (! l.vertical){
   vec = l.vectorPair.second - l.vectorPair.first;
   ortho = AP_point2d(-vec.y, vec.x);
  } else {
   ortho = AP_point2d(1, 0);
   dotProduct = p.x-l.vectorPair.first.x;
   if (dotProduct >= 0)
    return dotProduct;
   return -dotProduct;
  }
    //   answer = |dot product (p - l.vectorPair[0], ortho)| / |ortho|
  dotProduct = (p.x-l.vectorPair.first.x)*ortho.x + (p.y-l.vectorPair.first.y)*ortho.y;
    //   |ortho| / 2 <= |ortho| - mistake <= approxLenOfOrtho <= |ortho| + mistake <= |ortho| * 3/2
    //   0 <= mistake <= |ortho|/2
    //   |ortho| - mistake > 0
    //   |ortho|/approxLenOfOrtho - mistake/approxLenOfOrtho <= 1 <= |ortho|/approxLenOfOrtho + mistake/approxLenOfOrtho
    //   answer - approxAnswer = |dot product (p - l.vectorPair[0], ortho)| / |ortho| - |dot product (p - l.vectorPair[0], ortho)| / approxLenOfOrtho =
    //   = |dot product (p - l.vectorPair[0], ortho)| * (approxLenOfOrtho - |ortho|) / (|ortho| * approxLenOfOrtho)
    //   |answer - approxAnswer| = |dot product (p - l.vectorPair[0], ortho)| * |(approxLenOfOrtho - |ortho|)| / (|ortho| * approxLenOfOrtho) <=
    //   <= mistake * |dotProduct| / (|ortho| * approxLenOfOrtho) <= 
    //   <= mistake * |dotProduct| / (|ortho| * (|ortho| / 2)) = mistake * |dotProduct| * 2 / (|ortho|**2)
    //   want: mistake * |dotProduct| * 2 / (|ortho|**2) <= max_allowed_mistake
    //   equal: mistake   <= max_allowed_mistake * (|ortho|**2) / (|dotProduct| * 2)
  AP_fraction notGreaterThanOrthoLength = ortho.getAPositiveNumberNotGreaterThanLengthOfThisVector();
  AP_fraction absDotProduct = dotProduct.abs();
  AP_fraction mistake = max_allowed_mistake * (notGreaterThanOrthoLength * notGreaterThanOrthoLength) /  (absDotProduct * 2);
  if (mistake > notGreaterThanOrthoLength / 2)
   mistake = notGreaterThanOrthoLength / 2;
    //   mistake   <= max_allowed_mistake * (|ortho|**2) / (|dotProduct| * 2)
    //   , so
    //   |answer - approxAnswer| <= max_allowed_mistake
  AP_fraction approxLenOfOrtho = (ortho.x*ortho.x + ortho.y*ortho.y).AP_sqrt(mistake);
  return absDotProduct / approxLenOfOrtho;
 }
  
 AP_fraction  compute_area_of_triangle_with_max_mistake(const AP_point2d & p1, const AP_point2d & p2, const AP_point2d & p3, const AP_fraction & maxAreaMistake) {
  AP_line2d line1 = AP_line2d(p2,p1);
  AP_line2d line2 = AP_line2d(p3,p2);
  AP_line2d line3 = AP_line2d(p1,p3);
  
  AP_fraction SideNotMoreThan = (p2 - p1).getANumberNotLessThanLengthOfThisVector();
  AP_fraction HNotGreaterThan = getNumberNotLessThan_distance_from_point_to_line(p3, line1);
    //   |side| <= SideNotMoreThan
    //   triangleAreaMistake = |triangleArea-approxTriangleArea| = 
    //   = |(side*h/2) - (approxSide*approxH)/2|
    //   side - maxSideMistake <= approxSide <= side + maxSideMistake
    //   h - maxHMistake <= approxH <= h + maxHMistake
    //   val1 = (side*h/2) - (approxSide*approxH)/2
    //   val1 >= (side*h/2) - ((side + maxSideMistake)*(h + maxHMistake))/2 =
    //   = (1/2) * (side*h - side*h-side*maxHMistake-h*maxSideMistake-maxSideMistake*maxHMistake) =
    //   = (-1/2) * (side*maxHMistake+h*maxSideMistake+maxSideMistake*maxHMistake) <= val1
    //  
    //   val1 <= (side*h/2) - ((side - maxSideMistake)*(h - maxHMistake))/2 = 
    //   = (1/2) * (side*h - side*h + side*maxHMistake + h*maxSideMistake - maxSideMistake*maxHMistake) = 
    //   = (1/2) * (side*maxHMistake + h*maxSideMistake - maxSideMistake*maxHMistake) <=
    //   <= (1/2) * (side*maxHMistake + h*maxSideMistake) >= val1
    //  
    //   triangleAreaMistake = |val1| <= max
    //            (
    //     val2=   (1/2) * (side*maxHMistake+h*maxSideMistake+maxSideMistake*maxHMistake)
    //             ,
    //     val3=   (1/2) * (side*maxHMistake + h*maxSideMistake)
    //            )
    //  
    //   val2 <= (1/2) * (SideNotMoreThan*maxHMistake+HNotGreaterThan*maxSideMistake+maxSideMistake*maxHMistake)
    //   val3 <= (1/2) * (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake)
    //  
    //   want: val2 <= maxAreaMistake / 4
    //         val3 <= maxAreaMistake / 4
    //   
    //sufficient:(1/2) * (SideNotMoreThan*maxHMistake+HNotGreaterThan*maxSideMistake+maxSideMistake*maxHMistake) <= maxAreaMistake / 4
    //           (1/2) * (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake) <= maxAreaMistake / 4
    //   equal:  (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake + maxSideMistake*maxHMistake) <= maxAreaMistake / 2
    //           (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake) <= maxAreaMistake / 2
    //sufficient:SideNotMoreThan*maxHMistake    <= maxAreaMistake / 6
    //           HNotGreaterThan*maxSideMistake <= maxAreaMistake / 6 
    //           maxSideMistake*maxHMistake)    <= maxAreaMistake / 6
    //           SideNotMoreThan*maxHMistake    <= maxAreaMistake / 4
    //           HNotGreaterThan*maxSideMistake <= maxAreaMistake / 4
    //   equal:  maxHMistake    <= maxAreaMistake / (6*SideNotMoreThan)
    //           maxSideMistake <= maxAreaMistake / (6*HNotGreaterThan)
    //           maxHMistake    <= maxAreaMistake / (6*maxSideMistake)
    //           maxHMistake    <= maxAreaMistake / (4*SideNotMoreThan)
    //           maxSideMistake <= maxAreaMistake / (4*HNotGreaterThan)
  AP_fraction maxHMistake    =     maxAreaMistake / (6*SideNotMoreThan); // extract here
  AP_fraction maxSideMistake =     maxAreaMistake / (6*HNotGreaterThan);
  if (maxHMistake >    maxAreaMistake / (6*maxSideMistake))
   maxHMistake =       maxAreaMistake / (6*maxSideMistake);
  if (maxHMistake  >   maxAreaMistake / (4*SideNotMoreThan))
   maxHMistake  =      maxAreaMistake / (4*SideNotMoreThan);
  if (maxSideMistake > maxAreaMistake / (4*HNotGreaterThan))
   maxSideMistake =    maxAreaMistake / (4*HNotGreaterThan);
   
    //   now can compute with these mistakes
  AP_fraction approxSide = (p2 - p1).length_of_vector_given_max_mistake(maxSideMistake);
  AP_fraction approxH = compute_distance_from_point_to_line_with_max_mistake(p3, line1, maxHMistake);
  AP_fraction approxTriangleArea = (approxSide*approxH) / 2;
  return approxTriangleArea;
 }
  
  AP_fraction getNumberNotLessThan_distance_from_point_to_line(const AP_point2d & p, const AP_line2d & l) {
  return compute_distance_from_point_to_line_with_max_mistake(p, l, 1) + 1;
 }
}

#endif // #ifndef _zvc9_AP_LINE2D_H_
