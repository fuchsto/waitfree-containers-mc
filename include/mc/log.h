#ifndef __MC__LOG_H__
#define __MC__LOG_H__

#ifdef _MC__LOG
#include <iostream>
#define MC_LOG(msg) (::std::cout << (msg) << ::std::endl)

#else  // _MC__LOG
#define MC_LOG(msg) do { } while(0)

#endif // _MC__LOG

#endif // __MC__LOG_H__

