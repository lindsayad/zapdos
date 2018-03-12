#include "DensityFromDimensionless.h"

template <>
InputParameters
validParams<DensityFromDimensionless>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addRequiredCoupledVar("density_log", "The variable representing the log of the density.");
  params.addRequiredParam<Real>(
      "characteristic_length",
      "The characteristic length to be used for this simulation. Must be in units of meters.");
  params.addRequiredParam<Real>(
      "characteristic_efield",
      "The characteristic electric field strength. Must be in units of volts per meter.");
  params.addRequiredParam<Real>("characteristic_mobility",
                                "The characteristic mobility in units of m^2 / (V*s)");
  return params;
}

DensityFromDimensionless::DensityFromDimensionless(const InputParameters & parameters)
  : AuxKernel(parameters),
    _density_log(coupledValue("density_log")),
    _mu0(getParam<Real>("characteristic_mobility")),
    _l0(getParam<Real>("characteristic_length")),
    _E0(getParam<Real>("characteristic_efield"))
{
}

Real
DensityFromDimensionless::computeValue()
{
  return std::exp(_density_log[_qp]) * 8.85e-12 * _E0 / 1.6e-19 / _l0;
}
