
#include <mc/assert.h>
#include <mc/atomic.h>

int main() {

  ::mc::Atomic<int> a; 

  a.store(10); 

  int exp = 10; 
  MC_ASSERT(a.compare_exchange_strong(exp, 35)); 

  MC_ASSERT( a == 35 );

  return 0;
}

