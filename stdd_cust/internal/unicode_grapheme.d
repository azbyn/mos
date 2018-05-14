module stdd.internal.unicode_grapheme;
import stdd.internal.unicode_tables;

package(stdd):

static if (size_t.sizeof == 8)
{
    //832 bytes
    enum hangulLVTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x20, 0x40],
            [0x100, 0x80, 0xa00], [0x2010000000000, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x4000300020001, 0x1000700060005, 0x5000400030002, 0x2000100070006,
            0x6000500040003, 0x3000200010007, 0x7000600050004, 0x4000300020001,
            0x1000700060005, 0x5000400030002, 0x8000100070006, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x100000010000001, 0x1000000100000, 0x10000001000,
            0x1000000100000010, 0x10000001000000, 0x100000010000, 0x1000000100,
            0x100000010000001, 0x1000000100000, 0x10000001000,
            0x1000000100000010, 0x10000001000000, 0x100000010000, 0x1000000100,
            0x100000010000001, 0x1000000100000, 0x10000001000,
            0x1000000100000010, 0x10000001000000, 0x100000010000, 0x1000000100,
            0x100000010000001, 0x1000000100000, 0x10000001000,
            0x1000000100000010, 0x10000001000000, 0x100000010000, 0x1000000100,
            0x10000001000000, 0x100000010000, 0x100, 0x0, 0x0, 0x0, 0x0, 0x0]);
    //832 bytes
    enum hangulLVTTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x20, 0x40],
            [0x100, 0x80, 0xa00], [0x2010000000000, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x4000300020001, 0x1000700060005, 0x5000400030002, 0x2000100070006,
            0x6000500040003, 0x3000200010007, 0x7000600050004, 0x4000300020001,
            0x1000700060005, 0x5000400030002, 0x8000100070006, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0xfeffffffeffffffe, 0xfffeffffffefffff, 0xfffffeffffffefff,
            0xeffffffeffffffef, 0xffeffffffeffffff, 0xffffeffffffeffff,
            0xffffffeffffffeff, 0xfeffffffeffffffe, 0xfffeffffffefffff,
            0xfffffeffffffefff, 0xeffffffeffffffef, 0xffeffffffeffffff,
            0xffffeffffffeffff, 0xffffffeffffffeff, 0xfeffffffeffffffe,
            0xfffeffffffefffff, 0xfffffeffffffefff, 0xeffffffeffffffef,
            0xffeffffffeffffff, 0xffffeffffffeffff, 0xffffffeffffffeff,
            0xfeffffffeffffffe, 0xfffeffffffefffff, 0xfffffeffffffefff,
            0xeffffffeffffffef, 0xffeffffffeffffff, 0xffffeffffffeffff,
            0xffffffeffffffeff, 0xffeffffffeffffff, 0xffffeffffffeffff,
            0xffffffeff, 0x0, 0x0, 0x0, 0x0, 0x0]);
    //1536 bytes
    enum mcTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x20, 0x60], [0x100,
            0x100, 0x1800], [0x202030202020100, 0x206020205020204,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x3000200010000, 0x6000000050004, 0x7, 0x8000000000000,
            0xb000a00090000, 0xc, 0x0, 0x0, 0x0, 0x0, 0xd, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x110010000f000e, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x130012, 0x1400000000,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x15000000000000, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x160000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc800000000000008, 0xde01,
            0xc00000000000000c, 0x801981, 0xc000000000000008, 0x1,
            0xc000000000000008, 0x1a01, 0x400000000000000c, 0x801981,
            0xc000000000000000, 0x801dc6, 0xe, 0x1e, 0x400000000000000c,
            0x600d9f, 0xc00000000000000c, 0x801dc1, 0xc, 0xc0000ff038000,
            0xc000000000000000, 0x8000000000000000, 0x0, 0x0,
            0x1902180000000000, 0x3f9c00c00000, 0x1c009f98, 0x0, 0x0, 0x0,
            0xc040000000000000, 0x1bf, 0x1fb0e7800000000, 0x0,
            0xffff000000000000, 0x301, 0x6000000, 0x7e01a00a00000, 0x0, 0x0,
            0xe820000000000010, 0x1b, 0x34c200000004, 0xc5c8000000000,
            0x300ff000000000, 0x0, 0x0, 0xc000200000000, 0xc00000000000, 0x0,
            0x0, 0x0, 0x9800000000, 0x0, 0xfff0000000000003, 0xf, 0x0, 0xc0000,
            0xec30000000000008, 0x1, 0x19800000000000, 0x800000000002000, 0x0,
            0x20c80000000000, 0x0, 0x0, 0x0, 0x16d800000000, 0x5, 0x0,
            0x187000000000004, 0x0, 0x100000000000, 0x0, 0x8038000000000004,
            0x1, 0x0, 0x0, 0x40d00000000000, 0x0, 0x0, 0x7ffffffffffe0000, 0x0,
            0x0, 0x0, 0x7e06000000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
    //2336 bytes
    enum graphemeExtendTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x20,
            0x70], [0x100, 0x140, 0x2d00], [0x402030202020100,
            0x207020206020205, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020202, 0x202020202020202,
            0x202020202020202, 0x202020202020208, 0x202020202020202,
            0x202020202020202, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1000000000000, 0x5000400030002,
            0x9000800070006, 0xd000c000b000a, 0xf00000000000e,
            0x10000000000000, 0x14001300120011, 0x160015, 0x17, 0x0, 0x0,
            0x190018, 0x1a, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x1b00000000, 0x1f001e001d001c, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x20000000000000, 0x22002100000000,
            0x230000, 0x0, 0x2400000000, 0x0, 0x260025, 0x2700000000, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x28000000000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x2a00290000, 0x0, 0x0, 0x0, 0x2b0000, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0xffffffffffffffff, 0xffffffffffff, 0x0, 0x0, 0x0, 0x0,
            0x3f8, 0x0, 0x0, 0x0, 0xbffffffffffe0000, 0xb6, 0x7ff0000,
            0x10000fffff800, 0x0, 0x3d9f9fc00000, 0xffff000000020000, 0x7ff,
            0x1ffc000000000, 0xff80000000000, 0x3eeffbc00000, 0xe000000, 0x0,
            0x7ffffff000000000, 0x1400000000000007, 0xc00fe21fe,
            0x5000000000000002, 0xc0080201e, 0x1000000000000006,
            0x23000000023986, 0x1000000000000006, 0xc000021be,
            0xd000000000000002, 0xc00c0201e, 0x4000000000000004, 0x802001,
            0xc000000000000000, 0xc00603dc1, 0x9000000000000000, 0xc00603044,
            0x4000000000000000, 0xc0080201e, 0x0, 0x805c8400,
            0x7f2000000000000, 0x7f80, 0x1bf2000000000000, 0x3f00,
            0x2a0000003000000, 0x7ffe000000000000, 0x1ffffffffeffe0df, 0x40,
            0x66fde00000000000, 0x1e0001c3000000, 0x20002064, 0x0, 0x0,
            0xe0000000, 0x0, 0x0, 0x1c0000001c0000, 0xc0000000c0000,
            0x3fb0000000000000, 0x200ffe40, 0x3800, 0x0, 0x20000000000, 0x0,
            0xe04018700000000, 0x0, 0x0, 0x0, 0x9800000, 0x9ff81fe57f400000,
            0x0, 0x0, 0x17d000000000000f, 0xff80000000004, 0xb3c00000003,
            0x3a34000000000, 0xcff00000000000, 0x0, 0x0, 0x1021fdfff70000, 0x0,
            0x0, 0x0, 0xf000007fffffffff, 0x3000, 0x0, 0x0, 0x1ffffffff0000,
            0x0, 0x0, 0x0, 0x3800000000000, 0x0, 0x8000000000000000, 0x0,
            0xffffffff00000000, 0xfc0000000000, 0x0, 0x6000000, 0x0, 0x0,
            0x3ff7800000000000, 0x80000000, 0x3000000000000, 0x6000000844, 0x0,
            0x0, 0x3ffff00000010, 0x3fc000000000, 0x3ff80, 0x13c8000000000007,
            0x0, 0x667e0000000000, 0x1008, 0xc19d000000000000,
            0x40300000000002, 0x0, 0x0, 0x0, 0x212000000000, 0x40000000, 0x0,
            0x0, 0x0, 0x7f0000ffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc0000000, 0x0,
            0x0, 0x0, 0x0, 0x2000000000000000, 0x870000000000f06e, 0x0, 0x0,
            0x0, 0xff00000000000002, 0x7f, 0x678000000000003, 0x0,
            0x1fef8000000007, 0x0, 0x7fc0000000000003, 0x0, 0x0, 0x0,
            0xbf280000000000, 0x0, 0x0, 0x0, 0x78000, 0x0, 0x0,
            0xf807c3a000000000, 0x3c0000000fe7, 0x0, 0x0, 0x1c, 0x0, 0x0,
            0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff,
            0xffffffffffff, 0x0, 0x0, 0x0, 0x0]);

}

static if (size_t.sizeof == 4)
{
    //832 bytes
    enum hangulLVTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x40, 0x80],
            [0x100, 0x80, 0xa00], [0x0, 0x20100, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x20001, 0x40003, 0x60005, 0x10007, 0x30002, 0x50004, 0x70006,
            0x20001, 0x40003, 0x60005, 0x10007, 0x30002, 0x50004, 0x70006,
            0x20001, 0x40003, 0x60005, 0x10007, 0x30002, 0x50004, 0x70006,
            0x80001, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x10000001, 0x1000000, 0x100000, 0x10000,
            0x1000, 0x100, 0x10, 0x1000000, 0x100000, 0x10000, 0x1000, 0x100,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
    //832 bytes
    enum hangulLVTTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x40, 0x80],
            [0x100, 0x80, 0xa00], [0x0, 0x20100, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x20001, 0x40003, 0x60005, 0x10007, 0x30002, 0x50004, 0x70006,
            0x20001, 0x40003, 0x60005, 0x10007, 0x30002, 0x50004, 0x70006,
            0x20001, 0x40003, 0x60005, 0x10007, 0x30002, 0x50004, 0x70006,
            0x80001, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0xeffffffe, 0xfeffffff, 0xffefffff, 0xfffeffff,
            0xffffefff, 0xfffffeff, 0xffffffef, 0xeffffffe, 0xfeffffff,
            0xffefffff, 0xfffeffff, 0xffffefff, 0xfffffeff, 0xffffffef,
            0xeffffffe, 0xfeffffff, 0xffefffff, 0xfffeffff, 0xffffefff,
            0xfffffeff, 0xffffffef, 0xeffffffe, 0xfeffffff, 0xffefffff,
            0xfffeffff, 0xffffefff, 0xfffffeff, 0xffffffef, 0xeffffffe,
            0xfeffffff, 0xffefffff, 0xfffeffff, 0xffffefff, 0xfffffeff,
            0xffffffef, 0xeffffffe, 0xfeffffff, 0xffefffff, 0xfffeffff,
            0xffffefff, 0xfffffeff, 0xffffffef, 0xeffffffe, 0xfeffffff,
            0xffefffff, 0xfffeffff, 0xffffefff, 0xfffffeff, 0xffffffef,
            0xeffffffe, 0xfeffffff, 0xffefffff, 0xfffeffff, 0xffffefff,
            0xfffffeff, 0xffffffef, 0xfeffffff, 0xffefffff, 0xfffeffff,
            0xffffefff, 0xfffffeff, 0xf, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0]);
    //1536 bytes
    enum mcTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x40, 0xc0], [0x100,
            0x100, 0x1800], [0x2020100, 0x2020302, 0x5020204, 0x2060202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x10000, 0x30002, 0x50004,
            0x60000, 0x7, 0x0, 0x0, 0x80000, 0x90000, 0xb000a, 0xc, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xd, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xf000e, 0x110010,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x130012, 0x0, 0x0, 0x14, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x150000, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x160000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x8, 0xc8000000, 0xde01, 0x0,
            0xc, 0xc0000000, 0x801981, 0x0, 0x8, 0xc0000000, 0x1, 0x0, 0x8,
            0xc0000000, 0x1a01, 0x0, 0xc, 0x40000000, 0x801981, 0x0, 0x0,
            0xc0000000, 0x801dc6, 0x0, 0xe, 0x0, 0x1e, 0x0, 0xc, 0x40000000,
            0x600d9f, 0x0, 0xc, 0xc0000000, 0x801dc1, 0x0, 0xc, 0x0,
            0xff038000, 0xc0000, 0x0, 0xc0000000, 0x0, 0x80000000, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x19021800, 0xc00000, 0x3f9c, 0x1c009f98, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc0400000, 0x1bf, 0x0, 0x0,
            0x1fb0e78, 0x0, 0x0, 0x0, 0xffff0000, 0x301, 0x0, 0x6000000, 0x0,
            0xa00000, 0x7e01a, 0x0, 0x0, 0x0, 0x0, 0x10, 0xe8200000, 0x1b, 0x0,
            0x4, 0x34c2, 0x0, 0xc5c80, 0x0, 0x300ff0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0xc0002, 0x0, 0xc000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x98, 0x0,
            0x0, 0x3, 0xfff00000, 0xf, 0x0, 0x0, 0x0, 0xc0000, 0x0, 0x8,
            0xec300000, 0x1, 0x0, 0x0, 0x198000, 0x2000, 0x8000000, 0x0, 0x0,
            0x0, 0x20c800, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x16d8, 0x5, 0x0,
            0x0, 0x0, 0x4, 0x1870000, 0x0, 0x0, 0x0, 0x1000, 0x0, 0x0, 0x4,
            0x80380000, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x40d000, 0x0, 0x0,
            0x0, 0x0, 0xfffe0000, 0x7fffffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x7e060, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
    //2336 bytes
    enum graphemeExtendTrieEntries = TrieEntry!(bool, 8, 5, 8)([0x0, 0x40,
            0xe0], [0x100, 0x140, 0x2d00], [0x2020100, 0x4020302, 0x6020205,
            0x2070202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x2020208, 0x2020202, 0x2020202, 0x2020202, 0x2020202,
            0x2020202, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x10000, 0x30002, 0x50004,
            0x70006, 0x90008, 0xb000a, 0xd000c, 0xe, 0xf0000, 0x0, 0x100000,
            0x120011, 0x140013, 0x160015, 0x0, 0x17, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x190018, 0x0, 0x1a, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x1b, 0x1d001c, 0x1f001e, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x200000, 0x0, 0x220021, 0x230000,
            0x0, 0x0, 0x0, 0x0, 0x24, 0x0, 0x0, 0x260025, 0x0, 0x0, 0x27, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x280000, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x290000, 0x2a, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2b0000,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0xffffffff, 0xffffffff, 0xffffffff, 0xffff, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x3f8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0xfffe0000, 0xbfffffff, 0xb6, 0x0, 0x7ff0000, 0x0, 0xfffff800,
            0x10000, 0x0, 0x0, 0x9fc00000, 0x3d9f, 0x20000, 0xffff0000, 0x7ff,
            0x0, 0x0, 0x1ffc0, 0x0, 0xff800, 0xfbc00000, 0x3eef, 0xe000000,
            0x0, 0x0, 0x0, 0x0, 0x7ffffff0, 0x7, 0x14000000, 0xfe21fe, 0xc,
            0x2, 0x50000000, 0x80201e, 0xc, 0x6, 0x10000000, 0x23986, 0x230000,
            0x6, 0x10000000, 0x21be, 0xc, 0x2, 0xd0000000, 0xc0201e, 0xc, 0x4,
            0x40000000, 0x802001, 0x0, 0x0, 0xc0000000, 0x603dc1, 0xc, 0x0,
            0x90000000, 0x603044, 0xc, 0x0, 0x40000000, 0x80201e, 0xc, 0x0,
            0x0, 0x805c8400, 0x0, 0x0, 0x7f20000, 0x7f80, 0x0, 0x0, 0x1bf20000,
            0x3f00, 0x0, 0x3000000, 0x2a00000, 0x0, 0x7ffe0000, 0xfeffe0df,
            0x1fffffff, 0x40, 0x0, 0x0, 0x66fde000, 0xc3000000, 0x1e0001,
            0x20002064, 0x0, 0x0, 0x0, 0x0, 0x0, 0xe0000000, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x1c0000, 0x1c0000, 0xc0000, 0xc0000, 0x0, 0x3fb00000,
            0x200ffe40, 0x0, 0x3800, 0x0, 0x0, 0x0, 0x0, 0x200, 0x0, 0x0, 0x0,
            0xe040187, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x9800000, 0x0,
            0x7f400000, 0x9ff81fe5, 0x0, 0x0, 0x0, 0x0, 0xf, 0x17d00000, 0x4,
            0xff800, 0x3, 0xb3c, 0x0, 0x3a340, 0x0, 0xcff000, 0x0, 0x0, 0x0,
            0x0, 0xfff70000, 0x1021fd, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0xffffffff, 0xf000007f, 0x3000, 0x0, 0x0, 0x0, 0x0, 0x0,
            0xffff0000, 0x1ffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x38000,
            0x0, 0x0, 0x0, 0x80000000, 0x0, 0x0, 0x0, 0xffffffff, 0x0, 0xfc00,
            0x0, 0x0, 0x6000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3ff78000,
            0x80000000, 0x0, 0x0, 0x30000, 0x844, 0x60, 0x0, 0x0, 0x0, 0x0,
            0x10, 0x3ffff, 0x0, 0x3fc0, 0x3ff80, 0x0, 0x7, 0x13c80000, 0x0,
            0x0, 0x0, 0x667e00, 0x1008, 0x0, 0x0, 0xc19d0000, 0x2, 0x403000,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2120, 0x40000000, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0xffff, 0x7f, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x0, 0xc0000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x0, 0x20000000, 0xf06e, 0x87000000, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0x2, 0xff000000, 0x7f, 0x0, 0x3, 0x6780000, 0x0,
            0x0, 0x7, 0x1fef80, 0x0, 0x0, 0x3, 0x7fc00000, 0x0, 0x0, 0x0, 0x0,
            0x0, 0x0, 0x0, 0xbf2800, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x78000,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xf807c3a0, 0xfe7, 0x3c00, 0x0, 0x0,
            0x0, 0x0, 0x1c, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffffffff, 0xffffffff,
            0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffff,
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);

}
