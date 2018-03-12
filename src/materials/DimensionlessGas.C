#include "DimensionlessGas.h"
#include "MooseUtils.h"

template <>
InputParameters
validParams<DimensionlessGas>()
{
  InputParameters params = validParams<Gas>();

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

DimensionlessGas::DimensionlessGas(const InputParameters & parameters)
  : Gas(parameters),
    _mu0(getParam<Real>("characteristic_mobility")),
    _l0(getParam<Real>("characteristic_length")),
    _E0(getParam<Real>("characteristic_efield"))
{
  if (parameters.isParamSetByUser("potential_units"))
    mooseError("DimesionlessGas takes care of units for you. Don't specify potential_units");
}

void
DimensionlessGas::computeQpProperties()
{
  Gas::computeQpProperties();

  Real t0 = _l0 / (_mu0 * _E0);
  Real D0 = _l0 * _l0 / t0;

  _muem[_qp] /= _mu0;
  _d_muem_d_actual_mean_en[_qp] /= _mu0;
  _muArp[_qp] /= _mu0;
  _mumean_en[_qp] /= _mu0;
  _d_mumean_en_d_actual_mean_en[_qp] /= _mu0;
  _diffem[_qp] /= D0;
  _d_diffem_d_actual_mean_en[_qp] /= D0;
  _diffArp[_qp] /= D0;
  _diffmean_en[_qp] /= D0;
  _d_diffmean_en_d_actual_mean_en[_qp] /= D0;
  _diffpotential[_qp] = 1.0;

  _alpha_iz[_qp] *= _l0;
  _d_iz_d_actual_mean_en[_qp] *= _l0;
  _alpha_ex[_qp] *= _l0;
  _d_ex_d_actual_mean_en[_qp] *= _l0;
  _alpha_el[_qp] *= _l0;
  _d_el_d_actual_mean_en[_qp] *= _l0;
}
