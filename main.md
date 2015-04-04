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


### The Somewhat Homomorphic DGHV Scheme

##### Construction

In this section we recall the DGHV somewhat homomorphic encryption scheme over the integers proposed in [@DGHV10], specifically the variation with an error-free public key element. Four parameters are used to control the number of elements in the public key and the bit-length of various integers. We denote by ``\tau`` the number of elements in the public key, ``\gamma`` their bit-length, ``\eta`` the bit-length of the private key ``p``, and ``\rho`` (resp. ``\rho'``) the bit-length of the noise in the public key (resp. fresh ciphertext). All of the parameters are polynomial in security parameter ``\lambda``.

For integers ``z``, ``p`` we denote the reduction of ``z`` modulo ``p`` by ``(z \mod p)`` or ``[z]_p``. For a specific (``\eta``-bit) odd positive integer p, we use the following distribution over ``\gamma``-bit integers:

```math
    \mathcal{D}_{\gamma, \rho}(p) = \{
        \mathsf{Choose}~q \leftarrow [0, 2^\gamma / p ), ~
        \mathsf{Choose}~r \leftarrow (-2^\rho, 2^\rho) ~:~
        \mathsf{Output}~x = q \cdot p + r \}
```
\par
``\mathsf{DGHV.KeyGen}( 1^\lambda ).``
\hangindent=2em
Randomly choose odd ``\eta``-bit integer ``p`` from ``( 2\mathbb{Z} + 1 ) \cap ( 2^{\eta-1}, 2^\eta )`` as private key. Randomly choose integer ``q_0`` from ``[0, 2^\gamma / p )`` and set error-free public key element ``x_0 = q_0 \cdot p``. For ``1 \leq i \leq \tau``, sample ``x_i \leftarrow \mathcal{D}_{\gamma, \rho}( p )``. Output ``(\mathbf{pk}, \mathbf{sk})``, where ``\mathbf{pk} = ( x_0, x_1, ..., x_\tau )``, and ``\mathbf{sk} = p``.

``\mathsf{DGHV.Encrypt}( \mathbf{pk}, m \in \{0, 1\} ).``
\hangindent=2em
Choose a random subset ``S \subset \{ 1, 2, ..., x_\tau \}`` and a random noise integer ``r`` from ``(-2^{\rho'}, 2^{\rho'})``. Output the ciphertext:
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
Output ``[ c_1 \cdot c_2 ]_{x_0}``

A limited number of homomorphic operations can be performed on ciphertexts, but the scheme can be extended to be fully homomorphic using the bootstrapping technique following the Gentry's approach.

##### Security

The security of the DGHV scheme is based on the (Error-Free) Approximate-GCD problem, that is, given a set of polynomially many samples from ``\mathcal{D}_{\gamma, \rho}(p)`` and ``x_0 = q_0 \cdot p`` for a randomly chosen ``\eta``-bit odd ``p`` and a randomly chosen ``q_0 \in [1, 2^\gamma/p)``, determine ``p``. The scheme is semantically secure if the (Error-Free) Approximate-GCD problem is hard.

Certain constraints accounting for known Approximate-GCD attacks are to be put on parameters in order to achieve the ``\lambda``-bit security level. The constraints accounting for latest known attacks can be found in [@CLT14].

##### Improvements

The scheme has been improved a number of times since it appeared. Public key compression techniques were proposed in [@CMNT11; @CNT11], achieving public key size of 1GB and 10.1 MB respectively at the 72-bit security level. A modified scheme featuring batching capabilities allowing for SIMD-style operations was proposed in [@CLT13]. The most recent improvement at the moment of writing is the SIDGHV scale-invariant modification [@CLT14] based on the techniques from [@Bra12] with compression and batching capabilities.


## The Variant of DGHV Somewhat Scheme

##### Construction

We now describe the variant of DGHV scheme with an error-free public key element as given in [@YKPB13]. We denote by ``\gamma`` the bit-length of the public key ``x_0``, ``\eta`` the bit-length of the private key ``p``, and ``\rho`` the bit-length of the noise in the public key and fresh ciphertexts. All of the parameters are polynomial in security parameter ``\lambda``.

``\mathsf{VDGHV.KeyGen}( 1^\lambda ).``
\hangindent=2em
Randomly choose odd ``\eta``-bit integer ``p`` from ``( 2\mathbb{Z} + 1 ) \cap ( 2^{\eta-1}, 2^\eta )`` as private key. Randomly choose odd ``q_0`` from ``( 2\mathbb{Z} + 1 ) \cap [1, 2^\gamma/p )``, and set ``x_0 = q_0 \cdot p``.
Output ``(\mathbf{pk}, \mathbf{sk})`` where ``\mathbf{pk} = x_0``, ``\mathbf{sk} = p``.

``\mathsf{VDGHV.Encrypt}( \mathbf{pk}, m \in \{0, 1\} ).``
\hangindent=2em
Choose random ``q`` from ``\mathbb{Z} \cap [1, 2^\gamma/p]``, and a random noise integer ``r`` from ``\mathbb{Z} \cap (-2^{\rho}, 2^{\rho})``. Output the ciphertext:
```math
c = \left[ q \cdot p + 2r + m \right]_{x_0}
```
\par
``\mathsf{VDGHV.Decrypt}( \mathbf{sk}, c \in \mathcal{C} ).``
\hangindent=2em
Output ``[ c \mod p ]_2``.

``\mathsf{VDGHV.Add}( \mathbf{pk} , c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} ).``
\hangindent=2em
Output ``[ c_1 + c_2 ]_{x_0}``

``\mathsf{VDGHV.Mult}( \mathbf{pk}, c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} ).``
\hangindent=2em
Output ``[ c_1 \cdot c_2 ]_{x_0}``

The difference with the original scheme is that only the noise-free public key element ``x_0`` is used, while all the other public key elements ``x_1, x_2, ..., x_\tau`` are set to 0.

##### Security

Any instance of the VDGHV scheme is clearly an instance of DGHV scheme as described above with ``x_1, x_2, ..., x_\tau`` set to 0, implying the same security requirements. Therefore, the scheme is semantically secure if the (Error-Free) Approximate-GCD problem is hard.

[@DC14] mentions that the parameters chosen by default in [@YKPB13] might be not secure at the declared level against the latest Approximate-GCD attacks. Alternative parameter constraints are given below.

##### Parameter selection

We propose to use the parameters based on recent results from [@CLT14].

##### Motivation

The variant was proposed in [@YKPB13] for the purpose of constructing a practical single-server computational Private Information Retrieval protocol. The authors noticed that the generic PIR protocol they outlined didn't require encrypting new integers on the server side, rendering ``x_1, x_2, ..., x_\tau`` public key elements useless. Thus, a variant scheme enables for a significantly lower communication overhead.

An important feature of the VDGHV (and the parent DGHV) scheme that allows to avoid additional encryptions on the server-side is the ability to perform "natural" mixed homomorphic operations on plaintext and ciphertext, since both plaintext and ciphertext spaces are subsets of ``\mathbb{Z}``.

``\mathsf{VDGHV.Add( \mathbf{pk}, c \in \mathcal{C}, m \in \{0, 1\} )}.``
\hangindent=2em
Output ``[c + m]_{x_0}``.

``\mathsf{VDGHV.Mult( \mathbf{pk}, c \in \mathcal{C}, m \in \{0, 1\} )}.``
\hangindent=2em
Output ``[c \cdot m]_{x_0}``.

Indeed, we can see that the mixed operations are correct, i.e. given the private key ``p``, public key ``x_0``, ciphertext ``c = \mathsf{VDGHV.Encrypt}( x_0, m ) = [ q \cdot p + 2r + m ]_{x_0}``

```math
  \mathsf{VDGHV.Decrypt}( p, \mathsf{VGHV.Add}( x_0, c, m' ) ) &=
                    \mathsf{VDGHV.Decrypt}( p, [c + m']_{x_0} ) \\
  &= \mathsf{VDGHV.Decrypt}( p, [ q \cdot p + 2r + m + m']_{x_0} ) \\
  &= [2r + m + m']_2 \\
  &= m \oplus m'
```

Analogically,

```math
  \mathsf{VDGHV.Decrypt}( p, \mathsf{VGHV.Mult}( x_0, c, m' ) ) &=
                    \mathsf{VDGHV.Decrypt}( p, [c \cdot m']_{x_0} ) \\
  &= \mathsf{VDGHV.Decrypt}( p, [ m' \cdot ( q \cdot p + 2r + m ) ]_{x_0} ) \\
  &= [2 r m' + m \cdot m']_2 \\
  &= m \wedge m'
```


## Implementation

## Summary

## References
