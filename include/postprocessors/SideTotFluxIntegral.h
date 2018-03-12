#ifndef SIDETOTFLUXINTEGRAL_H
#define SIDETOTFLUXINTEGRAL_H

// MOOSE includes
#include "SideIntegralPostprocessor.h"

// Forward Declarations
class SideTotFluxIntegral;

template <>
InputParameters validParams<SideTotFluxIntegral>();

/**
 * This postprocessor computes a side integral of the mass flux.
 */
class SideTotFluxIntegral : public SideIntegralPostprocessor
{
public:
  SideTotFluxIntegral(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral();

  MooseVariable & _ip_var;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _muip;
  const MaterialProperty<Real> & _diffem;
  const MaterialProperty<Real> & _diffip;

  const VariableGradient & _grad_potential;
  const VariableGradient & _grad_em;
  const VariableValue & _em;
  const VariableGradient & _grad_ip;
  const VariableValue & _ip;
};

#endif // SIDETOTFLUXINTEGRAL_H
