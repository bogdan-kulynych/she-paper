---
bibliography: resources/bibliography.bib
---

\newpage


## Introduction

First-generation FHE schemes:
[@Gen09; @DGHV10; @BGV11].

Second-generation schemes:
Improvement of [@BGV12] called YASHE [@BLLN13]. Improvement of [@LTV12] by [@FV12]. Details in [@LN14].
Also, improvement of [@DGHV10] in [@CLT14].

Implementation of [@BGV12] with [@SV11; @GHS11] called `helib` [@GHS12].


## Preliminaries


### Generic Fully Homomorphic Encryption Scheme

Whereas a conventional public-key encryption scheme ``\mathcal{E}`` consists of three algorithms ``\mathsf{KeyGen}_\mathcal{E}``, ``\mathsf{Encrypt}_\mathcal{E}``, ``\mathsf{Decrypt}_\mathcal{E}``,
a FHE scheme additionally includes homomorphic operations on ciphertexts that we denote as ``\mathsf{Add}_\mathcal{E}`` and ``\mathsf{Mult}_\mathcal{E}``.

``\mathsf{KeyGen}_\mathcal{E}( 1^\lambda ).``
\hangindent=2em
Given a security parameter ``\lambda``, output a public and private key pair ``(\mathbf{pk, sk})``, where ``\mathbf{pk}`` is a public key, and ``\mathbf{sk}`` is a private key.

``\mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m \in \{0, 1\} ).``
\hangindent=2em
Given a public key ``\mathbf{pk}`` and a plaintext message ``m \in \{0, 1\}``, output ciphertext ``c \in \mathcal{C}``, where ``\mathcal{C}`` is  ciphertext space.

``\mathsf{Decrypt}_\mathcal{E}( \mathbf{sk}, c \in \mathcal{C} ).``
\hangindent=2em
Given a private key ``\mathbf{sk}`` and a ciphertext ``c = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m )``, output original plaintext message ``m \in \{0, 1\}``.

``\mathsf{Add}_\mathcal{E}( \mathbf{pk} , c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} )`` (resp. ``\mathsf{Mult}_\mathcal{E}``).
\hangindent=2em
Given a public key ``\mathbf{pk}`` and two ciphertexts ``c_1 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \in \{0, 1\} )`` and ``c_2 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_2 \in \{0, 1\} )``, output ciphertext ``c_3 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \oplus m_2 )`` (resp. ``c_3 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \wedge m_2 )``)


### Original Somewhat Homomorphic DGHV Scheme

##### Construction

In this section we recall the DGHV somewhat homomorphic encryption scheme over the integers proposed in [@DGHV10]. Four parameters are used to control the number of elements in the public key and the bit-length of various integers. We denote by ``\tau`` the number of elements in the public key, ``\gamma`` their bit-length, ``\eta`` the bit-length of the private key ``p``, and ``\rho`` (resp. ``\rho'``) the bit-length of the noise in the public key (resp. fresh ciphertext). All of the parameters are polynomial in security parameter ``\lambda``.

For integers ``z``, ``p`` we denote the reduction of ``z`` modulo ``p`` by ``(z \mod p)`` or ``[z]_p``. For a specific (``\eta``-bit) odd positive integer p, we use the following distribution over ``\gamma``-bit integers:

```math
    \mathcal{D}_{\gamma, \rho}(p) = \{
        \mathrm{choose}~q \leftarrow \mathbb{Z} \cap [0, 2^\gamma / p ), ~
        \mathrm{choose}~r \leftarrow \mathbb{Z} \cap (-2^\rho, 2^\rho) ~:~
        \mathrm{output}~x = q p + r \}
```

\par
``\mathsf{DGHV.KeyGen}( 1^\lambda ).``
\hangindent=2em
Randomly choose odd ``\eta``-bit integer ``p`` in ``( 2\mathbb{Z} + 1 ) \cap ( 2^{\eta-1}, 2^\eta )`` as private key. For ``1 \leq i \leq \tau``, sample ``x_i \leftarrow \mathcal{D}_{\gamma, \rho}( p )``. Relabel the ``x_i``’s so that ``x_0`` is the largest. Restart unless ``x_0`` is odd and ``[x_0]_p`` is even. Output ``(\mathbf{pk}, \mathbf{sk})``, where ``\mathbf{pk} = ( x_0, x_1, ..., x_\tau )``, and ``\mathbf{sk} = p``.

``\mathsf{DGHV.Encrypt}( \mathbf{pk}, m \in \{0, 1\} ).``
\hangindent=2em
Choose a random subset ``S \subset \{ 1, 2, ..., x_\tau \}`` and a random noise integer ``r`` in ``\mathbb{Z} \cap (-2^{\rho'}, 2^{\rho'})``. Output the ciphertext:
```math
c = \left[ m + 2r + 2\sum_{i \in S} x_i \right]_{x_0}
```

\par
``\mathsf{DGHV.Decrypt}( \mathbf{sk}, c \in \mathcal{C} ).``
\hangindent=2em
Output ``[ c \mod p ]_2``.

``\mathsf{DGHV.Add}( \mathbf{pk} , c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} ).``
\hangindent=2em
Output ``[ c_1 + c_2 ]_{x_0}``

``\mathsf{DGHV.Mult}( \mathbf{pk}, c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} ).``
\hangindent=2em
Output ``[ c_1 c_2 ]_{x_0}``

The scheme can be extended to be fully homomorphic using the bootstrapping technique following the Gentry's approach.

##### Security

The security of the DGHV scheme is based on the approximate-GCD problem, that is, given a set of polynomially many samples from ``\mathcal{D}_{\gamma, \rho}(p)`` for a randomly chosen ``\eta``-bit odd ``p``, determine ``p``. The scheme is semantically secure if the approximate-GCD problem is hard.

Specific lower bounds that can be found in [@DGHV10] are placed on the parameters in order to achieve the ``\lambda``-bit security level.

##### Improvements

The scheme has been improved a number of times since it appeared. Ciphertext compression techniques were proposed in [@CMNT11; @CNT11], the former one achieving public key size of 10.1 MB at the 72-bit security level. A modified scheme featuring batching capabilities allowing for SIMD-style operations was proposed in [@CLT13]. The most recent improvement at the moment of writing is the SIDGHV scale-invariant modification based on the techniques from [@Bra12] with compression and batching capabilities proposed in [@CLT14].


## Variant DGHV Scheme

Proposed in [@YKPB13] for the purpose of constructing a single-server computational Private Information Retrieval protocol. The protocol was  practical because of a mixing operations feature inherited from DGHV.

Safer parameters suggested in [@DC14].

## Implementation

## Summary

## References
