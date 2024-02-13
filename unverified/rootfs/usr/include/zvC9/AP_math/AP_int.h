#ifndef _zvC9_AP_INT_H_
#define _zvC9_AP_INT_H_

#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <utility>
#include <stdexcept>

namespace zvC9 {
 template<typename uint_type> std::string toString(uint_type ui) {
  if (ui == 0)
   return "0";
  std::string result = "";
  while (ui > 0) {
   std::string s;
   char c;
   s = ".";
   c = static_cast<char>((ui%10)+'0');
   s[0] = c;
   s[1] = 0;
   result = s + result;
   ui /= 10;
  }
  return result;
 }
 
 template <typename digit_t, typename double_digit_t, uint64_t base, uint64_t digit_bits>
    class AP_int_implementation {
  protected:
   std::vector<digit_t> m_digits; // wrong old comment: base q=256, el (least significant digits 1st, little endian)
   bool m_negative = false;
  public:
   AP_int_implementation() {}
   
   AP_int_implementation(AP_int_implementation && other) {
    m_negative = other.m_negative;
    m_digits = std::move(other.m_digits);
   }
   
   AP_int_implementation(const AP_int_implementation & other) {
    m_negative = other.m_negative;
    m_digits = (other.m_digits);
   }
   
   AP_int_implementation & operator=(AP_int_implementation && other) {
    m_negative = other.m_negative;
    m_digits = std::move(other.m_digits);
    return *this;
   }
   
   AP_int_implementation & operator=(const AP_int_implementation & other) {
    m_negative = other.m_negative;
    m_digits = (other.m_digits);
    return *this;
   }
   
   template<typename uint_type> AP_int_implementation(uint_type i) {
    if (i == 0)
     return;
    if (i < 0) {
     m_negative = true;
     digit_t digit;
     while (i != 0) {
      if (i % base == 0)
       digit = 0;
      else
       digit = static_cast<digit_t>(-(i%base));
      m_digits.push_back(digit);
      i /= base;
     }
    } else {
     m_negative = false;
     digit_t digit;
     while (i != 0) {
      if (i % base == 0)
       digit = 0;
      else
       digit = static_cast<digit_t>((i%base));
      m_digits.push_back(digit);
      i /= base;
     }
    }
   }
   
   bool operator <(const AP_int_implementation & other) const {
    if (*this == other)
     return false;
    if (m_negative && ! other.m_negative)
     return true;
    if ((! m_negative) && other.m_negative)
     return false;
    if (positive_greater_than(other)) // abs() > other.abs()
     return m_negative;
    // else. abs() < other.abs()
    return !m_negative;
   }
   
   bool operator >= (const AP_int_implementation & other) const {
    return ! operator <(other);
   }
   
   bool positive_greater_than(const AP_int_implementation & other) const { // abs > other abs
    //if (is0()) {
    //  return false;
    //}
    //if (other.is0()) {
    // return true;
    //}
    typename std::vector<digit_t>::size_type l = m_digits.size();
    typename std::vector<digit_t>::size_type other_l = other.m_digits.size();
    //if (m_digits.size() > other.m_digits.size())
    // return true;
    //if (m_digits.size() < other.m_digits.size())
    // return false;
    //typename std::vector<digit_t>::size_type l = m_digits.size();
    //if (l == 0) // *this == other
    // return false;
    if (l > other_l) {
     for (typename std::vector<digit_t>::size_type i = l-1 ; i >= other_l ; --i) {
      if (m_digits[i] != 0)
       return true;
     }
    } else {
     if (l < other_l) {
      for (typename std::vector<digit_t>::size_type i = other_l-1 ; i >= l ; --i) {
       if (other.m_digits[i] != 0)
        return false;
      }
     }
    }
    typename std::vector<digit_t>::size_type i = std::min(l,other_l);
    if (i != 0) {
     for (--i ; ; --i) {
      if (other.m_digits[i] < m_digits[i])
       return true;
      if (other.m_digits[i] > m_digits[i])
       return false;
      if (i == 0)
       break;
     }
    }
    return false; // abs == abs
   }
   
   AP_int_implementation operator ++(int) {
    AP_int_implementation result(*this);
    *this += 1;
    return result;
   }
   
   AP_int_implementation & operator ++() {
    *this += 1;
    return *this;
   }
   
   AP_int_implementation operator --(int) {
    AP_int_implementation result(*this);
    *this -= 1;
    return result;
   }
   
   AP_int_implementation & operator --() {
    *this -= 1;
    return *this;
   }
   
   AP_int_implementation positive_add(const AP_int_implementation & other) const {
    AP_int_implementation sum;
    sum.m_digits.clear();
    digit_t additional = 0;
    typename std::vector<digit_t>::size_type l = m_digits.size();
    typename std::vector<digit_t>::size_type maxl = l;
    if (maxl < other.m_digits.size())
     maxl = other.m_digits.size();
    typename std::vector<digit_t>::size_type other_l = other.m_digits.size();
    for (typename std::vector<digit_t>::size_type i = 0 ; i < maxl ; ++i) {
     double_digit_t curr;
     digit_t next_digit;
     curr = additional;
     if (i < l)
      curr += m_digits[i];
     if (i < other_l)
      curr += other.m_digits[i];
     next_digit = static_cast<digit_t>(curr & (base -1));  // next_digit = static_cast<digit_t>(curr % base);
     curr >>= digit_bits; //  curr /= base
     sum.m_digits.push_back(next_digit);
     additional = static_cast<digit_t>(curr & (base -1));
    }
    if (additional != 0) // > 0
     sum.m_digits.push_back(additional);
    return sum;
   }
   
   bool is0() const {
    typename std::vector<digit_t>::size_type l = m_digits.size();
    if (l == 0)
     return true;
    for (typename std::vector<digit_t>::size_type i = 0 ; i < l ; ++i) {
     if (m_digits[i] != 0)
      return false;
    }
    return true;
   }
  
// DANGEROUS code: 
//   bool operator==(const AP_int_implementation & other) const {
//    if (is0()) {
//     if (other.is0())
//      return true;
//     else
//      return false;
//    }
//    if (other.is0())
//     return false;
//    if (m_negative != other.m_negative)
//     return false;
//    int l = m_digits.size();
//    if (l != other.m_digits.size())
//     return false;
//    for (int i = 0 ; i  < l ; ++i)
//     if (m_digits[i] != other.m_digits[i])
//      return false;
//    return true;
//   }
   
   void delete_leading_zeroes() {
    typename std::vector<digit_t>::size_type l = m_digits.size();
    typename std::vector<digit_t>::size_type i;
    for (i = l ; i > 0  ; --i)
     if (m_digits[i-1] != 0)
      break;
    m_digits.resize(i);
   }
   
   AP_int_implementation positive_subtract_less_from_greater(const AP_int_implementation & other) const{ // *this - other
    if (operator==(other))
     return AP_int_implementation(0);
    if (!positive_greater_than(other))
     return other.positive_subtract_less_from_greater(*this);
    AP_int_implementation result;
    result.m_digits.clear();
    digit_t minus1 = 0;
    typename std::vector<digit_t>::size_type l = m_digits.size();
    typename std::vector<digit_t>::size_type other_l = other.m_digits.size();
    for (typename std::vector<digit_t>::size_type i = 0 ; i < l ; ++i) {
     double_digit_t subt;
     if (i < other_l)
      subt = other.m_digits[i];
     else
      subt = 0;
     subt += minus1;
     digit_t next_digit;
     if (m_digits[i] >= subt) {
      next_digit = static_cast<digit_t>(static_cast<double_digit_t>(m_digits[i])-subt);
      minus1 = 0;
     } else {
      next_digit = static_cast<digit_t>((static_cast<double_digit_t>(base) + m_digits[i])-subt);
      minus1 = 1;
     }
     result.m_digits.push_back(next_digit);
    }
    result.delete_leading_zeroes();
    return result;
   }
   
   AP_int_implementation operator+(const AP_int_implementation & other) const {
    AP_int_implementation result;
    if (m_negative == other.m_negative) {
     result = positive_add(other);
     result.m_negative = m_negative;
     return result;
    }
    result = positive_subtract_less_from_greater(other);
    if (positive_greater_than(other)) {
     result.m_negative = m_negative;
    } else {
     result.m_negative = other.m_negative;
    }
    return result;
   }
   
   AP_int_implementation operator-(const AP_int_implementation & other) const {
    AP_int_implementation result;
    if (m_negative != other.m_negative) {
     result = positive_add(other);
     result.m_negative = m_negative;
     return result;
    }
    result = positive_subtract_less_from_greater(other);
    if (positive_greater_than(other)) {
     result.m_negative = m_negative;
    } else {
     result.m_negative = other.m_negative;
    }
    return result;
   }
   
   AP_int_implementation & operator -= (const AP_int_implementation & other) {
    *this = *this - other;
    return *this;
   }
   
   AP_int_implementation & operator += (const AP_int_implementation & other) {
    *this = *this + other;
    return *this;
   }
   
   AP_int_implementation & operator *= (const AP_int_implementation & other) {
    *this = *this * other;
    return *this;
   }
   
   AP_int_implementation & operator /= (const AP_int_implementation & other) {
    *this = *this / other;
    return *this;
   }
   
   AP_int_implementation & operator %= (const AP_int_implementation & other) {
    *this = *this % other;
    return *this;
   }
   
   AP_int_implementation operator *(const AP_int_implementation & other) const {
    if (is0())
     return AP_int_implementation(0);
    if (other.is0())
     return AP_int_implementation(0);
    AP_int_implementation result;
    typename std::vector<digit_t>::size_type l = m_digits.size();
    typename std::vector<digit_t>::size_type other_l = other.m_digits.size();
    for (typename std::vector<digit_t>::size_type i =  0 ; i < l ; ++i) {
     typename std::vector<digit_t>::size_type j ;
     double_digit_t add = 0;
     digit_t new_digit;
     for (j=0 ; j < other_l ; ++j) {
      while (result.m_digits.size() <= i+j) {
       result.m_digits.push_back(0);
      }
      add += result.m_digits[i+j];
      add += static_cast<double_digit_t>(m_digits[i])*other.m_digits[j];
      new_digit = static_cast<digit_t>(add & (base-1)); // % base
      result.m_digits[i+j] = new_digit;
      add >>= digit_bits; // /= base
     }
     if (add != 0) {
      while (result.m_digits.size() <= i+j) {
       result.m_digits.push_back(0);
      }
      new_digit = static_cast<digit_t>(add);
      result.m_digits[i+j] = new_digit;
     }
    }
    if (m_negative != other.m_negative)
     result.m_negative = true;
    return result;
   }
   
  protected:
   digit_t nonnegative_binary_divide_to_uint8(const AP_int_implementation & other) const {
    double_digit_t minval = 0;
    double_digit_t maxval = base;
    double_digit_t midval;
    while (true) {
     if (other * minval == *this)
      return static_cast<digit_t>(minval);
     if (other * maxval == *this)
      return static_cast<digit_t>(maxval);
     midval = (minval+maxval)/2;
     if (other * midval == *this)
      return static_cast<digit_t>(midval);
     if (positive_greater_than(other * midval)) // *this / other > midval
      minval = midval;
     else // *this / other < midval
      maxval = midval;
     if (maxval - minval <= 1)
      return minval;
    }
   }
  public:
   // part < other => part <= other-1
   // part -> part * 256 + val , val <= 255
   // part <= (other-1)*256+255 = 256*other-1
   // part < 256*other, part/other < 256
   
   std::pair<AP_int_implementation, AP_int_implementation> divide_with_remainder(const AP_int_implementation & other) const { // *this = first*other + second, second < abs(other)
    if (other.is0())
     throw std::runtime_error("Division by zero");
    if (is0())
     return std::make_pair(AP_int_implementation(0), AP_int_implementation(0));
    if (other.positive_greater_than(*this)) {
     if (!m_negative)
      return std::make_pair(AP_int_implementation(0), *this);
     else
      return std::make_pair(AP_int_implementation(-1), other+*this);
    }
    AP_int_implementation part;
    AP_int_implementation otherAbs(other.abs());
    
    typename std::vector<digit_t>::size_type other_l = other.m_digits.size();
    typename std::vector<digit_t>::size_type l       = m_digits.size();
    typename std::vector<digit_t>::size_type pos     = l;
    while (otherAbs.positive_greater_than(part)) {
     part.m_digits.insert(part.m_digits.begin(), m_digits[pos-1]);
     --pos;
    }
    AP_int_implementation quotient;
    //AP_int_implementation remainder;
    digit_t next_digit;
    while (true) {
     next_digit = part.nonnegative_binary_divide_to_uint8(otherAbs);
     //cerr << "(...).nonnegative_binary_divide_to_uint8(" << "(...)" << ") = " << (int)(next_digit) << endl;
     //cerr << (std::string)(part) << ".nonnegative_binary_divide_to_uint8(" << (std::string)other << ") = " << (int)next_digit << endl;
     //cerr << (part).digits_le() << ".nonnegative_binary_divide_to_uint8(" << other.digits_le() << ") = " << (int)next_digit << endl;
     quotient.m_digits.insert(quotient.m_digits.begin(), next_digit);
     part -= otherAbs*next_digit;
     if (pos != 0) {
      part.m_digits.insert(part.m_digits.begin(), m_digits[pos-1]);
     --pos;
     } else {
      break;
     }
    }
    if (m_negative) {
     if (!part.is0()) {
      quotient += 1;
      part = otherAbs - part;
     }
     if (!other.m_negative)
      quotient.m_negative = 1;
    } else {
     if (other.m_negative)
      quotient.m_negative = 1;
    }
    return std::make_pair(quotient, part);
   }
   
   AP_int_implementation abs() const {
    if (m_negative) {
     AP_int_implementation result(*this);
     result.m_negative = false;
     return result;
    }
    return *this;
   }
   
   AP_int_implementation operator/(const AP_int_implementation & other) const {
    return divide_with_remainder(other).first;
   }
   
   AP_int_implementation operator%(const AP_int_implementation & other) const {
    return divide_with_remainder(other).second;
   }
   
   std::string digits_le() const {
    std::string result = "(";
    typename std::vector<digit_t>::size_type l = m_digits.size();
    for (typename std::vector<digit_t>::size_type i = 0 ; i < l ; ++i) {
     result += toString(m_digits[i]);
     if (i != m_digits.size()-1)
      result += ", ";
    }
    result += ")";
    return result;
   }
   
   explicit operator digit_t() const {
    if (is0())
     return 0;
    if (!m_negative)
     return m_digits[0];
    if (m_digits[0] == 0)
     return 0;
    return static_cast<digit_t>(base-m_digits[0]);
   }
   
   explicit operator typename std::vector<digit_t>::size_type() const {
    if (is0())
     return 0;
    if (!m_negative)
     return m_digits[0];
    if (m_digits[0] == 0)
     return 0;
    return static_cast<digit_t>(base-m_digits[0]);
   }
   
   /* DRAFT for optimization (also, optimize * and / operators and may be, + -, ++, --)
   size_t compute_number_of_decimal_digits_and_minus_in_decimal_string_representation_and_optionally_generate_string(std::string & result, bool only_compute = true) const {
    if (is0()) {
     if (only_compute)
      return 1;
     result = "0";
     return 1;
    }
    //std::string result = "";
    AP_int_implementation val(this -> abs());
    while (!val.is0()) {
     result = (char)(static_cast<digit_t>(val%10)+'0')+result;
     val /= 10;
    }
    if (m_negative)
     result = "-"+result;
    return result;
   }
   */
   
   explicit operator std::string() const {
    if (is0())
     return "0";
    std::string result = "";
    AP_int_implementation val(this -> abs());
    while (!val.is0()) {
     result = (char)(static_cast<digit_t>(val%10)+'0')+result;
     val /= 10;
    }
    if (m_negative)
     result = "-"+result;
    return result;
   }
   
   std::string to_string() const {
    return (std::string)(*this);
   }
   
   bool operator ==(const AP_int_implementation & other) const {
    if (is0())
     return other.is0();
    if (other.is0())
     return false;
    if (m_negative != other.m_negative)
     return false;
    if (m_digits.size() != other.m_digits.size())
     return false;
    typename std::vector<digit_t>::size_type l = m_digits.size();
    for (typename std::vector<digit_t>::size_type i = 0 ; i < l ; ++i)
     if (m_digits[i] != other.m_digits[i])
      return false;
    return true;
   }
   
   bool operator !=(const AP_int_implementation & other) const {
    return !((*this - other).is0());
   }
   
   AP_int_implementation(const std::string & decimal) {
    if (decimal.size() == 0)
     return;
    typename std::vector<digit_t>::size_type pos = 0;
    AP_int_implementation result ; // "will be abs(*this)"
    bool neg = false;
    if (decimal[0] == '-') {
     neg = true;
     pos = 1;
    }
    typename std::vector<digit_t>::size_type sz = decimal.size();
    for (typename std::vector<digit_t>::size_type i = pos ; i < sz; ++i) {
     result *= 10;
     result += (decimal[i]-'0');
    }
    m_negative = neg;
    m_digits = result.m_digits;
   }
   
   bool isNegative() const {
    if (is0())
     return false;
    return m_negative;
   }
   
   AP_int_implementation GCD(const AP_int_implementation & other) const { // greatest common divisor
    if (is0() && other.is0())
     throw std::runtime_error("Calculating GCD (greatest common divisor) of 0 and 0");
    if (is0())
     return other.abs();
    if (other.is0())
     return abs();
    AP_int_implementation val1, val2;
    if (positive_greater_than(other)) {
     val1 = abs();
     val2 = other.abs();
    } else {
     val2 = abs();
     val1 = other.abs();
    }
    //val1 >= val2;
    if (val1 == val2)
     return val1;
    // val1 > val2
    AP_int_implementation remainder;
    while (true) {
     remainder = val1 % val2;
     if (remainder == 0)
      return val2;
     val1 = val2;
     val2 = remainder;
    }
   }
   
   AP_int_implementation LCM(const AP_int_implementation & other) const { // least common multiple
    return (*this * other) / GCD(other);
   }
   
   AP_int_implementation operator - () const {
    AP_int_implementation result(*this);
    result.m_negative = !m_negative;
    return result;
   }
   
   bool operator <= (const AP_int_implementation & other) const {
    return (*this < other) || (*this == other);
   }
   
   bool operator > (const AP_int_implementation & other) const {
    return ! operator <= (other);
   }
   
   AP_int_implementation to_power(const AP_int_implementation & other) const {
    // result * base**power
    AP_int_implementation result(1), pow_base(*this), power(other);
    while (power != 0) {
     if (power % 2 == 0) {
      power /= 2;
      pow_base *= pow_base;
     } else {
      result *= pow_base;
      --power;
     }
    }
    return result;
   }
 };
 
 typedef AP_int_implementation<uint32_t, uint64_t, 4294967296ull, 32> AP_int;
 //#define AP_int_digit_type uint32_t
 //#define AP_int_base 4294967296ull
}

#endif //#ifndef _zvC9_AP_INT_H_

