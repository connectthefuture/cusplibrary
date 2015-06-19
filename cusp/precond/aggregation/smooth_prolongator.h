/*
 *  Copyright 2008-2014 NVIDIA Corporation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#pragma once

#include <cusp/detail/config.h>

#include <cusp/execution_policy.h>

namespace cusp
{
namespace precond
{
namespace aggregation
{

/* \cond */
template <typename DerivedPolicy,
          typename MatrixType1,
          typename MatrixType2,
          typename MatrixType3,
          typename ValueType>
void smooth_prolongator(const thrust::detail::execution_policy_base<DerivedPolicy> &exec,
                        const MatrixType1& S,
                        const MatrixType2& T,
                              MatrixType3& P,
                        const ValueType rho_Dinv_S = 0.0,
                        const ValueType omega = 4.0/3.0);
/* \endcond */

//   Smoothed (final) prolongator defined by P = (I - omega/rho(K) K) * T
//   where K = diag(S)^-1 * S and rho(K) is an approximation to the
//   spectral radius of K.
template <typename MatrixType1,
          typename MatrixType2,
          typename MatrixType3,
          typename ValueType>
void smooth_prolongator(const MatrixType1& S,
                        const MatrixType2& T,
                              MatrixType3& P,
                        const ValueType rho_Dinv_S = 0.0,
                        const ValueType omega = 4.0/3.0);

} // end namespace aggregation
} // end namespace precond
} // end namespace cusp

#include <cusp/precond/aggregation/detail/smooth_prolongator.inl>