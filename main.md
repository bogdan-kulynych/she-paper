---
bibliography: resources/bibliography.bib
---

\newpage

We describe a symmetric variant of homomomorphic encryption scheme by van Dijk et al. [@DGHV10], that remains semantically secure under the error-free approximate-GCD problem. The scheme allows to perform mixed homomorphic operations on ciphertexts and plaintexts, eliminating the need to encrypt new ciphertexts using the public key in a remote execution setting for some algorithms. Compared to the original scheme, the properties of our variant enable for smaller communication cost for generic secure function evaluation applications, specifically, private
information retrieval.

Introduction
------------

First-generation FHE schemes: [@Gen09; @DGHV10; @BGV11].

Second-generation schemes: Improvement of [@BGV12] called YASHE
[@BLLN13]. Improvement of [@LTV12] by [@FV12]. Details in [@LN14]. Also,
improvement of [@DGHV10] in [@CLT14].

Implementation of [@BGV12] with [@SV11; @GHS12a] called `helib` [@GHS12b].

Preliminaries
-------------

### Generic Fully Homomorphic Encryption Scheme

Whereas a conventional public-key encryption scheme ``\mathcal{E}``
consists of three algorithms ``\mathsf{KeyGen}_\mathcal{E}``,
``\mathsf{Encrypt}_\mathcal{E}``, ``\mathsf{Decrypt}_\mathcal{E}``, a FHE
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
(resp. ``\mathsf{Mult}_\mathcal{E}``). \hangindent=2em Given a public key
``\mathbf{pk}`` and two ciphertexts
``c_1 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \in \{0, 1\} )``
and
``c_2 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_2 \in \{0, 1\} )``,
output ciphertext
``c_3 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \oplus m_2 )``
(resp.
``c_3 = \mathsf{Encrypt}_\mathcal{E}( \mathbf{pk}, m_1 \wedge m_2 )``)

### The Somewhat Homomorphic DGHV Scheme

##### Construction

In this section we recall the DGHV somewhat homomorphic encryption
scheme over the integers proposed in [@DGHV10], specifically the
variant with an error-free public key element. Four parameters are
used to control the number of elements in the public key and the
bit-length of various integers. We denote by ``\tau`` the number of
elements in the public key, ``\gamma`` their bit-length, ``\eta`` the
bit-length of the private key ``p``, and ``\rho`` (resp. ``\rho'``) the
bit-length of the noise in the public key (resp. fresh ciphertext). All
of the parameters are polynomial in security parameter ``\lambda``.

For integers ``z``, ``p`` we denote the reduction of ``z`` modulo ``p`` by
``(z \mod p)`` or ``[z]_p``. For a specific (``\eta``-bit) odd positive
integer ``p``.

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

It was shown in [@DGHV10] that scheme is somewhat homomorphic, i.e. a
limited number of homomorphic operations can be performed on ciphertext.
Specifically, roughly ``\eta/\rho'`` homomorphic multiplications can be
performed in a way that the ciphertext is still correctly decryptable
(the ciphertext noise must not exceed ``p``). The scheme can be extended
to evaluate arbitrary circuits using the bootstrapping technique
following the Gentry's approach [@DGHV10].

##### Security

The security of the DGHV scheme described as above is based on the
error-free approximate-GCD problem. We use the following distribution over ``\gamma``-bit integers:

```math
    \mathcal{D}^{\rho}(p, q_0) = \{
        \mathsf{Choose}~q \leftarrow [0, q_0 ), ~
        \mathsf{Choose}~r \leftarrow (-2^\rho, 2^\rho) ~:~
        \mathsf{Output}~x = q \cdot p + r \}
```

**Definition (``(\rho, \eta, \gamma)``-Error-Free Approximate-GCD).** For a random ``\eta``-bit ``p``, given ``x_0 = q_0 \cdot p``, where ``q_0`` is a random odd integer in ``( 2\mathbb{Z} + 1) \cap [ 0, 2^{ \gamma } / p )``, and polynomially many samples ``x_i`` from ``\mathcal{D}_{\rho} ( p, q_0 )``, output ``p``.

The scheme is semantically secure if the error-free approximate-GCD problem is hard.

##### Improvements

The scheme has been improved a number of times since it appeared. Public
key compression techniques were introduced in [@CMNT11; @CNT12],
achieving public key size of 1GB and 10.1 MB respectively at the 72-bit
security level. A modified scheme featuring batching capabilities
allowing for SIMD-style operations was proposed in [@CLT13]. The most
recent improvement at the moment of writing is the SIDGHV
scale-invariant modification [@CLT14] based on the techniques from
[@Bra12] with compression and batching capabilities.


The Symmetric Variant of DGHV Somewhat Scheme
---------------------------------------------

#### Construction

We now describe the symmetric variant of DGHV scheme with an error-free
public element as given in [@YKPB13; @CCK13]. We denote by ``\gamma`` the
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

The main difference compared to the original scheme is that only the
noise-free public element ``x_0`` is used, while all the other public key
elements ``x_1, x_2, ..., x_\tau`` are set to 0. Note the
``\mathsf{SDGHV.Add}`` and ``\mathsf{SDGHV.Mult}`` here can be used as mixed
operations that take a ciphertext and a plaintext as input, since both
ciphertext space and plaintext space are subsets of ``\mathbb{Z}``. See
the next section for explanation.

#### Motivation

The variant was proposed in [@YKPB13] for the purpose of constructing a
practical single-server computational private information retrieval
protocol. The authors noticed that the generic PIR protocol they
outlined didn't require encrypting new integers on the server side,
implying the public key elements ``x_1, x_2, ..., x_\tau`` only used in
encryption procedure could be omitted. Obtained symmetric scheme has
improved the protocol's communication overhead due to the absence of all
of the public key elements except the error-free element, while enabling
to efficiently evaluate the server-side PIR retrieval algorithm.

The key feature of the SDGHV scheme that allows to avoid encryptions on
the server-side is the ability to perform "natural" mixed homomorphic
operations on plaintext and ciphertext:

``\mathsf{SDGHV.Add}( \mathbf{pk}, c \in \mathcal{C}, m \in \{0, 1\} ).``
\hangindent=2em Output ``[c + m]_{x_0}``.

``\mathsf{SDGHV.Mult}( \mathbf{pk}, c \in \mathcal{C}, m \in \{0, 1\} ).``
\hangindent=2em Output ``[c \cdot m]_{x_0}``.

Indeed, we can see that the mixed operations are correct, i.e. given the
private key ``p``, public key ``x_0``, some messages ``m, m' \in \{ 0, 1 \}``, and a ciphertext ``c = \mathsf{SDGHV.Encrypt}( x_0, m ) = [ q \cdot p + 2r + m ]_{x_0}``:

```math
  \mathsf{SDGHV.Decrypt}( p, \mathsf{SDGHV.Add}( x_0, c, m' ) ) &=
                    \mathsf{SDGHV.Decrypt}( p, [c + m']_{x_0} ) \\
  &= \mathsf{SDGHV.Decrypt}( p, [ q \cdot p + 2r + m + m']_{x_0} ) \\
  &= [2r + m + m']_2 \\
  &= m \oplus m'
```

And analogically,

```math
  \mathsf{SDGHV.Decrypt}( p, \mathsf{SDGHV.Mult}( x_0, c, m' ) ) &=
                    \mathsf{SDGHV.Decrypt}( p, [c \cdot m']_{x_0} ) \\
  &= \mathsf{SDGHV.Decrypt}( p, [ m' \cdot ( q \cdot p + 2r + m ) ]_{x_0} ) \\
  &= [2 r m' + m \cdot m']_2 \\
  &= m \wedge m'
```

We can see the number of homomorphic additions in the form ``c + m'``,
where ``m' \in \{ 0, 1\}``, is limited to ``p - 2r - m``, for a specific
ciphertext ``c = [ q \cdot m + 2r + m ]_{x_0}``.

#### Security

The scheme is semantically secure if the adapted error-free approximate-GCD problem is hard. We use the following modified distribution over ``\gamma``-bit integers:

```math
    \mathcal{D}^{\rho}_{x_0}(p, q_0) = \{
        \mathsf{Choose}~q \leftarrow [0, q_0 ), ~
        \mathsf{Choose}~r \leftarrow (-2^\rho, 2^\rho) ~:~ \\
        \mathsf{Output}~x = [q \cdot p + r]_{x_0} \}
```

**Definition (Adapted ``(\rho, \eta, \gamma)``-Error-Free Approximate-GCD). ** For a random ``\eta``-bit ``p``, given ``x_0 = q_0 \cdot p``, where ``q_0`` is a random odd integer in ``(2\mathbb{Z} + 1) \cap [ 0, 2^{ \gamma } / p )``, and polynomially many samples ``x_i`` from ``\mathcal{D}_{\rho}^{x_0} ( p, q_0 )``, output ``p``.

**Lemma**. Adapted error-free approximate-GCD problem is equivalent to ordinary error-free approximate-GCD problem if ``\rho < \eta``.

_Proof_. The proof is straightforward. For an instance of ordinary error-free approximate-GCD, one simply sets ``x'_i = x_i \mod x_0`` for all samples ``x_i`` to obtain an instance of an adapted error-free approximate-GCD. Conversely, for an instance of adapted error-free approximate-GCD, ``x_0 > q_i p + r_i`` for all ``i``, since ``r_i < p``. Therefore, ``x_i~\mod~x_0 \equiv x_i`` for all ``i``, yielding an ordinary error-free approximate-GCD instance. \qed{}

While the brute force attack on the error-free approximate-GCD instance requires ``\mathcal{O}( 2^\rho )`` computation, the best attack to date [@CN12] is able to find solution in ``\mathcal{\tilde{O}}( 2^{\rho/2} )``.

Note that the parameters chosen for benchmark in [@YKPB13] are not
secure at the declared level against current approximate-GCD attacks (as
also briefly noted in [@DC14]). Secure parameter constraints and a
proposed parameter set are given below.

#### Parameter selection

We propose to use the parameter constraints based on the attacks
overview from [@KLYC13]:

```math
\rho &\geq 2\lambda \quad \text{to mitigate the attack in \cite{CN12}} \\
```


#### Improvements

Public key compression from [@CMNT11; @CNT12], doesn't make sense in the
symmetric setting of SDGHV. Batching techniques as described in
[@CLT13; @KLYC13; @CCK13] could be be applied to SDGHV scheme, but the
mixed homomorphic operations correctness would be lost if CRT batching
is used, so it doesn't make sense.

Implementation
--------------

Summary
-------

References
----------
