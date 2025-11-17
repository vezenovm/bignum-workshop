mod stage1_tests;

// Stage 1: Generic BigNum with type parameters
// This allows us to distinguish between different fields (Fq vs Fr) at the type level

/// Generic BigNum struct parameterized by:
/// - LIMBS: number of limbs (compile-time constant)
/// - Params: type that provides field specific information (e.g., modulus)
pub struct BigNum<let LIMBS: u32, Params> {
    limbs: [u128; LIMBS],
}

impl<let LIMBS: u32, Params> BigNum<LIMBS, Params> {
    /// Constructs a BigNum from big-endian bytes
    /// Each limb holds (48/LIMBS) bytes of the number
    pub fn from_be_bytes(bytes: [u8; 48]) -> Self {
        let mut limbs = [0; LIMBS];
        let bytes_per_limb = 48 / LIMBS;

        // Parse bytes into limbs (big-endian: most significant limb first)
        for i in 0..LIMBS {
            let limb_start = i * bytes_per_limb;
            let mut limb_value: u128 = 0;

            for j in 0..bytes_per_limb {
                limb_value = limb_value * 256 + (bytes[limb_start + j] as u128);
            }

            limbs[i] = limb_value;
        }

        Self { limbs }
    }

    /// Simple addition without carry propagation
    /// NOTE: This is a simplified implementation for educational purposes.
    pub fn add(self, other: Self) -> Self {
        let mut result_limbs = [0; LIMBS];

        for i in 0..LIMBS {
            result_limbs[i] = self.limbs[i] + other.limbs[i];
        }

        Self { limbs: result_limbs }
    }

    /// Naive multiplication (only works for 4 limbs currently)
    /// NOTE: This is a simplified implementation.
    pub fn mul(self, other: Self) -> Self {
        let mut result = [0 as u128; 8];

        // Schoolbook multiplication
        for i in 0..LIMBS {
            for j in 0..LIMBS {
                let i_le = (LIMBS - 1) - i;
                let j_le = (LIMBS - 1) - j;
                let result_pos = i_le + j_le;

                let product = self.limbs[i] * other.limbs[j];
                result[result_pos] += product;
            }
        }

        // Convert result back to big-endian (take lower LIMBS)
        let mut final_limbs = [0; LIMBS];
        for i in 0..LIMBS {
            final_limbs[i] = result[(LIMBS - 1) - i];
        }
        Self { limbs: final_limbs }
    }
}

// ============================================================================
// Field-specific parameter types
// ============================================================================

/// Marker trait for BigNum parameters
/// Each field (Fq, Fr) will have its own params type
pub trait BigNumParamsTrait {
    fn modulus() -> [u128; 4];
}
/// Parameters for BrainpoolP384r1 base field (Fq)
pub struct BrainpoolP384r1FqParams {}

impl BigNumParamsTrait for BrainpoolP384r1FqParams {
    fn modulus() -> [u128; 4] {
        [
            0xd3a729901d1a71874700133107ec53,
            0x7109ed5456b412b1da197fb71123ac,
            0x82a3386d280f5d6f7e50e641df152f,
            0x8cb91e,
        ]
    }
}

/// Parameters for BrainpoolP384r1 scalar field (Fr)
pub struct BrainpoolP384r1FrParams {}

impl BigNumParamsTrait for BrainpoolP384r1FrParams {
    fn modulus() -> [u128; 4] {
        [
            0x3ab6af6b7fc3103b883202e9046565,
            0x7109ed5456b31f166e6cac0425a7cf,
            0x82a3386d280f5d6f7e50e641df152f,
            0x8cb91e,
        ]
    }
}

// ============================================================================
// Type aliases for convenience
// ============================================================================

/// BrainpoolP384r1 base field element
pub type BrainpoolP384r1_Fq = BigNum<4, BrainpoolP384r1FqParams>;

/// BrainpoolP384r1 scalar field element
pub type BrainpoolP384r1_Fr = BigNum<4, BrainpoolP384r1FrParams>;
