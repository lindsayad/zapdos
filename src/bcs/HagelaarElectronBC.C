#include "HagelaarElectronBC.h"

template <>
InputParameters
validParams<HagelaarElectronBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("r", "The reflection coefficient");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredParam<Real>(
      "characteristic_efield",
      "The characteristic electric field strength. Must be in units of volts per meter.");
  params.addRequiredParam<Real>("characteristic_mobility",
                                "The characteristic mobility in units of m^2 / (V*s)");
  return params;
}

HagelaarElectronBC::HagelaarElectronBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _r(getParam<Real>("r")),

    // Coupled Variables
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),

    _muem(getMaterialProperty<Real>("muem")),
    _massem(getMaterialProperty<Real>("massem")),
    _e(getMaterialProperty<Real>("e")),
    _a(0.5),
    _v_thermal(0),
    _d_v_thermal_d_u(0),
    _E0(getParam<Real>("characteristic_efield")),
    _mu0(getParam<Real>("characteristic_mobility")),
    _mean_energy(getMaterialProperty<Real>("actual_mean_energy"))
{
}

Real
HagelaarElectronBC::computeQpResidual()
{
  if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  _v_thermal =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * _mean_energy[_qp] / (M_PI * _massem[_qp])) / (_mu0 * _E0);

  return _test[_i][_qp] * (1. - _r) / (1. + _r) *
         (-(2 * _a - 1) * _muem[_qp] * -_grad_potential[_qp] * std::exp(_u[_qp]) * _normals[_qp] +
          0.5 * _v_thermal * std::exp(_u[_qp]));
}

Real
HagelaarElectronBC::computeQpJacobian()
{
  return 0;
}

Real
HagelaarElectronBC::computeQpOffDiagJacobian(unsigned int /*jvar*/)
{
  return 0;
}
