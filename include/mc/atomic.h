#ifndef __MC__ATOMIC_H__
#define __MC__ATOMIC_H__

#ifdef _MC__SIMULATE_STDATOMIC
#include <mutex>
#else
#include <atomic>
#endif

namespace mc {

#ifndef _MC__SIMULATE_STDATOMIC

/**
 * @brief Alias for ::std::atomic<T>.
 */
template<typename T>
  using Atomic = ::std::atomic<T>;

#else

/**
 * @brief Custom blocking emulation of std::atomic. 
 */
template<typename T>
class Atomic
{
private: 

  typedef ::mc::Atomic<T> self_t; 

private: 

  mutable ::std::mutex _mutex; 
  T _value; 

public: 

  Atomic() = default; 

  Atomic(T desired) : _value(desired) {
  // {{{
  } // }}}

  T load() const {
  // {{{
    _mutex.lock(); 
    T tmp = _value; 
    _mutex.unlock(); 
    
    return tmp; 
  } // }}}

  void store(const T & v) {
  // {{{
    _mutex.lock(); 
    _value = v; 
    _mutex.unlock(); 
  } // }}}

  bool is_lock_free() const { 
  // {{{
    return false; 
  } // }}}

  operator T () const { 
  // {{{
    return load(); 
  } // }}}

  T exchange(T desired) {
  // {{{
    _mutex.lock(); 
    T old  = _value; 
    _value = desired; 
    _mutex.unlock(); 

    return old; 
  } // }}}

  bool compare_exchange_strong(T & expected, T desired) {
  // {{{
    bool success = false; 
    
    _mutex.lock(); 
    if (_value == expected) {
      _value  = desired; 
      success = true; 
    }
    else {
      expected = _value; 
    }
    _mutex.unlock(); 

    return success; 
  } // }}}

  bool compare_exchange_weak(T & expected, T desired) {
  // {{{
    return compare_exchange_strong(expected, desired); 
  } // }}}
  
  T operator=(T desired) 
  { // {{{
    store(desired); 
    return desired; 
  } // }}}

public: 

  /**
   * @brief Atomic variables are not CopyAssignable, forbid 
   *        assignment operator on class type. 
   */
  self_t & operator=(const self_t &) = delete; 

  /**
   * @brief Atomic variables are not CopyAssignable, forbid 
   *        copy constructor. 
   */
  Atomic(const self_t &) = delete;

};

#endif // MC__STDATOMIC

} // namespace mc

#endif // __MC__ATOMIC_H__

