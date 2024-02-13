#ifndef _zvC9_AP_FRACTION_H_
#define _zvC9_AP_FRACTION_H_

#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <utility>
#include <stdexcept>
#include <ostream>

#include "AP_int.h"

namespace zvC9 {
 class AP_fraction {
  protected:
   // GCD of these must be 1
   AP_int m_numerator = 0; // any integer
   AP_int m_denominator = 1; // > 0
   
  public:
   AP_fraction() {
   }
   
   AP_fraction(AP_fraction && other) {
    m_numerator   = std::move(other.m_numerator);
    m_denominator = std::move(other.m_denominator);
   }
   
   AP_fraction(const AP_fraction & other) {
    m_numerator   = (other.m_numerator);
    m_denominator = (other.m_denominator);
   }
   
   AP_fraction & operator =(AP_fraction && other) {
    m_numerator   = std::move(other.m_numerator);
    m_denominator = std::move(other.m_denominator);
    return *this;
   }
   
   AP_fraction & operator =(const AP_fraction & other) {
    m_numerator   = (other.m_numerator);
    m_denominator = (other.m_denominator);
    return *this;
   }
   
   AP_fraction(const int & i) {
    m_numerator = AP_int(i);
   }
   
   AP_fraction(const AP_int & obj) {
    m_numerator = obj;
   }
   
   AP_fraction(const AP_int & numer, const AP_int & denom) {
    m_numerator = numer;
    m_denominator = denom;
    reduce_and_fix_denominator_sign();
   }
   
   AP_fraction operator * (const AP_fraction & other) const {
    AP_fraction result;
    result.m_numerator = m_numerator*other.m_numerator;
    result.m_denominator = m_denominator*other.m_denominator;
    result.reduce_and_fix_denominator_sign();
    return result;
   }
   
   AP_fraction operator / (const AP_fraction & other) const {
   //
   //  a      c       a*d
   // ---  / ---  = -----------
   //  b      d        b*c
    AP_fraction result;
    result.m_numerator = m_numerator*other.m_denominator;
    result.m_denominator = m_denominator*other.m_numerator;
    result.reduce_and_fix_denominator_sign();
    return result;
   }
   
   AP_fraction operator + (const AP_fraction & other) const {
   //
   //  a      c       a*d + b*c
   // ---  + ---  = -----------
   //  b      d        b*d
   //            (not optimized)
//#warning "\"AP_fraction operator + (const AP_fraction & other)\" is not optimized"
    AP_fraction result;
    result.m_numerator = m_numerator*other.m_denominator + other.m_numerator*m_denominator;
    result.m_denominator = m_denominator*other.m_denominator;
    result.reduce_and_fix_denominator_sign();
    return result;
   }
   
   AP_fraction operator - (const AP_fraction & other) const {
   //
   //  a      c       a*d - b*c
   // ---  - ---  = -------------
   //  b      d          b*d
   //            (not optimized)
//#warning "\"AP_fraction operator - (const AP_fraction & other)\" is not optimized"
    AP_fraction result;
    result.m_numerator = m_numerator*other.m_denominator - other.m_numerator*m_denominator;
    result.m_denominator = m_denominator*other.m_denominator;
    result.reduce_and_fix_denominator_sign();
    return result;
   }
   
   const AP_fraction operator -= (const AP_fraction & other) {
    return *this = *this - other;
   }
   
   const AP_fraction operator += (const AP_fraction & other) {
    return *this = *this + other;
   }
   const AP_fraction operator *= (const AP_fraction & other) {
    return *this = *this * other;
   }
   const AP_fraction operator /= (const AP_fraction & other) {
    return *this = *this / other;
   }
   
   bool operator == (const AP_fraction & other) const { // always reduced
    return (m_numerator == other.m_numerator) && (m_denominator == other.m_denominator);
   }
   
   bool operator <= (const AP_fraction & other) const {
    if (operator ==(other))
     return true;
    return operator <(other);
   }
   
   bool reduce_and_fix_denominator_sign() {
    if (m_denominator < 0) {
     m_denominator = -m_denominator;
     m_numerator   = -m_numerator;
    }
    AP_int GCD = m_numerator.GCD(m_denominator);
    if (GCD == 1)
     return false;
    m_numerator /= GCD;
    m_denominator /= GCD;
    return true;
   }
   
   bool operator < (const AP_fraction & other) const {
   //
   //  a      c            a*d     b*c              
   // ---  < ---    <==>   ----- < ------   <==> a*d < b*c
   //  b      d            b*d     b*d
    return (m_numerator*other.m_denominator) < (m_denominator*other.m_numerator);
    //if ((m_numerator < 0)) {
    // if (other.m_numerator >= 0)
    //  return true;
    // 
    //} else {
    //}
   }
   
   bool operator > (const AP_fraction & other) const {
    if (operator ==(other))
     return false;
    return ! operator <(other);
   }
   
   bool operator >= (const AP_fraction & other) const {
    if (operator ==(other))
     return true;
    return operator >(other);
   }
   
   bool operator != (const AP_fraction & other) const {
    return ! operator == (other);
   }
   
   AP_fraction operator -() const {
    return AP_fraction(-m_numerator, m_denominator);
   }
   
   AP_fraction abs() const {
    if (m_numerator >= 0)
     return *this;
    AP_fraction result(*this);
    result.m_numerator = -m_numerator;
    return result;
   }

#warning "This function has not passed tests: AP_fraction AP_sin(const AP_fraction & max_allowed_mistake) const"
   AP_fraction AP_sin(const AP_fraction & max_allowed_mistake) const {
     // source: https://en.wikipedia.org/wiki/Taylor%27s_theorem
     // Taylor's theorem
     // Pk(x) = f(a) + f'(a)(x-a) + ... + f^((k))(a)/(k!) * (x-a)^k
     // Rk(x) = f(x) - Pk(x)
     // Rk(x) = f^((k+1))(point) / ((k+1)!) * (x-a) ^ (k+1)
     // point between a and x
     // f = sin, f' = cos, f'' = -sin, f''' = -cos, f''''=f^((4)) = sin, ...
     // |f^((...))(...)| <= 1
     //==============================
     //           |x-a|^(k+1)
     // |Rk| <=  —————————————
     //              (k+1)!
     //==============================
     // a = 0 , f(a) = 0, f'(a) = 1, f''(a) = 0 , f'''(a) = -1, ...
     // sin(0)       =  0
     // sin'(0)      =  1
     // sin''(0)     =  0
     // sin'''(0)    = -1
     // sin''''(0)   =  0
     // sin'''''(0)  =  1
     //              =  0
     //              = -1
     //              =  0
     //              =  1
     //              =  ...
    if (max_allowed_mistake <= 0)
     throw  std::runtime_error("max_allowed_mistake must be > 0");
    AP_int k = 1;
    AP_fraction absX = abs();
    AP_fraction absXPowKplus1 = absX*absX;
    AP_int kPlus1Factorial=2;
    AP_fraction AbsRkNotMoreThan = absXPowKplus1 / kPlus1Factorial;
    while (AbsRkNotMoreThan > max_allowed_mistake) {
     k += 1;
     absXPowKplus1   *= absX;
     kPlus1Factorial *= (k+1);
     AbsRkNotMoreThan = absXPowKplus1 / kPlus1Factorial;
    }
    int8_t derivatives[] = {0,1,0,-1};    // at zero
    AP_fraction sum = 0;
    AP_fraction xpowi = *this;
    AP_int ifactorial = 1;
    int8_t derivative;
    for (AP_int i = 1 ;  k >= i ; ++i)  { //  for i in range (1,k+1):
     derivative = derivatives[static_cast<size_t>(i%4)];
     sum += (xpowi * derivative) / ifactorial;
     xpowi *= *this;
     ifactorial *= (i+1);
    }
    return sum;
   }
   
#warning "This function has not passed tests: AP_fraction AP_cos(const AP_fraction & max_allowed_mistake) const"
   AP_fraction AP_cos(const AP_fraction & max_allowed_mistake) const {
    // source: https://en.wikipedia.org/wiki/Taylor%27s_theorem
    // Taylor's theorem
    // Pk(x) = f(a) + f'(a)(x-a) + ... + f^((k))(a)/(k!) * (x-a)^k
    // Rk(x) = f(x) - Pk(x)
    // Rk(x) = f^((k+1))(point) / ((k+1)!) * (x-a) ^ (k+1)
    // point between a and x
 
    // f = cos, f' = -sin, f'' = -cos, f''' = sin, f''''=f^((4)) = cos, ...
    // |f^((...))(...)| <= 1
    // ==============================
    //           |x-a|^(k+1)
    // |Rk| <=  —————————————
    //              (k+1)!
    // ==============================
    // a = 0 , f(a) = 1, f'(a) = 0, f''(a) = -1 , f'''(a) = 0, ...
    // cos(0)       =  1
    // cos'(0)      =  0
    // cos''(0)     = -1
    // cos'''(0)    =  0
    // cos''''(0)   =  1
    // cos'''''(0)  =  0
    //              = -1
    //              =  0
    //              =  1
    //              =  0
    //              =  ...
    if (max_allowed_mistake <= 0)
     throw std::runtime_error("max_allowed_mistake must be > 0");
    AP_int k = 1;
    AP_fraction absX = abs();
    AP_fraction absXPowKplus1=absX*absX;
    AP_int kPlus1Factorial=2;
    AP_fraction AbsRkNotMoreThan = absXPowKplus1 / kPlus1Factorial;
    while (AbsRkNotMoreThan > max_allowed_mistake) {
     k += 1;
     absXPowKplus1   *= absX;
     kPlus1Factorial *= (k+1);
     AbsRkNotMoreThan = absXPowKplus1 / kPlus1Factorial;
    }
    int8_t derivatives[] = {1,0,-1,0};    // at zero
    AP_fraction sum(0);
    sum += 1 ;   // cos(0) = f(a) = 1
    AP_fraction xpowi(*this);
    AP_int ifactorial = 1;
    AP_int derivative;
    for (AP_int i = 1 ; k >= i ; ++i) { //for i in range (1,k+1)
     derivative = derivatives[static_cast<size_t>(i%4)];
     sum += (xpowi * derivative) / ifactorial;
     xpowi *= *this;
     ifactorial *= (i+1);
    }
    return sum;
   }
   
   AP_fraction AP_sqrt(const AP_fraction max_allowed_mistake) const {
    // binary search
    if (operator == (0))
     return 0;
    if (*this < 0)
     throw std::runtime_error("sqrt of <0");
    if (max_allowed_mistake <= 0)
     throw std::runtime_error("max_allowed_mistake <= 0");
    AP_fraction  sqrtmin = 0; 
    AP_fraction  sqrtmax = 1;
    while (sqrtmax*sqrtmax < *this)
     sqrtmax *= 2;
    if (sqrtmax * sqrtmax == *this)
     return sqrtmax;
    AP_fraction sqrtnext;
    while (true) {
     sqrtnext = (sqrtmin+sqrtmax) / 2;
     if (sqrtnext*sqrtnext == *this)
      return sqrtnext;
     if (sqrtnext * sqrtnext > *this)
      sqrtmax = sqrtnext;
     else
      sqrtmin = sqrtnext;
     if (sqrtmax-sqrtmin < max_allowed_mistake)
      return sqrtmin;
    }
   }
   
   std::string AP_to_string(const AP_int & digits) const {
    if (digits <= 0)
     throw std::runtime_error("digits must be positive integer");
    AP_fraction absX = abs();
    AP_fraction x10PowDigits = absX * AP_int(10).to_power(digits);
    AP_int whole = absX.m_numerator / absX.m_denominator;
    std::string result = "";
    if (*this < 0)
     result = "-";
    result += whole.to_string();
    result += ".";
    AP_int remainder = x10PowDigits.m_numerator / x10PowDigits.m_denominator % AP_int(10).to_power(digits);
    std::string resplus= remainder.to_string();
    while (digits > resplus.length())
     resplus = "0" + resplus;
    result += resplus;
    return result;
   }
   
   friend std::ostream & operator << (std::ostream & out, const AP_fraction & frac);
 };
 
 AP_fraction operator -(int i, const AP_fraction & frac) {
  return AP_fraction(i).operator -(frac);
 }
 
 AP_fraction operator *(int i, const AP_fraction & frac) {
  return AP_fraction(i).operator *(frac);
 }
 
 std::ostream & operator << (std::ostream & out, const AP_fraction & frac) {
  return (out << "( " << frac.m_numerator.to_string() << " / " << frac.m_denominator.to_string() << " )");
 }
}

#endif //#ifndef _zvC9_AP_FRACTION_H_

