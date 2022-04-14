#include <sstream> // required for 'stringstream'
#include <iostream> // required for 'cout'
#include <iomanip> // required for 'setfill'
#include "ripemd160.c"
using namespace std;
string uint8_to_hex_string(const uint8_t *v, const size_t s) {
  stringstream ss;

  ss << hex << setfill('0');

  for (int i = 0; i < s; i++) {
    ss << hex << setw(2) << static_cast<int>(v[i]);
  }

  return ss.str();
}

int main(int argc, char* argv[]) {
  size_t msglen = 32;
  uint8_t msg[msglen];

  size_t hashlen = 20;
  uint8_t hash[hashlen];

  string str = argv[1];

  memcpy(msg, str.c_str(), sizeof(msg));

  ripemd160(msg, msglen, hash);

  string hexstr = uint8_to_hex_string(hash, hashlen);

  cout << hexstr << endl;
  // e6d64710683e82853342e24f011bc77af21884ad

  return 0;
}
