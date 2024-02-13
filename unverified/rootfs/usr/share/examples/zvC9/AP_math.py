#!/usr/bin/python3



import fractions
import math
import sys

def metersToPictureCoordinates(point):
 point.x = fractions.Fraction(point.x)
 point.y = fractions.Fraction(point.y)
 global XminCM
 global YminCM
 global maxDiffCM
 global mulBy
 global marginsMM
 
 #print ("XminCM, YminCM, maxDiffCM, mulBy, marginsMM: ", XminCM, YminCM, maxDiffCM, mulBy, marginsMM)
 
 return Point2d(
   fractions.Fraction(point.x*100-XminCM,maxDiffCM)*mulBy+marginsMM,
   fractions.Fraction(point.y*100-YminCM,maxDiffCM)*mulBy+marginsMM
#   fractions.Fraction(point.x*100-XminCM,maxDiffCM)*mulBy,
#   fractions.Fraction(point.y*100-YminCM,maxDiffCM)*mulBy
  )
 

def cos_of_frac_given_max_mistake(x, maxMistake):
 # Taylor's theorem
 # Pk(x) = f(a) + f'(a)(x-a) + ... + f^((k))(a)/(k!) * (x-a)^k
 # Rk(x) = f(x) - Pk(x)
 # Rk(x) = f^((k+1))(point) / ((k+1)!) * (x-a) ^ (k+1)
 # point between a and x
 
 # f = cos, f' = -sin, f'' = -cos, f''' = sin, f''''=f^((4)) = cos, ...
 # |f^((...))(...)| <= 1
 #==============================
 #           |x-a|^(k+1)
 # |Rk| <=  —————————————
 #              (k+1)!
 #==============================
 # a = 0 , f(a) = 1, f'(a) = 0, f''(a) = -1 , f'''(a) = 0, ...
 # cos(0)       =  1
 # cos'(0)      =  0
 # cos''(0)     = -1
 # cos'''(0)    =  0
 # cos''''(0)   =  1
 # cos'''''(0)  =  0
 #              = -1
 #              =  0
 #              =  1
 #              =  0
 #              =  ...
 x = fractions.Fraction(x, 1)
 maxMistake = fractions.Fraction(maxMistake, 1)
 if (maxMistake <= 0):
  raise Exception("maxMistake must be > 0")
 k = 1
 absX = x
 if (absX < 0):
  absX = -absX
 absXPowKplus1=absX*absX
 kPlus1Factorial=2
 AbsRkNotMoreThan = fractions.Fraction(absXPowKplus1, kPlus1Factorial)
 while (AbsRkNotMoreThan > maxMistake):
  k += 1
  absXPowKplus1   *= absX
  kPlus1Factorial *= (k+1)
  AbsRkNotMoreThan = fractions.Fraction(absXPowKplus1, kPlus1Factorial)
 #print("sin_of_frac_given_max_mistake(",x,",",maxMistake,"): k =", k)
 derivatives = [1,0,-1,0] # at zero
 sum = fractions.Fraction(0, 1)
 sum += 1 # cos(0) = f(a) = 1
 xpowi = x
 ifactorial = 1
 for i in range (1,k+1):
  derivative = derivatives[i%4]
  sum += fractions.Fraction(derivative * xpowi, ifactorial)
  xpowi *= x
  ifactorial *= (i+1)
 return sum

def sin_of_frac_given_max_mistake(x, maxMistake):
 # Taylor's theorem
 # Pk(x) = f(a) + f'(a)(x-a) + ... + f^((k))(a)/(k!) * (x-a)^k
 # Rk(x) = f(x) - Pk(x)
 # Rk(x) = f^((k+1))(point) / ((k+1)!) * (x-a) ^ (k+1)
 # point between a and x
 
 # f = sin, f' = cos, f'' = -sin, f''' = -cos, f''''=f^((4)) = sin, ...
 # |f^((...))(...)| <= 1
 #==============================
 #           |x-a|^(k+1)
 # |Rk| <=  —————————————
 #              (k+1)!
 #==============================
 # a = 0 , f(a) = 0, f'(a) = 1, f''(a) = 0 , f'''(a) = -1, ...
 # sin(0)       =  0
 # sin'(0)      =  1
 # sin''(0)     =  0
 # sin'''(0)    = -1
 # sin''''(0)   =  0
 # sin'''''(0)  =  1
 #              =  0
 #              = -1
 #              =  0
 #              =  1
 #              =  ...
 x = fractions.Fraction(x, 1)
 maxMistake = fractions.Fraction(maxMistake, 1)
 if (maxMistake <= 0):
  raise Exception("maxMistake must be > 0")
 k = 1
 absX = x
 if (absX < 0):
  absX = -absX
 absXPowKplus1=absX*absX
 kPlus1Factorial=2
 AbsRkNotMoreThan = fractions.Fraction(absXPowKplus1, kPlus1Factorial)
 while (AbsRkNotMoreThan > maxMistake):
  k += 1
  absXPowKplus1   *= absX
  kPlus1Factorial *= (k+1)
  AbsRkNotMoreThan = fractions.Fraction(absXPowKplus1, kPlus1Factorial)
 #print("sin_of_frac_given_max_mistake(",x,",",maxMistake,"): k =", k)
 derivatives = [0,1,0,-1] # at zero
 sum = fractions.Fraction(0, 1)
 xpowi = x
 ifactorial = 1
 for i in range (1,k+1):
  derivative = derivatives[i%4]
  sum += fractions.Fraction(derivative * xpowi, ifactorial)
  xpowi *= x
  ifactorial *= (i+1)
 return sum
def sqrt_of_frac_given_max_mistake(x, maxMistake):
 x = fractions.Fraction(x, 1)
 maxMistake = fractions.Fraction(maxMistake, 1)
 if (x == fractions.Fraction(0,1)):
  return fractions.Fraction(0,1)
 if (x < fractions.Fraction(0,1)):
  raise Exception("sqrt of <0")
 if (maxMistake <= fractions.Fraction(0,1)):
  raise Exception("maxMistake <= 0")
 sqrtmin=fractions.Fraction(0,1)
 sqrtmax=fractions.Fraction(1,1)
 while (sqrtmax*sqrtmax < x):
  sqrtmax *= fractions.Fraction(2,1)
 if (sqrtmax * sqrtmax == x):
  return sqrtmax
 while True:
  sqrtnext = fractions.Fraction(sqrtmin+sqrtmax,2)
  if (sqrtnext*sqrtnext == x):
   return sqrtnext
  elif (sqrtnext * sqrtnext > x):
   sqrtmax=sqrtnext
  else :
   sqrtmin = sqrtnext
  if (sqrtmax-sqrtmin < maxMistake):
   return fractions.Fraction(sqrtmin+sqrtmax,2)
def frac_to_string_n_digits_after_dot (x, digits):
 x = fractions.Fraction(x,1)
 if (type(digits) != type(1)):
  raise Exception("digits must be positive integer")
 if (digits <= 0):
  raise Exception("digits must be positive integer")
 x10PowDigits = x * 10**digits;
 whole = x.numerator // x.denominator;
 res = "";
 res += str(whole)
 res += "."
 remainder = x10PowDigits.numerator // x10PowDigits.denominator % 10**digits;
 resplus= str(remainder);
 while (len(resplus) < digits):
  resplus = "0" + resplus
 res += resplus
 return res

class Point2d:
 def __init__(self, X, Y):
  self.x = fractions.Fraction(X,1)
  self.y = fractions.Fraction(Y,1)
 def __mul__(self, number):
  number = fractions.Fraction(number, 1)
  result=Point2d(0,0)
  result.x = self.x*number
  result.y = self.y*number
  return result
 def __add__(self, point): # as vector
  return Point2d(self.x+point.x, self.y+point.y)
 def __sub__(self, point):
  return Point2d(self.x-point.x, self.y-point.y)
 def middleBetweenSelfAndOtherPoint(self, other):
  return Point2d(fractions.Fraction(self.x+other.x,2), fractions.Fraction(self.y+other.y,2))
 def weightedSumWIthOtherPoint(self, other, coeff):
  coeff = fractions.Fraction(coeff, 1)
  return Point2d(self.x*coeff+other.x*(1-coeff), self.y*coeff+other.y*(1-coeff))
 def getANumberNotLessThanLengthOfThisVector(self):
  result = fractions.Fraction(1,1);
  squareLength = self.x*self.x + self.y*self.y
  while (squareLength > result*result):
   result *= 2
  return result
 def getAPositiveNumberNotGreaterThanLengthOfThisVector(self):
  if (self.x == 0 and self.y == 0):
   raise Exception("zero vector, can't find positive number ...")
  result = fractions.Fraction(1,1);
  squareLength = self.x*self.x + self.y*self.y
  while (squareLength < result*result):
   result /= 2
  return result
 def length_of_vector_given_max_mistake(self, maxMistake):
  return sqrt_of_frac_given_max_mistake(self.x*self.x + self.y*self.y, maxMistake)

def getNumberNotLessThan_distance_from_point_to_line(p, l):
 return compute_distance_from_point_to_line_with_max_mistake(p, l, fractions.Fraction(1,1)) + 1

def compute_distance_from_point_to_line_with_max_mistake(p, l, maxMistake):
 maxMistake = fractions.Fraction(maxMistake, 1)
 if (maxMistake <= fractions.Fraction(0,1)):
  raise Exception("maxMistake <= 0")
 
 ortho = Point2d(0,0)
 if (not l.vertical):
  vec = l.vectorPair[1] - l.vectorPair[0]
  ortho = Point2d(-vec.y, vec.x)
 else:
  ortho = Point2d(1, 0)
  dotProduct = p.x-l.vectorPair[0].x
  if (dotProduct >= 0):
   return dotProduct
  return -dotProduct
 # answer = |dot product (p - l.vectorPair[0], ortho)| / |ortho|
 dotProduct = (p.x-l.vectorPair[0].x)*ortho.x + (p.y-l.vectorPair[0].y)*ortho.y
 # |ortho| / 2 <= |ortho| - mistake <= approxLenOfOrtho <= |ortho| + mistake <= |ortho| * 3/2
 # 0 <= mistake <= |ortho|/2
 # |ortho| - mistake > 0
 # |ortho|/approxLenOfOrtho - mistake/approxLenOfOrtho <= 1 <= |ortho|/approxLenOfOrtho + mistake/approxLenOfOrtho
 # answer - approxAnswer = |dot product (p - l.vectorPair[0], ortho)| / |ortho| - |dot product (p - l.vectorPair[0], ortho)| / approxLenOfOrtho =
 # = |dot product (p - l.vectorPair[0], ortho)| * (approxLenOfOrtho - |ortho|) / (|ortho| * approxLenOfOrtho)
 # |answer - approxAnswer| = |dot product (p - l.vectorPair[0], ortho)| * |(approxLenOfOrtho - |ortho|)| / (|ortho| * approxLenOfOrtho) <=
 # <= mistake * |dotProduct| / (|ortho| * approxLenOfOrtho) <= 
 # <= mistake * |dotProduct| / (|ortho| * (|ortho| / 2)) = mistake * |dotProduct| * 2 / (|ortho|**2)
 # want: mistake * |dotProduct| * 2 / (|ortho|**2) <= maxMistake
 # equal: mistake   <= maxMistake * (|ortho|**2) / (|dotProduct| * 2)
 notGreaterThanOrthoLength = ortho.getAPositiveNumberNotGreaterThanLengthOfThisVector()
 absDotProduct = dotProduct
 if (absDotProduct < 0):
  absDotProduct = -absDotProduct
 mistake = fractions.Fraction(maxMistake * (notGreaterThanOrthoLength * notGreaterThanOrthoLength), (absDotProduct * 2))
 if (mistake > notGreaterThanOrthoLength / 2):
  mistake = notGreaterThanOrthoLength / 2
 # mistake   <= maxMistake * (|ortho|**2) / (|dotProduct| * 2)
 # , so
 # |answer - approxAnswer| <= maxMistake
 approxLenOfOrtho = sqrt_of_frac_given_max_mistake(ortho.x*ortho.x + ortho.y*ortho.y, mistake)
 approxAnswer = fractions.Fraction(absDotProduct , approxLenOfOrtho)
 return approxAnswer
 
def compute_area_of_triangle_with_max_mistake(p1, p2, p3, maxAreaMistake):
 maxAreaMistake = fractions.Fraction(maxAreaMistake, 1)
 p1.x = fractions.Fraction(p1.x, 1)
 p1.y = fractions.Fraction(p1.y, 1)
 p2.x = fractions.Fraction(p2.x, 1)
 p2.y = fractions.Fraction(p2.y, 1)
 p3.x = fractions.Fraction(p3.x, 1)
 p3.y = fractions.Fraction(p3.y, 1)
 
 line1=Line2d(p2,p1)
 line2=Line2d(p3,p2)
 line3=Line2d(p1,p3)
 
 SideNotMoreThan = (p2 - p1).getANumberNotLessThanLengthOfThisVector()
 HNotGreaterThan = getNumberNotLessThan_distance_from_point_to_line(p3, line1)
 # |side| <= SideNotMoreThan
 # triangleAreaMistake = |triangleArea-approxTriangleArea| = 
 # = |(side*h/2) - (approxSide*approxH)/2|
 # side - maxSideMistake <= approxSide <= side + maxSideMistake
 # h - maxHMistake <= approxH <= h + maxHMistake
 # val1 = (side*h/2) - (approxSide*approxH)/2
 # val1 >= (side*h/2) - ((side + maxSideMistake)*(h + maxHMistake))/2 =
 # = (1/2) * (side*h - side*h-side*maxHMistake-h*maxSideMistake-maxSideMistake*maxHMistake) =
 # = (-1/2) * (side*maxHMistake+h*maxSideMistake+maxSideMistake*maxHMistake) <= val1
 #
 # val1 <= (side*h/2) - ((side - maxSideMistake)*(h - maxHMistake))/2 = 
 # = (1/2) * (side*h - side*h + side*maxHMistake + h*maxSideMistake - maxSideMistake*maxHMistake) = 
 # = (1/2) * (side*maxHMistake + h*maxSideMistake - maxSideMistake*maxHMistake) <=
 # <= (1/2) * (side*maxHMistake + h*maxSideMistake) >= val1
 #
 # triangleAreaMistake = |val1| <= max
 #          (
 #   val2=   (1/2) * (side*maxHMistake+h*maxSideMistake+maxSideMistake*maxHMistake)
 #           ,
 #   val3=   (1/2) * (side*maxHMistake + h*maxSideMistake)
 #          )
 #
 # val2 <= (1/2) * (SideNotMoreThan*maxHMistake+HNotGreaterThan*maxSideMistake+maxSideMistake*maxHMistake)
 # val3 <= (1/2) * (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake)
 #
 # want: val2 <= maxAreaMistake / 4
 #       val3 <= maxAreaMistake / 4
 # 
 # enough: (1/2) * (SideNotMoreThan*maxHMistake+HNotGreaterThan*maxSideMistake+maxSideMistake*maxHMistake) <= maxAreaMistake / 4
 #         (1/2) * (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake) <= maxAreaMistake / 4
 # equal:  (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake + maxSideMistake*maxHMistake) <= maxAreaMistake / 2
 #         (SideNotMoreThan*maxHMistake + HNotGreaterThan*maxSideMistake) <= maxAreaMistake / 2
 # enough: SideNotMoreThan*maxHMistake    <= maxAreaMistake / 6
 #         HNotGreaterThan*maxSideMistake <= maxAreaMistake / 6 
 #         maxSideMistake*maxHMistake)    <= maxAreaMistake / 6
 #         SideNotMoreThan*maxHMistake    <= maxAreaMistake / 4
 #         HNotGreaterThan*maxSideMistake <= maxAreaMistake / 4
 # equal:  maxHMistake    <= maxAreaMistake / (6*SideNotMoreThan)
 #         maxSideMistake <= maxAreaMistake / (6*HNotGreaterThan)
 #         maxHMistake    <= maxAreaMistake / (6*maxSideMistake)
 #         maxHMistake    <= maxAreaMistake / (4*SideNotMoreThan)
 #         maxSideMistake <= maxAreaMistake / (4*HNotGreaterThan)
 maxHMistake    =     fractions.Fraction(maxAreaMistake, (6*SideNotMoreThan))
 maxSideMistake =     fractions.Fraction(maxAreaMistake, (6*HNotGreaterThan))
 if (maxHMistake >    fractions.Fraction(maxAreaMistake, (6*maxSideMistake))):
  maxHMistake =       fractions.Fraction(maxAreaMistake, (6*maxSideMistake))
 if (maxHMistake  >   fractions.Fraction(maxAreaMistake, (4*SideNotMoreThan))):
  maxHMistake  =      fractions.Fraction(maxAreaMistake, (4*SideNotMoreThan))
 if (maxSideMistake > fractions.Fraction(maxAreaMistake, (4*HNotGreaterThan))):
  maxSideMistake =    fractions.Fraction(maxAreaMistake, (4*HNotGreaterThan))
  
 # now can compute with these mistakes
 approxSide = (p2 - p1).length_of_vector_given_max_mistake(maxSideMistake)
 approxH = compute_distance_from_point_to_line_with_max_mistake(p3, line1, maxHMistake)
 approxTriangleArea = fractions.Fraction(approxSide*approxH,2)
 return approxTriangleArea
 

def scaleVectorToMakeItsLengthAlmostEqualTo(vector, length, maxMistake): # length will be max this mistake far from desired length
 vector.x = fractions.Fraction(vector.x, 1)
 vector.y = fractions.Fraction(vector.y, 1)
 maxMistake = fractions.Fraction(maxMistake, 1)
 length=fractions.Fraction(length, 1)
 
 #initialLengthNotGreaterThan = vector.getANumberNotLessThanLengthOfThisVector()
 
 if ((vector.x == 0) and (vector.y == 0)):
  raise Exception("can't scale vector (0,0)")
 if (length < 0):
  raise Exception("length must be >= 0")
 
 coeffMin = fractions.Fraction(0,1)
 coeffMax = fractions.Fraction(1,1)
 
 while ((vector.x*vector.x+vector.y*vector.y)*coeffMax*coeffMax < length*length):
  coeffMax *= 2
 
 while True:
  coeffMid = fractions.Fraction(coeffMin+coeffMax,2)
  
  approxLength = sqrt_of_frac_given_max_mistake((vector.x*vector.x+vector.y*vector.y)*coeffMid*coeffMid, maxMistake/2)
  if ((approxLength >= length-maxMistake/2) and (approxLength <= length+maxMistake/2)):
   return vector*coeffMid
  
  if ((vector.x*vector.x+vector.y*vector.y)*coeffMid*coeffMid < length*length):
   coeffMin=coeffMid
  else:
   coeffMax=coeffMid

class Line2d:
 def __init__(self, p1, p2):
  p1.x = fractions.Fraction(p1.x,1)
  p1.y = fractions.Fraction(p1.y,1)
  p2.x = fractions.Fraction(p2.x,1)
  p2.y = fractions.Fraction(p2.y,1)
  if (p1 == p2):
   raise Exception("can't create line passing through 2 equal points (points must differ)")
  self.vectorPair = (p1, p2)
  if (p1.x == p2.x):
   self.vertical = True
   self.x = p1.x
  else:
   self.vertical = False
   # line: ax+b ; ax1+b = y1; ax2+b=y2 ; 
   # y2-y1 = a(x2-x1) => a = (y2-y1)/(x2-x1)
   self.a = fractions.Fraction(p2.y-p1.y,p2.x-p1.x)
   # ax1+b=y1 => b=y1-ax1
   self.b = p1.y-self.a*p1.x
 def parallelMoveToTheRight(self, distance, maxMistake):
  maxMistake=fractions.Fraction(maxMistake,1)
  direction = Point2d(0,0)
  direction.x = -(self.vectorPair[1].y-self.vectorPair[0].y)
  direction.y =   self.vectorPair[1].x-self.vectorPair[0].x
  moveByVector = scaleVectorToMakeItsLengthAlmostEqualTo(direction, distance, maxMistake)
  return Line2d(self.vector[0] + moveByVector, self.vector[1] + moveByVector)
 def parallelMoveToTheRight(self, distance, maxMistake):
  maxMistake=fractions.Fraction(maxMistake,1)
  direction = Point2d(0,0)
  direction.x =  (self.vectorPair[1].y-self.vectorPair[0].y)
  direction.y = -(self.vectorPair[1].x-self.vectorPair[0].x)
  moveByVector = scaleVectorToMakeItsLengthAlmostEqualTo(direction, distance, maxMistake)
  return Line2d(self.vectorPair[0] + moveByVector, self.vectorPair[1] + moveByVector)
 def intersect(self, line2):
  if (self.vertical and line2.vertical):
   raise Exception("can't find intersection of two vertical lines")
  if ((not self.vertical) and (not line2.vertical) and (self.a == line2.a)):
   raise Exception("can't find intersection of two parallel lines")
  if ((not self.vertical) and (not line2.vertical)):
   #Найти пересечение:
   #y=ax+b
   #(x,y)*(-a,1)=b
   #
   #(x,cx+d)*(-a,1)=b
   #-ax+cx+d=b
   #x*(c-a)=(b-d)
   #x=(b-d)/(c-a)
   #y=a*x+b
   p = Point2d(0,0)
   p.x = fractions.Fraction(self.b-line2.b,line2.a-self.a)
   p.y = self.a*p.x+self.b
   return p
  elif (self.vertical):
   p=Point2d(0,0)
   p.x = self.x
   p.y = line2.a*self.x+line2.b
   return p
  else: # line2.vertical
   #y=ax+b, x=line2.x
   p=Point2d(0,0)
   p.x = line2.x
   p.y = self.a*line2.x+self.b
   return p
  



