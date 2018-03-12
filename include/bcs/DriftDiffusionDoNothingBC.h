#ifndef DRIFTDIFFUSIONDONOTHINGBC_H
#define DRIFTDIFFUSIONDONOTHINGBC_H

#include "IntegratedBC.h"

class DriftDiffusionDoNothingBC;

template <>
InputParameters validParams<DriftDiffusionDoNothingBC>();

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

class DriftDiffusionDoNothingBC : public IntegratedBC
{
public:
  DriftDiffusionDoNothingBC(const InputParameters & parameters);
  virtual ~DriftDiffusionDoNothingBC();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const MaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _sign;

  const MaterialProperty<Real> & _diffusivity;

  unsigned int _potential_id;
  const VariableGradient & _grad_potential;
};

#endif /* DRIFTDIFFUSIONDONOTHINGBC_H */
