
#include <assert.h>
#include <pthread.h>

int i = 33;

void* thread( void *x ) {
    i++;
    return NULL;
}

int main() {
    pthread_t tid;
    pthread_create( &tid, NULL, thread, NULL );

    i++;

    pthread_join( tid, NULL );
    assert( i == 35 );
    return i;
}

