/++
 +/
module blake3;

@safe:

@safe struct BLAKE3 {
pure nothrow @nogc:
    void start() @trusted => blake3_hasher_init(&_hasher);

    void put(scope const(ubyte)[] data...) @trusted
		=> blake3_hasher_update(&_hasher, data.ptr, data.length);

    ubyte[32] finish() @trusted {
		typeof(return) result;
		blake3_hasher_finalize(&_hasher, result.ptr, result.length);
        return result;
    }
	private blake3_hasher _hasher;
}

///
version (none)
@safe pure unittest {
	import std.stdio : writeln;
	BLAKE3 h;
	h.start();
	debug writeln(h.finish);
	debug writeln(emptyHash);
	assert(h.finish == emptyHash);
}

private static immutable ubyte[32] emptyHash = [
    0xAF, 0x13, 0x49, 0xB9, 0xBC, 0xC1, 0xA4, 0x31,
    0xAD, 0x4C, 0x23, 0x72, 0x3E, 0xFB, 0xCB, 0xB4,
    0xA4, 0xF2, 0x75, 0xAA, 0x41, 0x8B, 0x32, 0xD1,
    0xA7, 0xF0, 0xD9, 0xD3, 0x47, 0x3E, 0x96, 0xF9
];

import core.stdc.stdint : uint8_t, uint32_t, uint64_t;

// Copied from BLAKE3/c/blake3.h
extern(C) pure nothrow @nogc {
enum BLAKE3_VERSION_STRING = "1.5.1";
enum BLAKE3_KEY_LEN = 32;
enum BLAKE3_OUT_LEN = 32;
enum BLAKE3_BLOCK_LEN = 64;
enum BLAKE3_CHUNK_LEN = 1024;
enum BLAKE3_MAX_DEPTH = 54;

// This struct is a private implementation detail. It has to be here because
// it's part of blake3_hasher below.
struct blake3_chunk_state {
  uint32_t[8] cv;
  uint64_t chunk_counter;
  uint8_t[BLAKE3_BLOCK_LEN] buf;
  uint8_t buf_len;
  uint8_t blocks_compressed;
  uint8_t flags;
}

struct blake3_hasher {
  uint32_t[8] key;
  blake3_chunk_state chunk;
  uint8_t cv_stack_len;
  // The stack size is MAX_DEPTH + 1 because we do lazy merging. For example,
  // with 7 chunks, we have 3 entries in the stack. Adding an 8th chunk
  // requires a 4th entry, rather than merging everything down to 1, because we
  // don't know whether more input is coming. This is different from how the
  // reference implementation does things.
  uint8_t[(BLAKE3_MAX_DEPTH + 1) * BLAKE3_OUT_LEN] cv_stack;
}

const(char) *blake3_version();
void blake3_hasher_init(blake3_hasher *self);
void blake3_hasher_init_keyed(blake3_hasher *self, const uint8_t[BLAKE3_KEY_LEN] key);
void blake3_hasher_init_derive_key(blake3_hasher *self, const char *context);
void blake3_hasher_init_derive_key_raw(blake3_hasher *self, const void *context,
                                                  size_t context_len);
void blake3_hasher_update(blake3_hasher *self, const void *input,
                                     size_t input_len);
void blake3_hasher_finalize(const blake3_hasher *self, uint8_t *out_, size_t out_len);
void blake3_hasher_finalize_seek(const blake3_hasher *self, uint64_t seek,
                                            uint8_t *out_, size_t out_len);
void blake3_hasher_reset(blake3_hasher *self);
}
