mod stage2_tests;

use std::cmp::Eq;
use std::ops::{Add, Mul};

// Stage 2b: BigNum Trait with stdlib operator overloading
// Now we can use +, *, and == operators!

/// Parameters for a BigNum field (modulus, etc.)
pub struct BigNumParams {
    pub modulus: [u128; 4],
}

/// BigNum Trait - shared interface for all big number types
/// Extends stdlib traits for operator overloading
pub trait BigNum: Add + Mul + Eq {
    fn from_be_bytes(bytes: [u8; 48]) -> Self;
    fn params() -> BigNumParams;
}

/// BrainpoolP384r1 base field element (Fq)
pub struct BrainpoolP384r1_Fq {
    limbs: [u128; 4],
}

/// BrainpoolP384r1 scalar field element (Fr)
pub struct BrainpoolP384r1_Fr {
    limbs: [u128; 4],
}

// Implement stdlib Add trait for + operator
impl Add for BrainpoolP384r1_Fq {
    fn add(self, other: Self) -> Self {
        let mut result_limbs = [0; 4];

        for i in 0..4 {
            result_limbs[i] = self.limbs[i] + other.limbs[i];
        }

        Self { limbs: result_limbs }
    }
}

// Implement stdlib Mul trait for * operator
impl Mul for BrainpoolP384r1_Fq {
    fn mul(self, other: Self) -> Self {
        let mut result = [0 as u128; 8];

        // Schoolbook multiplication
        for i in 0..4 {
            for j in 0..4 {
                let i_le = 3 - i;
                let j_le = 3 - j;
                let result_pos = i_le + j_le;

                let product = self.limbs[i] * other.limbs[j];
                result[result_pos] += product;
            }
        }

        Self { limbs: [result[3], result[2], result[1], result[0]] }
    }
}

// Implement stdlib Eq trait for == operator
impl Eq for BrainpoolP384r1_Fq {
    fn eq(self, other: Self) -> bool {
        self.limbs == other.limbs
    }
}

// Implement BigNum trait
impl BigNum for BrainpoolP384r1_Fq {
    fn from_be_bytes(bytes: [u8; 48]) -> Self {
        let mut limbs = [0; 4];

        // Parse bytes into limbs (big-endian: most significant limb first)
        for i in 0..4 {
            let limb_start = i * 12;
            let mut limb_value: u128 = 0;

            for j in 0..12 {
                limb_value = limb_value * 256 + (bytes[limb_start + j] as u128);
            }

            limbs[i] = limb_value;
        }

        Self { limbs }
    }

    fn params() -> BigNumParams {
        BigNumParams {
            modulus: [
                0xd3a729901d1a71874700133107ec53,
                0x7109ed5456b412b1da197fb71123ac,
                0x82a3386d280f5d6f7e50e641df152f,
                0x8cb91e,
            ],
        }
    }
}

// Implement stdlib Add trait for + operator
impl Add for BrainpoolP384r1_Fr {
    fn add(self, other: Self) -> Self {
        let mut result_limbs = [0; 4];

        for i in 0..4 {
            result_limbs[i] = self.limbs[i] + other.limbs[i];
        }

        Self { limbs: result_limbs }
    }
}

// Implement stdlib Mul trait for * operator
impl Mul for BrainpoolP384r1_Fr {
    fn mul(self, other: Self) -> Self {
        let mut result = [0 as u128; 8];

        // Schoolbook multiplication
        for i in 0..4 {
            for j in 0..4 {
                let i_le = 3 - i;
                let j_le = 3 - j;
                let result_pos = i_le + j_le;

                let product = self.limbs[i] * other.limbs[j];
                result[result_pos] += product;
            }
        }

        Self { limbs: [result[3], result[2], result[1], result[0]] }
    }
}

// Implement stdlib Eq trait for == operator
impl Eq for BrainpoolP384r1_Fr {
    fn eq(self, other: Self) -> bool {
        self.limbs == other.limbs
    }
}

// Implement BigNum trait
impl BigNum for BrainpoolP384r1_Fr {
    fn from_be_bytes(bytes: [u8; 48]) -> Self {
        let mut limbs = [0; 4];

        // Parse bytes into limbs (big-endian: most significant limb first)
        for i in 0..4 {
            let limb_start = i * 12;
            let mut limb_value: u128 = 0;

            for j in 0..12 {
                limb_value = limb_value * 256 + (bytes[limb_start + j] as u128);
            }

            limbs[i] = limb_value;
        }

        Self { limbs }
    }

    fn params() -> BigNumParams {
        BigNumParams {
            modulus: [
                0x3ab6af6b7fc3103b883202e9046565,
                0x7109ed5456b31f166e6cac0425a7cf,
                0x82a3386d280f5d6f7e50e641df152f,
                0x8cb91e,
            ],
        }
    }
}
