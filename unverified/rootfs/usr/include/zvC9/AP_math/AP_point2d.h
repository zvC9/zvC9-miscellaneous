#ifndef _zvC9_AP_POINT2D_H_
#define _zvC9_AP_POINT2D_H_

#include "AP_fraction.h"

namespace zvC9 {
 class AP_point2d {
  public:
   AP_fraction x = 0;
   AP_fraction y = 0;
  
  AP_point2d() {
  }
  
  AP_point2d(const AP_fraction & X, const AP_fraction & Y) {
   x = X;
   y = Y;
  }
  
  bool operator == (const AP_point2d & other) const {
   return (x == other.x) && (y == other.y);
  }
  
  AP_point2d operator *(const AP_fraction & number) const {
   AP_point2d result(0,0);
   result.x = x*number;
   result.y = y*number;
   return result;
  }
  AP_point2d operator +(const AP_point2d & point)const  { // as vector
   return AP_point2d(x+point.x, y+point.y);
  }
  AP_point2d operator -(const AP_point2d & point)const  { // as vector
   return AP_point2d(x-point.x, y-point.y);
  }
  AP_point2d middleBetweenSelfAndOtherPoint(const AP_point2d &other) const {
   return AP_point2d((x+other.x)/2, (y+other.y)/2);
  }
  AP_point2d weightedSumWIthOtherPoint(const AP_point2d &other, const AP_fraction & coeff) const {
   return AP_point2d(x*coeff+other.x*(1-coeff), y*coeff+other.y*(1-coeff));
  }
  AP_fraction getANumberNotLessThanLengthOfThisVector() const {
   AP_fraction result = 1;
   AP_fraction squareLength = x*x + y*y;
   while (squareLength > result*result) {
    result *= 2;
   }
   return result;
  }
  AP_fraction getAPositiveNumberNotGreaterThanLengthOfThisVector() const {
   if (x == 0 && y == 0)
    throw std::runtime_error("getAPositiveNumberNotGreaterThanLengthOfThisVector(): zero vector, can't find positive number");
   AP_fraction result = 1;
   AP_fraction squareLength = x*x + y*y;
   while (squareLength < result*result)
    result /= 2;
   return result;
  }
  AP_fraction length_of_vector_given_max_mistake(const AP_fraction & max_allowed_mistake) {
   return (x*x + y*y).AP_sqrt(max_allowed_mistake);
  }
 };


 AP_point2d scaleVectorToMakeItsLengthAlmostEqualTo(const AP_point2d & vector, const AP_fraction & length, const AP_fraction & max_allowed_mistake) { // length will be max this mistake far from desired length
  
  //#initialLengthNotGreaterThan = vector.getANumberNotLessThanLengthOfThisVector()
  
  if ((vector.x == 0) && (vector.y == 0))
   throw std::runtime_error("can't scale vector (0,0)");
  if (length < 0)
   throw std::runtime_error("\"AP_point2d scaleVectorToMakeItsLengthAlmostEqualTo(const AP_point2d & vector, const AP_fraction & length, const AP_fraction & max_allowed_mistake)\": length must be >= 0");
  
  AP_fraction coeffMin = 0;
  AP_fraction coeffMax = 1;
  
  while ((vector.x*vector.x+vector.y*vector.y)*coeffMax*coeffMax < length*length)
   coeffMax *= 2;
  
  while (true) {
   AP_fraction coeffMid;
   coeffMid = (coeffMin+coeffMax)/2;
   AP_fraction approxLength;
   approxLength = ((vector.x*vector.x+vector.y*vector.y)*coeffMid*coeffMid).AP_sqrt(max_allowed_mistake/2);
   if ((approxLength >= length-max_allowed_mistake/2) && (approxLength <= length+max_allowed_mistake/2))
    return vector*coeffMid;
   
   if ((vector.x*vector.x+vector.y*vector.y)*coeffMid*coeffMid < length*length)
    coeffMin=coeffMid;
   else
    coeffMax=coeffMid;
  }
 }
}


#endif // #ifndef _zvC9_AP_POINT2D_H_

