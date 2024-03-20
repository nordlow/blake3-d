/** BLAKE3 wrapper around BLAKE3 C API.
 */
module blake3;

@safe:

/** BLAKE3 wrapper around BLAKE3 C API.
 */
@safe struct BLAKE3 {
pure nothrow @nogc:
    void start() @trusted => blake3_hasher_init(&_hasher);

    void put(scope const(ubyte)[] data...) @trusted
		=> blake3_hasher_update(&_hasher, data.ptr, data.length);

    ubyte[32] finish() const @trusted {
		typeof(return) result = void;
		blake3_hasher_finalize(&_hasher, result.ptr, result.length);
        return result;
    }
	private blake3_hasher _hasher;
}

/// verify digest of empty input
@safe pure nothrow @nogc unittest {
	// output of b3sum on empty file:
	static immutable ubyte[digestLength] expected = [
		0xaf, 0x13, 0x49, 0xb9, 0xf5, 0xf9, 0xa1, 0xa6,
	    0xa0, 0x40, 0x4d, 0xea, 0x36, 0xdc, 0xc9, 0x49,
	    0x9b, 0xcb, 0x25, 0xc9, 0xad, 0xc1, 0x12, 0xb7,
		0xcc, 0x9a, 0x93, 0xca, 0xe4, 0x1f, 0x32, 0x62,
	];
	BLAKE3 h;
	h.start();
	assert(h.finish == expected);
}

/// verify digest of non-empty input
@safe pure nothrow @nogc unittest {
	const input = "Hello world!";
	// output of b3sum on file containing `input`:
	static immutable ubyte[digestLength] expected = [
	    0x79, 0x3c, 0x10, 0xbc, 0x0b, 0x28, 0xc3, 0x78,
	    0x33, 0x0d, 0x39, 0xed, 0xac, 0xe7, 0x26, 0x0a,
	    0xf9, 0xda, 0x81, 0xd6, 0x03, 0xb8, 0xff, 0xed,
	    0xe2, 0x70, 0x6a, 0x21, 0xed, 0xa8, 0x93, 0xf4
	];
	BLAKE3 h;
	h.start();
	h.put(cast(immutable(ubyte)[])input);
	assert(h.finish == expected);
}

version (unittest) {
	private enum digestLength = typeof(BLAKE3.init.finish()).sizeof;
}

import core.stdc.stdint : uint8_t, uint32_t, uint64_t;

// Copied from BLAKE3/c/blake3.h
extern(C) pure nothrow @nogc {
private enum BLAKE3_VERSION_STRING = "1.5.1";
private enum BLAKE3_KEY_LEN = 32;
private enum BLAKE3_OUT_LEN = 32;
private enum BLAKE3_BLOCK_LEN = 64;
private enum BLAKE3_CHUNK_LEN = 1024;
private enum BLAKE3_MAX_DEPTH = 54;

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
