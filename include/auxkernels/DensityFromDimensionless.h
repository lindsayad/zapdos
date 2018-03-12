#ifndef DENSITYFROMDIMENSIONLESS_H
#define DENSITYFROMDIMENSIONLESS_H

#include "AuxKernel.h"

class DensityFromDimensionless;

template <>
InputParameters validParams<DensityFromDimensionless>();

class DensityFromDimensionless : public AuxKernel
{
public:
  DensityFromDimensionless(const InputParameters & parameters);

  virtual ~DensityFromDimensionless() {}

protected:
  virtual Real computeValue() override;

  const VariableValue & _density_log;
  const Real _mu0;
  const Real _l0;
  const Real _E0;
};

#endif // DENSITYFROMDIMENSIONLESS_H
