#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <utility>
#include <stdexcept>

#include "AP_math/AP_line2d.h"

int main(int argc, char ** argv)
{
 //std::vector<int> v;
 //v.resize(10);
 //v.resize(0);
 //std::cerr << "v.resize(0) --> OK\n";
 //return 0;
 //std::cout << (-128)%(5) << std::endl;
 std::string  a, b;
 if (argc == 3) {
  a = argv[1];
  b = argv[2];
 } else {
 (std::cout << "a  b: ").flush();
  std::cin >> a >> b;
 }
 zvC9::AP_int A(a), B(b);
 std::cout << "A's   digits: " << A.digits_le() << std::endl;
 std::cout << "A's   negative: " << A.isNegative() << std::endl;
 std::cout << "B's   digits: " << B.digits_le() << std::endl;
 std::cout << "B's   negative: " << B.isNegative() << std::endl;
 std::cout << "A+B's digits: " << (A+B).digits_le() << std::endl;
 std::cout << "A+B's neg: " << (A+B).isNegative() << std::endl;
 std::cout << "A-B's digits: " << (A-B).digits_le() << std::endl;
 std::cout << "A-B's neg: " << (A-B).isNegative() << std::endl;
 std::cout << "A*B's digits: " << (A*B).digits_le() << std::endl;
 std::cout << "A*B's neg: " << (A*B).isNegative() << std::endl;
 std::cout << "A/B's digits: " << (A/B).digits_le() << std::endl;
 std::cout << "A/B's neg: " << (A/B).isNegative() << std::endl;
 std::cout << "A%B's digits: " << (A%B).digits_le() << std::endl;
 std::cout << "A%B's neg: " << (A%B).isNegative() << std::endl;
 
 std::cout << "A  : " << A.to_string() << std::endl;
 std::cout << "B  : " << B.to_string() << std::endl;
 std::cout << "A+B: " << (A+B).to_string() << std::endl;
 std::cout << "A-B: " << (A-B).to_string() << std::endl;
 std::cout << "A*B: " << (A*B).to_string() << std::endl;
 std::cout << "A/B: " << (A/B).to_string() << std::endl;
 std::cout << "A%B: " << (A%B).to_string() << std::endl;
 std::cout << "A**B: " << (A.to_power(B)).to_string() << std::endl;
 //return 0;
 zvC9::AP_fraction f(A);
 f /= B;
 std::cout << "f = " << f << std::endl;
 //zvC9::AP_fraction mistake(1,zvC9::AP_int(10).to_power(3));
 zvC9::AP_fraction mistake(1,2);
 std::cout << "f.AP_sin( " << mistake << " ) " << f.AP_sin(mistake) << std::endl;
 std::cout << "f.AP_cos( " << mistake << " ) " << f.AP_cos(mistake) << std::endl;
 return 0;
}


