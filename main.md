---
bibliography: resources/bibliography.bib
---

\newpage

##### Abstract
We describe a symmetric variant of homomomorphic encryption scheme by van Dijk et al. [@DGHV10], semantically secure under the error-free approximate-GCD problem. We also provide the implementation of the scheme as a C/C++ library. The scheme allows to perform "mixed" homomorphic operations on ciphertexts and plaintexts, eliminating the need to encrypt new ciphertexts using the public key for some applications, specifically, in secure function evaluation setting. Compared to the original scheme and other homomorphic encryption schemes, the properties of the symmetric variant enable for smaller communication cost for applications like privacy-preserving cloud computing, and private information retrieval.

\newpage

Introduction
------------

Fully homomorphic encryption (FHE) is a special kind of encryption that allows arbitrary computations on encrypted data. The first FHE scheme was shown to be possible in the breakthrough work by Gentry [@Gen09] in 2009. A number of other FHE schemes based on different hardness assumptions were proposed since then [@DGHV10; @BGV12; @Bra12; @LTV12; @FV12].

While the original scheme was based on ideal lattices [@Gen09], van Dijk et al. proposed a new FHE scheme [@DGHV10] over the integers in 2010. Both these schemes follow Gentry's blueprint to achieve fully homomorphic property. They are known as the _first generation_ FHE.

The schemes produce similar "noisy" ciphertexts, where noise grows larger as more homomorphic operations are performed on a given ciphertext. When the noise reaches some maximum amount, the ciphertext becomes undecryptable. Following Gentry's approach, one first constructs a _somewhat homomorphic encryption_ scheme, i.e. scheme that is capable of evaluating a limited amount of homomorphic operations before the ciphertext becomes undecryptable. Secondly, one defines _bootstrapping_ procedure that eliminates the noise in ciphertexts (_ciphertext refreshing_). The procedure consists of homomorphic evaluation of the scheme's decryption circuit, which for a given ciphertext results in a different encryption of the same plaintext with reduced noise. Using bootstrapping, arbitrary binary circuits can be evaluated by refreshing the ciphertexts before the noise reaches the threshold. The disadvantage of this approach is that the bootstrapping procedure is very costly to perform.

To avoid bootstrapping, a new technique known as _modulus switching_ was introduced by Brakerski, Gentry, and Vaikuntanathan in 2012 [@BGV12]. They proposed a _leveled_ FHE scheme, i.e. the one in which noise grows linearly with multiplicative depth of the circuit. Such scheme, however, has huge public key storage requirements. In 2012 Brakerski introduced the notion of _scale-invariance_ for _leveled_ FHE schemes [@Bra12] that allows to reduce the storage significantly. This technique was applied to BGV scheme [@BGV12] by Fan and Vercauteren in 2012 [@FV12] resulting in FV scheme, and was used to construct a scheme called YASHE by Bos et al. in 2013 [@BLLN13] based on work from [@LTV12]. The mentioned schemes [@BGV12; @Bra12; @FV12; @BLLN13] as well as improved scheme by Gentry, Sahai, and Waters from 2013 [@GSW13] based on [@Bra12; @BGV12] are known as _second generation_ FHE.

##### Existing FHE mplementations

One of the practical publicly available implementations of FHE is the C++ library implementing the BGV scheme [@BGV12] with certain improvements [@SV11; @GHS12a] called `helib` [@GHS12b]. There are also experimental implementations of the variant of DGHV scheme in Sage [@CNT12], and FV and YASHE in C++ [@LN14].

##### Our contributions

In this work we focus on somewhat homomorphic DGHV scheme over the integers [@DGHV10]. We notice that DGHV supports "mixed" homomorphic operations on ciphertexts and plaintexts, which in the context of secure function evaluation allows to eliminate the need for either the client or the remote worker to encrypt all of the inputs of the algorithm, implying symmetric setting. We then describe a symmetric variant of the DGHV scheme as seen in [@YKPB13], and provide its usable implementation as a C/C++ library.


Preliminaries
-------------

### Generic Homomorphic Encryption Scheme

Whereas a regular public-key encryption scheme ``\mathcal{E}``
consists of three algorithms ``\mathsf{KeyGen}_\mathcal{E}``,
``\mathsf{Encrypt}_\mathcal{E}``, ``\mathsf{Decrypt}_\mathcal{E}``, a homomorphic encryption
scheme additionally includes homomorphic operations on ciphertexts that
we denote as ``\mathsf{Add}_\mathcal{E}`` and ``\mathsf{Mult}_\mathcal{E}``.

``\mathsf{KeyGen}_\mathcal{E}( 1^\lambda ).`` \hangindent=2em Given a
security parameter ``\lambda``, output a public and private key pair
``(\mathbf{pk, sk})``, where ``\mathbf{pk}`` is a public key, and
``\mathbf{sk}`` is a private key.

``\mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m \in \{0, 1\} ).``
\hangindent=2em Given a public key ``\mathbf{pk}`` and a plaintext message
``m \in \{0, 1\}``, output ciphertext ``c \in \mathcal{C}``, where
``\mathcal{C}`` is ciphertext space.

``\mathsf{Decrypt}_\mathcal{E}( \mathbf{sk}, c \in \mathcal{C} ).``
\hangindent=2em Given a private key ``\mathbf{sk}`` and a ciphertext
``c = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m )``, output original
plaintext message ``m \in \{0, 1\}``.

``\mathsf{Add}_\mathcal{E}( \mathbf{pk} , c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} )``
(resp. ``\mathsf{Mult}_\mathcal{E}``). \hangindent=2em Given a public key ``\mathbf{pk}`` and two ciphertexts ``c_1 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \in \{0, 1\} )`` and ``c_2 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_2 \in \{0, 1\} )``, output ciphertext ``c' \in \mathcal{C}``.

To be homomorphic, a scheme ``\mathcal{E} = ( \mathsf{KeyGen}_\mathcal{E}, \mathsf{Encrypt}_\mathcal{E}, \mathsf{Decrypt}_\mathcal{E}, \mathsf{Add}_\mathcal{E}, \mathsf{Mult}_\mathcal{E} )`` has to be able to correctly evaluate some class of binary circuits.

**Definition (Correct Homomorphic Decryption).** A scheme ``\mathcal{E}`` with security parameter ``\lambda`` is _correct_ for a ``L``-input binary circuit ``C`` composed of ``\oplus`` (``\mathsf{Add}``) and ``\wedge`` (``\mathsf{Mult})`` gates, if for any key pair ``( \mathbf{pk, sk} ) =  \mathsf{KeyGen}_{\mathcal{E}}( 1^\lambda )``, and any ``L`` plaintext bits ``m_1, ..., m_L \in \{ 0, 1 \}`` and corresponding ciphertexts ``c_1, ..., c_L``, where ``c_i = \mathsf{Encrypt}_{\mathcal{E}}( \mathbf{pk}, m_i )``, the following holds:

```math
C( m_1, ..., m_L ) = \mathsf{Decrypt}_{\mathcal{E}}( \mathbf{sk}, \mathsf{Evaluate}_{\mathcal{E}}( \mathbf{pk}, C, c_1, ..., c_L ) ),
```
where ``\mathsf{Evaluate}_{\mathcal{E}}`` simply applies ``\mathsf{Add}_\mathcal{E}`` and ``\mathsf{Mult}_\mathcal{E}`` to the ciphertexts at corresponding gates of the circuit ``C``.

**Definition (Homomorphic Scheme)**. We call scheme ``\mathcal{E}`` _(somewhat) homomorphic_ if it is correct for any circuit ``C \in \mathcal{C}_\mathcal{E}`` for some class of circuits ``\mathcal{C}_\mathcal{E}``. We call scheme ``\mathcal{E}`` _fully homomorphic_, if it is correct for any circuit ``C``.

### The Somewhat Homomorphic DGHV Scheme

##### Construction

In this section we recall the DGHV somewhat homomorphic encryption scheme over the integers proposed in [@DGHV10], specifically the variant with an error-free public key element. Four parameters are used to control the number of elements in the public key and the bit-length of various integers. We denote by ``\tau`` the number of elements in the public key, ``\gamma`` their bit-length, ``\eta`` the bit-length of the private key ``p``, and ``\rho`` (resp. ``\rho'``) the bit-length of the noise in the public key (resp. fresh ciphertext). All of the parameters are polynomial in security parameter ``\lambda``.

For integers ``z``, ``p`` we denote the reduction of ``z`` modulo ``p`` by
``(z \mod p)`` or ``[z]_p``.

\par

``\mathsf{DGHV.KeyGen}( 1^\lambda ).`` \hangindent=2em Randomly choose odd ``\eta``-bit integer ``p`` from ``( 2\mathbb{Z} + 1 ) \cap ( 2^{\eta-1}, 2^\eta )`` as private key. Randomly choose integers ``q_0, q_1, ... , q_\tau`` each from ``[1, 2^\gamma / p )`` subject to the condition that the largest ``q_i`` is odd, and relabel ``q_0, q_1, ... , q_\tau`` so that ``q_0`` is the largest. Randomly choose ``r_1, ... , r_\tau`` each from ``(-2^{\rho}, 2^{\rho})``. Set error-free public key element ``x_0 = q_0 \cdot p`` and ``x_i = q_i p + r_i`` for all ``1 \leq i \leq \tau``. Output ``(\mathbf{pk}, \mathbf{sk})``, where ``\mathbf{pk} = ( x_0, x_1, ..., x_\tau )``, and ``\mathbf{sk} = p``.

``\mathsf{DGHV.Encrypt}( \mathbf{pk}, m \in \{0, 1\} ).`` \hangindent=2em
Choose a random subset ``S \subset \{ 1, 2, ..., x_\tau \}`` and a random
noise integer ``r`` from ``(-2^{\rho'}, 2^{\rho'})``. Output the ciphertext:

```math
c = \left[ m + 2r + 2\sum_{i \in S} x_i \right]_{x_0}
```

\par

``\mathsf{DGHV.Decrypt}( \mathbf{sk}, c \in \mathcal{C} ).``
\hangindent=2em Output ``[ c \mod p ]_2``.

``\mathsf{DGHV.Add}( \mathbf{pk} , c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} ).``
\hangindent=2em Output ``[ c_1 + c_2 ]_{x_0}``

``\mathsf{DGHV.Mult}( \mathbf{pk}, c_1 \in \mathcal{C}, ~ c_2 \in \mathcal{C} ).``
\hangindent=2em Output ``[ c_1 \cdot c_2 ]_{x_0}``

It was shown in [@DGHV10] that scheme is somewhat homomorphic, i.e. a limited number of homomorphic operations can be performed on ciphertext. Specifically, roughly ``\eta/\rho'`` homomorphic multiplications can be performed in a way that the ciphertext is still correctly decryptable (the ciphertext noise must not exceed ``p``). The scheme can be extended to evaluate arbitrary circuits using the bootstrapping technique [@DGHV10].

##### Semantic security

The security of the DGHV scheme described as above is based on the
error-free approximate-GCD problem. We use the following distribution over ``\gamma``-bit integers:

```math
    \mathcal{D}_{\rho}(p, q_0) = \{
        \mathsf{Choose}~q \leftarrow [0, q_0 ), ~
        \mathsf{Choose}~r \leftarrow (-2^\rho, 2^\rho) ~:~
        \mathsf{Output}~x = q \cdot p + r \}
```

**Definition (``(\rho, \eta, \gamma)``-Error-Free Approximate-GCD).** For a random ``\eta``-bit odd integer ``p``, given ``x_0 = q_0 \cdot p``, where ``q_0`` is a random odd integer in ``( 2\mathbb{Z} + 1) \cap [ 0, 2^{ \gamma } / p )``, and polynomially many samples from ``\mathcal{D}_{\rho} ( p, q_0 )``, output ``p``.

The scheme is semantically secure if the error-free approximate-GCD problem is hard [@DGHV10]. Certain constraints have to be put on scheme parameters in order to achieve ``\lambda``-bit security.

##### Improvements

The scheme has been improved a number of times since it appeared. Public
key compression techniques were introduced in [@CMNT11; @CNT12],
achieving public key size of 1GB and 10.1 MB respectively at the 72-bit
security level. A modified scheme featuring batching capabilities
allowing for SIMD-style operations was proposed in [@CLT13]. The most
recent improvement at the moment of writing is the SIDGHV
scale-invariant modification [@CLT14] based on the techniques from
[@Bra12].


The Symmetric Variant of DGHV Somewhat Scheme
---------------------------------------------

### Construction

We now describe the symmetric variant of DGHV scheme with an error-free
public element as given in [@YKPB13]. We denote by ``\gamma`` the
bit-length of the public key ``x_0``, ``\eta`` the bit-length of the private
key ``p``, and ``\rho`` the bit-length of the noise in the public key and
fresh ciphertexts. All of the parameters are polynomial in security
parameter ``\lambda``.

``\mathsf{SDGHV.KeyGen}( 1^\lambda ).`` \hangindent=2em Randomly choose
odd ``\eta``-bit integer ``p`` from
``( 2\mathbb{Z} + 1 ) \cap ( 2^{\eta-1}, 2^\eta )`` as private key.
Randomly choose odd ``q_0`` from
``( 2\mathbb{Z} + 1 ) \cap [1, 2^\gamma/p )``, and set
``x_0 = q_0 \cdot p``. Output ``(\mathbf{pk}, \mathbf{sk})`` where
``\mathbf{pk} = x_0``, ``\mathbf{sk} = p``.

``\mathsf{SDGHV.Encrypt}( \mathbf{pk}, m \in \{0, 1\} ).`` \hangindent=2em
Choose random ``q`` from ``\mathbb{Z} \cap [1, 2^\gamma/p]``, and a random
noise integer ``r`` from ``\mathbb{Z} \cap (-2^{\rho}, 2^{\rho})``. Output
the ciphertext:

```math
c = \left[ q \cdot p + 2r + m \right]_{x_0}
```

\par

``\mathsf{SDGHV.Decrypt}( \mathbf{sk}, c \in \mathcal{C} ).``
\hangindent=2em Output ``[ c \mod p ]_2``.

``\mathsf{SDGHV.Add}( \mathbf{pk}, c_1 \in \mathcal{C}, c_2 \in \mathcal{C} ).``
\hangindent=2em Output ``[c_1 + c_2]_{x_0}``.

``\mathsf{SDGHV.Mult}( \mathbf{pk}, c_1 \in \mathcal{C}, c_2 \in \mathcal{C} ).``
\hangindent=2em Output ``[c_1 \cdot c_2]_{x_0}``.

The main difference compared to the original scheme is that only the noise-free public element ``x_0`` is used, while all the other public key elements ``x_1, x_2, ..., x_\tau`` are not used, i.e. ``\tau`` is set to 0.

The scheme is clearly somewhat homomorphic, allowing to compute a limited amount of additions and multiplications. Note the ``\mathsf{SDGHV.Add}`` and ``\mathsf{SDGHV.Mult}`` here can be used as mixed operations that take a ciphertext and a plaintext as input, since both ciphertext space and plaintext space are subsets of ``\mathbb{Z}``. Further explanations will follow.

### Semantic security

The scheme is a partial case of the original DGHV scheme with ``\tau = 0``, therefore, remains semantically secure if the error-free approximate-GCD problem is hard.

##### Attacks

Given error-free public element ``x_0 = q_0 p``, factoring algorithms can be used to find ``p``. [@KLYC13] gives overview of such attacks: elliptic curve factoring method which runs in ``\exp( \mathcal{O}(\eta^{1 / 2}) )``, and the general number field sieve which runs in ``\exp( \mathcal{O}( \gamma^{1 / 3} ) )``. The following constraints must be put: ``\eta \geq \mathcal{O}(\lambda^2)``, ``\gamma \geq \mathcal{O}(\lambda^3)``.

Given ``x_0 = q_0 \cdot p`` and set of ``x_i = q_i p + r``, ``1 \leq i \leq n``, Lagrasias algorithm can be used to find ``p`` in ``\mathcal{O}(2^{n / (\eta - \rho)})`` time. This is mitigated by choosing ``\gamma / \eta^2 = \omega(\log \lambda)``. For the case ``i = 1``, the following attacks can also be used: Chen-Nguyen [@CN12] attack running in ``\tilde{\mathcal{O}}(2^{\rho/2})``, mitigated by  requiring ``\rho > \mathcal{O}(\lambda)``, and Howgrave-Grahan [@How01] attack that implies requirement ``\gamma > \eta^2 / \rho `` [@KLYC13].

Note that the parameters chosen for benchmark in [@YKPB13] are not secure at the declared level against current approximate-GCD attacks (as also briefly noted in [@DC14]). Secure parameter constraints and a proposed parameter set are given below.

##### Parameter selection

We propose to use the following parameter constraints:

- ``\rho \geq 2\lambda`` to mitigate the attack in [@CN12]
- ``\eta``
- ``\gamma``


### Motivation

The variant was proposed in [@YKPB13] for the purpose of constructing a practical single-server computational private information retrieval protocol. The authors noticed that the generic PIR protocol they outlined didn't require encrypting new integers on the server side, implying the public key elements ``x_1, x_2, ..., x_\tau`` only used in encryption procedure could be omitted. Obtained symmetric scheme has improved the protocol's communication overhead due to the absence of all of the public key elements except the error-free element, while enabling to efficiently evaluate the server-side PIR retrieval algorithm.

The key feature of the SDGHV scheme that allows to avoid encryptions on the server-side is the ability to perform "natural" mixed homomorphic operations on plaintext and ciphertext:

``\mathsf{SDGHV.Add}( \mathbf{pk}, c \in \mathcal{C}, m \in \{0, 1\} ).``
\hangindent=2em Output ``[c + m]_{x_0}``.

``\mathsf{SDGHV.Mult}( \mathbf{pk}, c \in \mathcal{C}, m \in \{0, 1\} ).``
\hangindent=2em Output ``[c \cdot m]_{x_0}``.

Indeed, we can see that the mixed operations are correct (for a certain number of operations). Given the private key ``p``, public key ``x_0``, some messages ``m, m' \in \{ 0, 1 \}``, and a ciphertext ``c = \mathsf{SDGHV.Encrypt}( x_0, m ) = [ q \cdot p + 2r + m ]_{x_0}``:

```math
  \mathsf{SDGHV.Decrypt}( p, \mathsf{SDGHV.Add}( x_0, c, m' ) ) &=
                    \mathsf{SDGHV.Decrypt}( p, [c + m']_{x_0} ) \\
  &= \mathsf{SDGHV.Decrypt}( p, [ q \cdot p + 2r + m + m']_{x_0} ) \\
  &= [2r + m + m']_2 \\
  &= m \oplus m',
```

if ``m + m' + 2r < p``. Analogically,

```math
  \mathsf{SDGHV.Decrypt}( p, \mathsf{SDGHV.Mult}( x_0, c, m' ) ) &=
                    \mathsf{SDGHV.Decrypt}( p, [c \cdot m']_{x_0} ) \\
  &= \mathsf{SDGHV.Decrypt}( p, [ m' \cdot ( q \cdot p + 2r + m ) ]_{x_0} ) \\
  &= [2 r m' + m \cdot m']_2 \\
  &= m \wedge m'
```

We can see the number of homomorphic additions in the form ``c + m'``, where ``m' \in \{ 0, 1\}``, is limited to ``p - 2r - m`` for a specific ciphertext ``c = [ q \cdot p + 2r + m ]_{x_0}``.

##### Notes on applying existing DGHV improvements

Public key compression from [@CMNT11; @CNT12], doesn't make sense in the symmetric setting of SDGHV. Batching techniques as described in [@CLT13; @KLYC13; @CCK13] could be be applied to SDGHV scheme, but the mixed homomorphic operations correctness would be lost if CRT batching is used.


Conclusion
----------
In this work, we recalled the DGHV somewhat homomorphic encryption scheme [@DGHV10]. We described a symmetric variant of the scheme, and provided its implementation as a C/C++ library.

The variant scheme can be used in remote secure function evaluation applications like privacy-preserving cloud computing, and private information retrieval. Compared to the original scheme and other FHE schemes, it eliminates the computation costs required for encryption of all inputs of the function being securely evaluated, and reduces the communication cost significantly because of the absence of most of the public key elements.


References
----------
