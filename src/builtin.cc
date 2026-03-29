#include <cstddef>
#include <cstdint>

extern "C"
{
    void* memset( void* ptr, int value, size_t num )
    {
        auto p = reinterpret_cast<uint8_t*>( ptr );
        while ( num-- )
        {
            *p++ = (unsigned char)value;
        }
        return ptr;
    }

    void* memcpy( void* dst, const void* src, size_t n )
    {
        auto d = reinterpret_cast<uint8_t*>( dst );
        auto s = reinterpret_cast<const uint8_t*>( src );

        while ( n-- )
            *d++ = *s++;

        return dst;
    }

    void* memmove( void* dst, const void* src, size_t n )
    {
        auto d = reinterpret_cast<uint8_t*>( dst );
        auto s = reinterpret_cast<const uint8_t*>( src );

        if ( d < s )
        {
            while ( n-- )
                *d++ = *s++;
        }
        else if ( d > s )
        {
            d += n;
            s += n;
            while ( n-- )
                *--d = *--s;
        }

        return dst;
    }
}
