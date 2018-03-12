#ifndef HAGELAARIONDIFFUSIONBC_H
#define HAGELAARIONDIFFUSIONBC_H

#include "IntegratedBC.h"

class HagelaarIonDiffusionBC;

template <>
InputParameters validParams<HagelaarIonDiffusionBC>();

class HagelaarIonDiffusionBC : public IntegratedBC
{
public:
  HagelaarIonDiffusionBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  Real _r;

  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _T;
  const MaterialProperty<Real> & _mass;

  Real _v_thermal;
  const Real _E0;
  const Real _mu0;
};

#endif // HAGELAARIONDIFFUSIONBC_H
