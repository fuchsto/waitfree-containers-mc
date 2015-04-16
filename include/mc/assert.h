#ifndef __MC__ASSERT_H__
#define __MC__ASSERT_H__

#ifdef _MC__NO_ASSERT
#define MC_ASSERT(exp) if (exp) {}
#define MC_ASSERT_MSG(exp, msg) if (exp) {}
#define MC_ASSERT_VAL(exp, val) if (exp) {}
#define MC_ASSERT_DEBUG(exp) if (exp) {}

#else  // !_MC__NO_ASSERT
#include<cassert>

#if defined(_MC__VERIFY) || defined(_MC__DEBUG_VERIFY)
#define MC_ASSERT(exp) assert(exp)
#define MC_ASSERT_MSG(exp, msg) assert(exp && msg)
#define MC_ASSERT_VAL(exp, val) assert(exp)

// MC_ASSERT_DEBUG is active in verification mode if explicitly enabled: 
#ifdef _MC__DEBUG_VERIFY
#define MC_ASSERT_DEBUG(exp) assert(exp)
#else
#define MC_ASSERT_DEBUG(exp) if (exp) {}
#endif

#else  		// !_MC__VERIFY && !_MC__DEBUG_VERIFY
#define MC_ASSERT(exp) assert(exp)
#define MC_ASSERT_MSG(exp, msg) assert(exp && msg)
#define MC_ASSERT_VAL(exp, val) do { \
  bool __AssertionValue__ = (exp); \
  if (!__AssertionValue__) { \
    MC_LOG("Assertion failed, value: " << val); \
  } assert(__AssertionValue__); \
} while(0)
#define MC_ASSERT_DEBUG(exp) assert(exp)

#endif 		// _MC__VERIFY

#endif // _MC__NO_ASSERT

#endif // __MC__ASSERT_H__

