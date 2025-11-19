mod stage3_tests;

use std::cmp::Eq;
use std::ops::{Add, Mul};

// Stage 3: Metaprogramming with derive_bignum
// Eliminate code duplication using compile-time code generation!

/// Parameters for a BigNum field (modulus, etc.)
pub struct BigNumParams {
    pub modulus: [u128; 4],
}

/// BigNum Trait - shared interface for all big number types
pub trait BigNum: Add + Mul + Eq {
    fn from_be_bytes(bytes: [u8; 48]) -> Self;
    fn params() -> BigNumParams;
}

// ============================================================================
// Generalized helper functions that operate on limb arrays
// ============================================================================

/// Add two limb arrays
pub fn add_limbs<let N: u32>(lhs: [u128; N], rhs: [u128; N]) -> [u128; N] {
    let mut result = [0; N];
    for i in 0..N {
        result[i] = lhs[i] + rhs[i];
    }
    result
}

/// Multiply two limb arrays (simplified - only works for N=4)
pub fn mul_limbs<let N: u32>(lhs: [u128; N], rhs: [u128; N]) -> [u128; N] {
    let mut result = [0 as u128; 8];

    // Schoolbook multiplication
    for i in 0..N {
        for j in 0..N {
            let i_le = (N - 1) - i;
            let j_le = (N - 1) - j;
            let result_pos = i_le + j_le;

            let product = lhs[i] * rhs[j];
            result[result_pos] += product;
        }
    }

    // Convert result back to big-endian
    let mut final_limbs = [0; N];
    for i in 0..N {
        final_limbs[i] = result[(N - 1) - i];
    }
    final_limbs
}

/// Check equality of two limb arrays
pub fn eq_limbs<let N: u32>(lhs: [u128; N], rhs: [u128; N]) -> bool {
    lhs == rhs
}

/// Parse big-endian bytes into limbs
pub fn from_be_bytes_limbs<let N: u32>(bytes: [u8; 48]) -> [u128; N] {
    let mut limbs = [0; N];
    let bytes_per_limb = 48 / N;

    for i in 0..N {
        let limb_start = i * bytes_per_limb;
        let mut limb_value: u128 = 0;

        for j in 0..bytes_per_limb {
            limb_value = limb_value * 256 + (bytes[limb_start + j] as u128);
        }

        limbs[i] = limb_value;
    }

    limbs
}

/// Derive BigNum, Add, Mul, and Eq implementations for a struct
/// Matches the production library pattern
pub comptime fn derive_bignum(strukt: TypeDefinition, N: u32, params: Quoted) -> Quoted {
    let typ = strukt.as_type();
    quote {
        // Implement BigNum trait
        impl $crate::BigNum for $typ {
            fn from_be_bytes(bytes: [u8; 48]) -> Self {
                Self { limbs: $crate::from_be_bytes_limbs::<$N>(bytes) }
            }

            fn params() -> $crate::BigNumParams {
                $params
            }
        }

        // Implement stdlib Add trait using shared add_limbs function
        impl std::ops::Add for $typ {
            fn add(self, other: Self) -> Self {
                Self { limbs: $crate::add_limbs(self.limbs, other.limbs) }
            }
        }

        // Implement stdlib Mul trait using shared mul_limbs function
        impl std::ops::Mul for $typ {
            fn mul(self, other: Self) -> Self {
                Self { limbs: $crate::mul_limbs(self.limbs, other.limbs) }
            }
        }

        // Implement stdlib Eq trait using shared eq_limbs function
        impl std::cmp::Eq for $typ {
            fn eq(self, other: Self) -> bool {
                $crate::eq_limbs(self.limbs, other.limbs)
            }
        }
    }
}

pub global BrainpoolP384r1_Fq_PARAMS: BigNumParams = BigNumParams {
    modulus: [
        0xd3a729901d1a71874700133107ec53,
        0x7109ed5456b412b1da197fb71123ac,
        0x82a3386d280f5d6f7e50e641df152f,
        0x8cb91e,
    ],
};

pub global BrainpoolP384r1_Fr_PARAMS: BigNumParams = BigNumParams {
    modulus: [
        0x3ab6af6b7fc3103b883202e9046565,
        0x7109ed5456b31f166e6cac0425a7cf,
        0x82a3386d280f5d6f7e50e641df152f,
        0x8cb91e,
    ],
};

/// BrainpoolP384r1 base field element (Fq)
#[derive_bignum(4, quote { BrainpoolP384r1_Fq_PARAMS })]
pub struct BrainpoolP384r1_Fq {
    limbs: [u128; 4],
}

/// BrainpoolP384r1 scalar field element (Fr)
#[derive_bignum(4, quote { BrainpoolP384r1_Fr_PARAMS })]
pub struct BrainpoolP384r1_Fr {
    limbs: [u128; 4],
}
