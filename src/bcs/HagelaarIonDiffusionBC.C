#include "HagelaarIonDiffusionBC.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<HagelaarIonDiffusionBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("r", "The reflection coefficient");
  params.addRequiredParam<Real>(
      "characteristic_efield",
      "The characteristic electric field strength. Must be in units of volts per meter.");
  params.addRequiredParam<Real>("characteristic_mobility",
                                "The characteristic mobility in units of m^2 / (V*s)");
  return params;
}

HagelaarIonDiffusionBC::HagelaarIonDiffusionBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _r(getParam<Real>("r")),

    _kb(getMaterialProperty<Real>("k_boltz")),
    _T(getMaterialProperty<Real>("T" + _var.name())),
    _mass(getMaterialProperty<Real>("mass" + _var.name())),
    _v_thermal(0),
    _E0(getParam<Real>("characteristic_efield")),
    _mu0(getParam<Real>("characteristic_mobility"))
{
}

Real
HagelaarIonDiffusionBC::computeQpResidual()
{
  _v_thermal = std::sqrt(8 * _kb[_qp] * _T[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

  return _test[_i][_qp] * (1. - _r) / (1. + _r) * 0.5 * _v_thermal * std::exp(_u[_qp]);
}

Real
HagelaarIonDiffusionBC::computeQpJacobian()
{
  _v_thermal = std::sqrt(8 * _kb[_qp] * _T[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

  return _test[_i][_qp] * (1. - _r) / (1. + _r) * 0.5 * _v_thermal * std::exp(_u[_qp]) *
         _phi[_j][_qp];
}
