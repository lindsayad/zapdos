#ifndef DIMENSIONLESSGAS_H_
#define DIMENSIONLESSGAS_H_

#include "Gas.h"
#include "SplineInterpolation.h"

class DimensionlessGas;

template <>
InputParameters validParams<DimensionlessGas>();

class DimensionlessGas : public Gas
{
public:
  DimensionlessGas(const InputParameters & parameters);

  virtual Real characteristicEField() override { return _E0; }

protected:
  virtual void computeQpProperties() override;

  const Real _mu0;
  const Real _l0;
  const Real _E0;
};

#endif // DIMENSIONLESSGAS_H
