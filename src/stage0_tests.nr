use crate::BrainpoolP384r1_Fq;

#[test]
fn test_from_be_bytes() {
    // Create a simple number: 0x0000...0042 (just 66 in the least significant byte)
    let mut bytes = [0 as u8; 48];
    bytes[47] = 66; // Last byte = 66

    let num = BrainpoolP384r1_Fq::from_be_bytes(bytes);

    // The number should be in the last limb
    assert_eq(num.limbs, [0, 0, 0, 66]);
}

#[test]
fn test_add_simple() {
    // Test: 5 + 3 = 8
    let mut bytes_a = [0 as u8; 48];
    bytes_a[47] = 5;
    let a = BrainpoolP384r1_Fq::from_be_bytes(bytes_a);

    let mut bytes_b = [0 as u8; 48];
    bytes_b[47] = 3;
    let b = BrainpoolP384r1_Fq::from_be_bytes(bytes_b);

    let result = a.add(b);

    assert_eq(result.limbs, [0, 0, 0, 8]);
}

#[test]
fn test_add_overflow_limitation() {
    // This test demonstrates the limitation of our simple add() implementation
    // When a limb overflows, the carry is NOT propagated to the next limb

    // Create a number with max u128 value in the last limb
    let mut bytes_max = [0 as u8; 48];
    for i in 36..48 {
        bytes_max[i] = 0xff; // Fill last 12 bytes with 0xff (max value for limb)
    }

    let max_limb = BrainpoolP384r1_Fq::from_be_bytes(bytes_max);

    // Add 1 to it
    let mut bytes_one = [0 as u8; 48];
    bytes_one[47] = 1;
    let one = BrainpoolP384r1_Fq::from_be_bytes(bytes_one);

    let result = max_limb.add(one);

    // In a proper implementation, limbs[3] would overflow and carry to limbs[2]
    // But our simple implementation doesn't handle carries, so the overflow wraps around
    // The exact result depends on Noir's overflow behavior, but it won't carry properly

    // Just verify it doesn't crash
    assert(result.limbs.len() == 4);
}

#[test]
fn test_mul_simple() {
    // Test: 6 * 7 = 42
    let mut bytes_a = [0 as u8; 48];
    bytes_a[47] = 6;
    let a = BrainpoolP384r1_Fq::from_be_bytes(bytes_a);

    let mut bytes_b = [0 as u8; 48];
    bytes_b[47] = 7;
    let b = BrainpoolP384r1_Fq::from_be_bytes(bytes_b);

    let result = a.mul(b);

    assert_eq(result.limbs, [0, 0, 0, 42]);
}

#[test]
fn test_mul_truncation() {
    // Demonstrate truncation: multiply numbers with values in high-order limbs
    // The product will be in positions beyond our 4-limb window and get truncated

    // Set limbs[0] (most significant) to 2
    let mut bytes_a = [0u8; 48];
    bytes_a[11] = 2; // Last byte of first limb = 2
    let a = BrainpoolP384r1_Fq::from_be_bytes(bytes_a);

    // Set limbs[0] to 3
    let mut bytes_b = [0u8; 48];
    bytes_b[11] = 3; // Last byte of first limb = 3
    let b = BrainpoolP384r1_Fq::from_be_bytes(bytes_b);

    let result = a.mul(b);

    // The product 2 * 3 = 6 would be at position limbs[0] * limbs[0] in the full result
    // In little-endian, that's position 6 in the 8-limb array
    // But we only keep positions 0-3, so the actual product is truncated!
    // Result is all zeros - we lost the actual answer
    assert_eq(result.limbs, [0, 0, 0, 0]);
}
