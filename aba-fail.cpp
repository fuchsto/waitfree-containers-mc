
#include <assert.h>
#include <pthread.h>

#include <mc/atomic.h>

::mc::Atomic<size_t> i = 0;

void * thread( void * x ) {
  size_t exp = 0; 
  if (i.compare_exchange_strong(exp, 10)) {
    
  }
  return NULL;
}

int main() {
  pthread_t tid;
  pthread_create( &tid, NULL, thread, NULL );

  size_t exp_b = i.load(); 
  i.compare_exchange_strong(exp_b, 1); 
  size_t exp_a = i.load(); 
  i.compare_exchange_strong(exp_b, 0); 

  pthread_join( tid, NULL );

  assert( i == 35 );

  return i;
}

