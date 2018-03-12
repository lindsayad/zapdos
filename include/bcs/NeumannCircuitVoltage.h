/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef NEUMANNCIRCUITVOLTAGE_H
#define NEUMANNCIRCUITVOLTAGE_H

#include "IntegratedBC.h"
#include "ProvideMobility.h"

// Forward Declarations
class NeumannCircuitVoltage;
class Function;

template <>
InputParameters validParams<NeumannCircuitVoltage>();

/**
 * Boundary condition of a Neumann style whose value is computed by a user-defined function
 */
class NeumannCircuitVoltage : public IntegratedBC
{
public:
  NeumannCircuitVoltage(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  /// The function being used for setting the value
  Function & _V_bat;
  const ProvideMobility & _data;

  MooseVariable & _ip_var;
  const VariableValue & _ip;
  const VariableGradient & _grad_ip;
  unsigned int _ip_id;
  const VariableValue & _mean_en;
  unsigned int _mean_en_id;
  const VariableValue & _em;
  const VariableGradient & _grad_em;
  unsigned int _em_id;

  const MaterialProperty<Real> & _se_coeff;
  const MaterialProperty<Real> & _muip;
  const Real _eps;
  const MaterialProperty<Real> & _sgnip;
  const MaterialProperty<Real> & _Dip;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _d_muem_d_actual_mean_en;
  const MaterialProperty<Real> & _diffem;
  const Real _e;
  const MaterialProperty<Real> & _massem;
  const MaterialProperty<Real> & _T_heavy;
  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _mass;

  const Real _r;
  RealVectorValue _ion_flux;
  Real _n_gamma;
  Real _actual_mean_en;
  Real _v_e_th;
  Real _d_v_e_th_d_em;
  Real _d_v_e_th_d_mean_en;
  Real _v_i_th;
  Real _a;
  Real _b;
  RealVectorValue _d_ion_flux_d_u;
  RealVectorValue _d_ion_flux_d_ip;
  Real _d_n_gamma_d_u;
  Real _d_n_gamma_d_ip;
  Real _d_n_gamma_d_em;
  Real _d_n_gamma_d_mean_en;
  Real _numerator;
  Real _denominator;
  Real _d_numerator_d_u;
  Real _d_denominator_d_u;
  Real _d_numerator_d_ip;
  Real _d_denominator_d_ip;
  Real _d_numerator_d_em;
  Real _d_denominator_d_em;
  Real _d_numerator_d_mean_en;
  Real _d_denominator_d_mean_en;

  const Real _mu0;
  const Real _l0;
  const Real _E0;
};

#endif // NEUMANNCIRCUITVOLTAGE_H
